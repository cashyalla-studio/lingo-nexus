package handler

import (
	"encoding/json"
	"net/http"

	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/internal/service"
)

type AuthHandler struct {
	authSvc *service.AuthService
}

func NewAuthHandler(authSvc *service.AuthService) *AuthHandler {
	return &AuthHandler{authSvc: authSvc}
}

// POST /api/v1/auth/login
// Body: {"provider":"google","id_token":"..."}
func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req model.AuthRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if req.Provider == "" || req.IDToken == "" {
		writeError(w, http.StatusBadRequest, "provider and id_token are required")
		return
	}

	var resp *model.AuthResponse
	var err error

	switch req.Provider {
	case "google":
		resp, err = h.authSvc.LoginWithGoogle(r.Context(), req.IDToken)
	default:
		writeError(w, http.StatusBadRequest, "unsupported provider: "+req.Provider)
		return
	}

	if err != nil {
		writeError(w, http.StatusUnauthorized, "authentication failed: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

// POST /api/v1/auth/refresh
// Body: {"refresh_token":"..."}
func (h *AuthHandler) Refresh(w http.ResponseWriter, r *http.Request) {
	var req model.RefreshRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if req.RefreshToken == "" {
		writeError(w, http.StatusBadRequest, "refresh_token is required")
		return
	}

	resp, err := h.authSvc.RefreshAccessToken(r.Context(), req.RefreshToken)
	if err != nil {
		writeError(w, http.StatusUnauthorized, "token refresh failed: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}
