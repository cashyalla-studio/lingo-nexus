package handler

import (
	"database/sql"
	"encoding/json"
	"net/http"

	appMiddleware "github.com/liel/lingo-nexus-server/internal/middleware"
)

type UserHandler struct {
	db *sql.DB
}

func NewUserHandler(db *sql.DB) *UserHandler {
	return &UserHandler{db: db}
}

// GET /api/v1/user/me
func (h *UserHandler) GetMe(w http.ResponseWriter, r *http.Request) {
	userID, ok := appMiddleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	var u struct {
		ID        uint64 `json:"id"`
		Email     string `json:"email"`
		Name      string `json:"name"`
		AvatarURL string `json:"avatar_url,omitempty"`
		Provider  string `json:"provider"`
	}
	var avatarURL sql.NullString
	err := h.db.QueryRowContext(r.Context(),
		`SELECT id, email, name, avatar_url, provider FROM users WHERE id = ?`, userID,
	).Scan(&u.ID, &u.Email, &u.Name, &avatarURL, &u.Provider)
	if err == sql.ErrNoRows {
		writeError(w, http.StatusNotFound, "user not found")
		return
	}
	if err != nil {
		writeError(w, http.StatusInternalServerError, "db error")
		return
	}
	u.AvatarURL = avatarURL.String

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(u)
}
