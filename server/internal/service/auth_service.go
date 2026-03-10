package service

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/liel/lingo-nexus-server/internal/model"
)

const (
	accessTokenTTL  = 24 * time.Hour
	refreshTokenTTL = 30 * 24 * time.Hour
)

type AuthService struct {
	db         *sql.DB
	jwtSecret  []byte
	httpClient *http.Client
}

func NewAuthService(db *sql.DB) *AuthService {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "dev-secret-change-in-production"
	}
	return &AuthService{
		db:         db,
		jwtSecret:  []byte(secret),
		httpClient: &http.Client{Timeout: 10 * time.Second},
	}
}

// LoginWithGoogle verifies a Google ID token and returns auth tokens.
func (s *AuthService) LoginWithGoogle(ctx context.Context, idToken string) (*model.AuthResponse, error) {
	info, err := s.verifyGoogleToken(ctx, idToken)
	if err != nil {
		return nil, fmt.Errorf("invalid google token: %w", err)
	}
	if info.Error != "" {
		return nil, fmt.Errorf("google token error: %s", info.ErrorDesc)
	}
	if info.Sub == "" || info.Email == "" {
		return nil, fmt.Errorf("google token missing sub or email")
	}

	user, err := s.upsertUser(ctx, model.User{
		Email:      info.Email,
		Name:       info.Name,
		AvatarURL:  info.Picture,
		Provider:   "google",
		ProviderID: info.Sub,
	})
	if err != nil {
		return nil, fmt.Errorf("upsert user: %w", err)
	}

	return s.issueTokens(ctx, user)
}

// RefreshAccessToken exchanges a refresh token for a new access token.
func (s *AuthService) RefreshAccessToken(ctx context.Context, refreshToken string) (*model.AuthResponse, error) {
	hash := hashToken(refreshToken)

	var userID uint64
	var expiresAt time.Time
	err := s.db.QueryRowContext(ctx,
		`SELECT user_id, expires_at FROM refresh_tokens WHERE token_hash = ?`, hash,
	).Scan(&userID, &expiresAt)
	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("invalid refresh token")
	}
	if err != nil {
		return nil, fmt.Errorf("db query: %w", err)
	}
	if time.Now().After(expiresAt) {
		return nil, fmt.Errorf("refresh token expired")
	}

	user, err := s.getUserByID(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("get user: %w", err)
	}

	// Rotate refresh token
	if _, err := s.db.ExecContext(ctx, `DELETE FROM refresh_tokens WHERE token_hash = ?`, hash); err != nil {
		return nil, fmt.Errorf("delete old refresh token: %w", err)
	}

	return s.issueTokens(ctx, user)
}

// ValidateAccessToken parses and validates a JWT access token.
func (s *AuthService) ValidateAccessToken(tokenString string) (uint64, error) {
	token, err := jwt.Parse(tokenString, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}
		return s.jwtSecret, nil
	}, jwt.WithValidMethods([]string{"HS256"}))
	if err != nil {
		return 0, err
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return 0, fmt.Errorf("invalid token claims")
	}

	sub, ok := claims["sub"].(float64)
	if !ok {
		return 0, fmt.Errorf("invalid sub claim")
	}
	return uint64(sub), nil
}

// ── Private helpers ───────────────────────────────────────────────────────────

func (s *AuthService) verifyGoogleToken(ctx context.Context, idToken string) (*model.GoogleTokenInfo, error) {
	url := "https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var info model.GoogleTokenInfo
	if err := json.NewDecoder(resp.Body).Decode(&info); err != nil {
		return nil, err
	}
	return &info, nil
}

func (s *AuthService) upsertUser(ctx context.Context, u model.User) (model.User, error) {
	res, err := s.db.ExecContext(ctx, `
		INSERT INTO users (email, name, avatar_url, provider, provider_id)
		VALUES (?, ?, ?, ?, ?)
		ON DUPLICATE KEY UPDATE
			name       = VALUES(name),
			avatar_url = VALUES(avatar_url),
			updated_at = CURRENT_TIMESTAMP
	`, u.Email, u.Name, u.AvatarURL, u.Provider, u.ProviderID)
	if err != nil {
		return model.User{}, err
	}

	var userID uint64
	lastID, _ := res.LastInsertId()
	if lastID == 0 {
		// Row already existed — fetch it
		err = s.db.QueryRowContext(ctx,
			`SELECT id FROM users WHERE provider = ? AND provider_id = ?`,
			u.Provider, u.ProviderID,
		).Scan(&userID)
		if err != nil {
			return model.User{}, err
		}
	} else {
		userID = uint64(lastID)
		// Create credit account for new user
		if _, err := s.db.ExecContext(ctx,
			`INSERT IGNORE INTO credit_accounts (user_id) VALUES (?)`, userID); err != nil {
			return model.User{}, err
		}
	}

	return s.getUserByID(ctx, userID)
}

func (s *AuthService) getUserByID(ctx context.Context, id uint64) (model.User, error) {
	var u model.User
	var avatarURL sql.NullString
	err := s.db.QueryRowContext(ctx,
		`SELECT id, email, name, avatar_url, provider, created_at, updated_at FROM users WHERE id = ?`, id,
	).Scan(&u.ID, &u.Email, &u.Name, &avatarURL, &u.Provider, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		return model.User{}, err
	}
	u.AvatarURL = avatarURL.String
	return u, nil
}

func (s *AuthService) issueTokens(ctx context.Context, user model.User) (*model.AuthResponse, error) {
	// Access token (JWT)
	now := time.Now()
	claims := jwt.MapClaims{
		"sub": user.ID,
		"iat": now.Unix(),
		"exp": now.Add(accessTokenTTL).Unix(),
	}
	accessToken, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(s.jwtSecret)
	if err != nil {
		return nil, fmt.Errorf("sign access token: %w", err)
	}

	// Refresh token (random bytes stored as hash)
	rawRefresh, err := generateRandomToken(32)
	if err != nil {
		return nil, fmt.Errorf("generate refresh token: %w", err)
	}
	hash := hashToken(rawRefresh)
	expiresAt := now.Add(refreshTokenTTL)

	if _, err := s.db.ExecContext(ctx,
		`INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)`,
		user.ID, hash, expiresAt,
	); err != nil {
		return nil, fmt.Errorf("store refresh token: %w", err)
	}

	// Clean up old tokens for this user (keep last 5)
	s.db.ExecContext(ctx, `
		DELETE FROM refresh_tokens WHERE user_id = ? AND id NOT IN (
			SELECT id FROM (SELECT id FROM refresh_tokens WHERE user_id = ? ORDER BY created_at DESC LIMIT 5) t
		)`, user.ID, user.ID)

	return &model.AuthResponse{
		AccessToken:  accessToken,
		RefreshToken: rawRefresh,
		ExpiresIn:    int(accessTokenTTL.Seconds()),
		User:         user,
	}, nil
}

func generateRandomToken(n int) (string, error) {
	b := make([]byte, n)
	if _, err := rand.Read(b); err != nil {
		return "", err
	}
	return hex.EncodeToString(b), nil
}

func hashToken(token string) string {
	h := sha256.Sum256([]byte(token))
	return hex.EncodeToString(h[:])
}
