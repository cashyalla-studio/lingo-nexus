package handler

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/internal/service"
)

type TranscribeHandler struct {
	llm *service.LLMService
}

func NewTranscribeHandler(llm *service.LLMService) *TranscribeHandler {
	return &TranscribeHandler{llm: llm}
}

// Transcribe godoc
// POST /api/v1/sync/transcribe
// Content-Type: application/json
//
// Body: TranscribeRequest (audio_base64, language, duration_ms)
// Response: TranscribeResponse (script, sync_items)
func (h *TranscribeHandler) Transcribe(w http.ResponseWriter, r *http.Request) {
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

	result, err := h.llm.Transcribe(r.Context(), req)
	if err != nil {
		log.Printf("Transcribe error (lang=%s): %v", req.Language, err)
		writeError(w, http.StatusInternalServerError, "transcription failed: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
