package middleware

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/liel/lingo-nexus-server/testutil"
)

// nextHandlerFunc is a test http.Handler that records whether it was called.
type nextHandlerFunc struct {
	called bool
	ctx    context.Context
}

func (h *nextHandlerFunc) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h.called = true
	h.ctx = r.Context()
	w.WriteHeader(http.StatusOK)
}

func TestAuth_MissingAuthorizationHeader(t *testing.T) {
	mock := &testutil.MockAuthService{}
	next := &nextHandlerFunc{}
	middleware := Auth(mock)(next)

	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	w := httptest.NewRecorder()

	middleware.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("status = %d, want %d", w.Code, http.StatusUnauthorized)
	}
	if next.called {
		t.Error("next handler should not be called for missing auth header")
	}
}

func TestAuth_BearerPrefixRequired(t *testing.T) {
	mock := &testutil.MockAuthService{}
	next := &nextHandlerFunc{}
	middleware := Auth(mock)(next)

	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	req.Header.Set("Authorization", "Token abc123") // wrong prefix
	w := httptest.NewRecorder()

	middleware.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("status = %d, want %d", w.Code, http.StatusUnauthorized)
	}
	if next.called {
		t.Error("next handler should not be called without Bearer prefix")
	}
}

func TestAuth_InvalidToken(t *testing.T) {
	mock := &testutil.MockAuthService{
		ValidateAccessTokenFunc: func(tokenString string) (uint64, error) {
			return 0, &invalidTokenError{"invalid signature"}
		},
	}
	next := &nextHandlerFunc{}
	middleware := Auth(mock)(next)

	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	req.Header.Set("Authorization", "Bearer invalid.token.here")
	w := httptest.NewRecorder()

	middleware.ServeHTTP(w, req)

	if w.Code != http.StatusUnauthorized {
		t.Errorf("status = %d, want %d", w.Code, http.StatusUnauthorized)
	}
	if next.called {
		t.Error("next handler should not be called for invalid token")
	}
}

func TestAuth_ValidToken_CallsNext(t *testing.T) {
	const userID uint64 = 42
	mock := &testutil.MockAuthService{
		ValidateAccessTokenFunc: func(_ string) (uint64, error) {
			return userID, nil
		},
	}
	next := &nextHandlerFunc{}
	middleware := Auth(mock)(next)

	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	req.Header.Set("Authorization", "Bearer valid.jwt.token")
	w := httptest.NewRecorder()

	middleware.ServeHTTP(w, req)

	if !next.called {
		t.Error("next handler should be called for valid token")
	}
	if w.Code != http.StatusOK {
		t.Errorf("status = %d, want %d", w.Code, http.StatusOK)
	}
}

func TestAuth_ValidToken_SetsUserIDInContext(t *testing.T) {
	const userID uint64 = 99
	mock := &testutil.MockAuthService{
		ValidateAccessTokenFunc: func(_ string) (uint64, error) {
			return userID, nil
		},
	}
	next := &nextHandlerFunc{}
	middleware := Auth(mock)(next)

	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	req.Header.Set("Authorization", "Bearer valid.jwt.token")
	w := httptest.NewRecorder()

	middleware.ServeHTTP(w, req)

	if next.ctx == nil {
		t.Fatal("context not captured by next handler")
	}
	gotID, ok := GetUserID(next.ctx)
	if !ok {
		t.Error("GetUserID returned ok=false, expected userID to be set in context")
	}
	if gotID != userID {
		t.Errorf("GetUserID = %d, want %d", gotID, userID)
	}
}

func TestGetUserID_NotSet(t *testing.T) {
	ctx := context.Background()
	id, ok := GetUserID(ctx)
	if ok {
		t.Error("GetUserID should return ok=false for empty context")
	}
	if id != 0 {
		t.Errorf("GetUserID should return 0 for empty context, got %d", id)
	}
}

// invalidTokenError simulates a JWT validation error.
type invalidTokenError struct{ msg string }

func (e *invalidTokenError) Error() string { return e.msg }
