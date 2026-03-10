package handler

import (
	"encoding/json"
	"log"
	"net/http"

	// appMiddleware "github.com/liel/lingo-nexus-server/internal/middleware" // TODO(testing): re-enable
	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/internal/service"
)

type TranscribeHandler struct {
	llm    *service.LLMService
	credit *service.CreditService
}

func NewTranscribeHandler(llm *service.LLMService, credit *service.CreditService) *TranscribeHandler {
	return &TranscribeHandler{llm: llm, credit: credit}
}

// Transcribe godoc
// POST /api/v1/sync/transcribe (auth required)
func (h *TranscribeHandler) Transcribe(w http.ResponseWriter, r *http.Request) {
	// TODO(testing): re-enable auth + credit checks before production
	// userID, ok := appMiddleware.GetUserID(r.Context())
	// if !ok {
	// 	writeError(w, http.StatusUnauthorized, "unauthorized")
	// 	return
	// }

	var req model.TranscribeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body: "+err.Error())
		return
	}
	if req.AudioBase64 == "" {
		writeError(w, http.StatusBadRequest, "audio_base64 is required")
		return
	}
	if req.Language == "" {
		req.Language = "en"
	}
	if req.DurationMs <= 0 {
		writeError(w, http.StatusBadRequest, "duration_ms must be positive")
		return
	}

	// Enforce max duration
	if req.DurationMs > model.MaxAudioDurationMs {
		writeError(w, http.StatusBadRequest, "audio exceeds maximum duration of 10 minutes")
		return
	}

	// TODO(testing): re-enable credit check before production
	// if err := h.credit.CheckAndDeductAudio(r.Context(), userID, req.DurationMs); err != nil {
	// 	writeError(w, http.StatusPaymentRequired, err.Error())
	// 	return
	// }

	result, err := h.llm.Transcribe(r.Context(), req)
	if err != nil {
		log.Printf("Transcribe error (lang=%s): %v", req.Language, err)
		writeError(w, http.StatusInternalServerError, "transcription failed: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
