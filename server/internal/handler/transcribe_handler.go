package handler

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	// appMiddleware "github.com/liel/lingo-nexus-server/internal/middleware" // TODO(testing): re-enable
	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/internal/service"
)

type TranscribeHandler struct {
	llm    *service.LLMService
	credit *service.CreditService
	usage  *service.UsageLogService
}

func NewTranscribeHandler(llm *service.LLMService, credit *service.CreditService, usage *service.UsageLogService) *TranscribeHandler {
	return &TranscribeHandler{llm: llm, credit: credit, usage: usage}
}

// Transcribe godoc
// POST /api/v1/sync/transcribe
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
	if req.DurationMs > model.MaxAudioDurationMs {
		writeError(w, http.StatusBadRequest, "audio exceeds maximum duration of 10 minutes")
		return
	}

	// TODO(testing): re-enable credit check before production
	// if err := h.credit.CheckAndDeductAudio(r.Context(), userID, req.DurationMs); err != nil {
	// 	writeError(w, http.StatusPaymentRequired, err.Error())
	// 	return
	// }

	start := time.Now()
	result, llmUsage, err := h.llm.Transcribe(r.Context(), req)
	durationMs := time.Since(start).Milliseconds()

	errStr := ""
	if err != nil {
		errStr = err.Error()
		log.Printf("Transcribe error (lang=%s): %v", req.Language, err)
		h.usage.LogAsync(nil, "transcribe", req.Language, llmUsage, durationMs, "", errStr)
		writeError(w, http.StatusInternalServerError, "transcription failed: "+errStr)
		return
	}

	h.usage.LogAsync(nil, "transcribe", req.Language, llmUsage, durationMs, result.Script, "")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
