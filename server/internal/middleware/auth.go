package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/liel/lingo-nexus-server/internal/service"
)

type contextKey string

const UserIDKey contextKey = "userID"

// Auth returns a middleware that validates JWT access tokens.
// Routes wrapped with this middleware require a valid Bearer token.
func Auth(authSvc *service.AuthService) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			authHeader := r.Header.Get("Authorization")
			if !strings.HasPrefix(authHeader, "Bearer ") {
				writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "missing authorization header"})
				return
			}

			token := strings.TrimPrefix(authHeader, "Bearer ")
			userID, err := authSvc.ValidateAccessToken(token)
			if err != nil {
				writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid or expired token"})
				return
			}

			ctx := context.WithValue(r.Context(), UserIDKey, userID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// GetUserID extracts the authenticated user ID from context.
func GetUserID(ctx context.Context) (uint64, bool) {
	id, ok := ctx.Value(UserIDKey).(uint64)
	return id, ok
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	// Simple manual JSON for error responses to avoid import cycle
	if m, ok := v.(map[string]string); ok {
		msg := m["error"]
		w.Write([]byte(`{"error":"` + msg + `"}`))
	}
}
