package service

import (
	"testing"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// TestValidateAccessToken tests the pure JWT validation logic.
func TestValidateAccessToken(t *testing.T) {
	secret := []byte("test-secret-key-for-unit-tests")
	svc := &AuthService{jwtSecret: secret}

	makeToken := func(claims jwt.MapClaims, secret []byte) string {
		tok, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(secret)
		if err != nil {
			t.Fatalf("failed to create test token: %v", err)
		}
		return tok
	}

	tests := []struct {
		name      string
		token     string
		wantID    uint64
		wantErr   bool
	}{
		{
			name: "valid token returns correct userID",
			token: makeToken(jwt.MapClaims{
				"sub": float64(42),
				"exp": time.Now().Add(time.Hour).Unix(),
			}, secret),
			wantID:  42,
			wantErr: false,
		},
		{
			name: "expired token returns error",
			token: makeToken(jwt.MapClaims{
				"sub": float64(1),
				"exp": time.Now().Add(-time.Hour).Unix(),
			}, secret),
			wantErr: true,
		},
		{
			name:    "completely invalid token returns error",
			token:   "not.a.jwt",
			wantErr: true,
		},
		{
			name: "wrong signing key returns error",
			token: makeToken(jwt.MapClaims{
				"sub": float64(1),
				"exp": time.Now().Add(time.Hour).Unix(),
			}, []byte("wrong-secret")),
			wantErr: true,
		},
		{
			name: "missing sub claim returns error",
			token: makeToken(jwt.MapClaims{
				"exp": time.Now().Add(time.Hour).Unix(),
			}, secret),
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			id, err := svc.ValidateAccessToken(tt.token)
			if tt.wantErr {
				if err == nil {
					t.Errorf("expected error, got nil (id=%d)", id)
				}
				return
			}
			if err != nil {
				t.Errorf("unexpected error: %v", err)
				return
			}
			if id != tt.wantID {
				t.Errorf("got userID=%d, want %d", id, tt.wantID)
			}
		})
	}
}

// TestHashToken tests that hashToken is deterministic and sensitive to input.
func TestHashToken(t *testing.T) {
	h1 := hashToken("token-abc")
	h2 := hashToken("token-abc")
	h3 := hashToken("token-xyz")

	if h1 != h2 {
		t.Error("hashToken is not deterministic")
	}
	if h1 == h3 {
		t.Error("hashToken produced same hash for different inputs")
	}
	if len(h1) != 64 {
		t.Errorf("expected SHA-256 hex (64 chars), got len=%d", len(h1))
	}
}

// TestGenerateRandomToken tests random token generation.
func TestGenerateRandomToken(t *testing.T) {
	t1, err := generateRandomToken(32)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(t1) != 64 { // 32 bytes → 64 hex chars
		t.Errorf("expected 64-char hex string, got len=%d", len(t1))
	}

	t2, err := generateRandomToken(32)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if t1 == t2 {
		t.Error("generateRandomToken produced identical tokens on consecutive calls")
	}
}
