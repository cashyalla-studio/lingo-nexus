package handler

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/testutil"
)

func TestAuthHandler_Login(t *testing.T) {
	validResp := &model.AuthResponse{
		AccessToken:  "access-token",
		RefreshToken: "refresh-token",
		ExpiresIn:    86400,
	}

	tests := []struct {
		name       string
		body       string
		mockSetup  func(*testutil.MockAuthService)
		wantStatus int
	}{
		{
			name:       "empty body returns 400",
			body:       `{}`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name:       "missing id_token returns 400",
			body:       `{"provider":"google"}`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name:       "missing provider returns 400",
			body:       `{"id_token":"tok"}`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name:       "unsupported provider returns 400",
			body:       `{"provider":"apple","id_token":"tok"}`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name: "valid google login returns 200",
			body: `{"provider":"google","id_token":"valid-token"}`,
			mockSetup: func(m *testutil.MockAuthService) {
				m.LoginWithGoogleFunc = func(_ context.Context, idToken string) (*model.AuthResponse, error) {
					return validResp, nil
				}
			},
			wantStatus: http.StatusOK,
		},
		{
			name: "google auth service error returns 401",
			body: `{"provider":"google","id_token":"bad-token"}`,
			mockSetup: func(m *testutil.MockAuthService) {
				m.LoginWithGoogleFunc = func(_ context.Context, _ string) (*model.AuthResponse, error) {
					return nil, errors.New("invalid google token")
				}
			},
			wantStatus: http.StatusUnauthorized,
		},
		{
			name:       "malformed JSON returns 400",
			body:       `{invalid json`,
			wantStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mock := &testutil.MockAuthService{}
			if tt.mockSetup != nil {
				tt.mockSetup(mock)
			}
			h := NewAuthHandler(mock)

			req := httptest.NewRequest(http.MethodPost, "/api/v1/auth/login",
				bytes.NewBufferString(tt.body))
			req.Header.Set("Content-Type", "application/json")
			w := httptest.NewRecorder()

			h.Login(w, req)

			if w.Code != tt.wantStatus {
				t.Errorf("Login() status = %d, want %d (body: %s)",
					w.Code, tt.wantStatus, w.Body.String())
			}
		})
	}
}

func TestAuthHandler_Login_ResponseBody(t *testing.T) {
	expected := &model.AuthResponse{
		AccessToken:  "at-123",
		RefreshToken: "rt-456",
		ExpiresIn:    86400,
	}
	mock := &testutil.MockAuthService{
		LoginWithGoogleFunc: func(_ context.Context, _ string) (*model.AuthResponse, error) {
			return expected, nil
		},
	}
	h := NewAuthHandler(mock)

	req := httptest.NewRequest(http.MethodPost, "/api/v1/auth/login",
		bytes.NewBufferString(`{"provider":"google","id_token":"tok"}`))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	h.Login(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var got model.AuthResponse
	if err := json.Unmarshal(w.Body.Bytes(), &got); err != nil {
		t.Fatalf("response is not valid JSON: %v", err)
	}
	if got.AccessToken != expected.AccessToken {
		t.Errorf("access_token = %q, want %q", got.AccessToken, expected.AccessToken)
	}
	if got.RefreshToken != expected.RefreshToken {
		t.Errorf("refresh_token = %q, want %q", got.RefreshToken, expected.RefreshToken)
	}
}

func TestAuthHandler_Refresh(t *testing.T) {
	tests := []struct {
		name       string
		body       string
		mockSetup  func(*testutil.MockAuthService)
		wantStatus int
	}{
		{
			name:       "missing refresh_token returns 400",
			body:       `{}`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name: "valid refresh_token returns 200",
			body: `{"refresh_token":"valid-rt"}`,
			mockSetup: func(m *testutil.MockAuthService) {
				m.RefreshAccessTokenFunc = func(_ context.Context, _ string) (*model.AuthResponse, error) {
					return &model.AuthResponse{AccessToken: "new-at"}, nil
				}
			},
			wantStatus: http.StatusOK,
		},
		{
			name: "expired refresh_token returns 401",
			body: `{"refresh_token":"expired-rt"}`,
			mockSetup: func(m *testutil.MockAuthService) {
				m.RefreshAccessTokenFunc = func(_ context.Context, _ string) (*model.AuthResponse, error) {
					return nil, errors.New("refresh token expired")
				}
			},
			wantStatus: http.StatusUnauthorized,
		},
		{
			name:       "malformed JSON returns 400",
			body:       `{bad`,
			wantStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mock := &testutil.MockAuthService{}
			if tt.mockSetup != nil {
				tt.mockSetup(mock)
			}
			h := NewAuthHandler(mock)

			req := httptest.NewRequest(http.MethodPost, "/api/v1/auth/refresh",
				bytes.NewBufferString(tt.body))
			req.Header.Set("Content-Type", "application/json")
			w := httptest.NewRecorder()

			h.Refresh(w, req)

			if w.Code != tt.wantStatus {
				t.Errorf("Refresh() status = %d, want %d (body: %s)",
					w.Code, tt.wantStatus, w.Body.String())
			}
		})
	}
}
