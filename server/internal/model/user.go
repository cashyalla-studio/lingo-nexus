package model

import "time"

type User struct {
	ID         uint64    `json:"id"`
	Email      string    `json:"email"`
	Name       string    `json:"name"`
	AvatarURL  string    `json:"avatar_url,omitempty"`
	Provider   string    `json:"provider"`
	ProviderID string    `json:"-"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// AuthRequest is sent by the client after Google/Apple sign-in.
type AuthRequest struct {
	Provider    string `json:"provider"`     // "google" | "apple"
	IDToken     string `json:"id_token"`     // Google ID token or Apple identity token
	AccessToken string `json:"access_token"` // Google access token (optional, for Drive scope)
}

// AuthResponse is returned after successful auth.
type AuthResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	ExpiresIn    int    `json:"expires_in"` // seconds
	User         User   `json:"user"`
}

// RefreshRequest is sent to refresh an access token.
type RefreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

// GoogleTokenInfo is the response from Google's tokeninfo endpoint.
type GoogleTokenInfo struct {
	Sub           string `json:"sub"`
	Email         string `json:"email"`
	EmailVerified string `json:"email_verified"`
	Name          string `json:"name"`
	Picture       string `json:"picture"`
	Error         string `json:"error"`
	ErrorDesc     string `json:"error_description"`
}
