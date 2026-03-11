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
	if req.TargetLanguage == "" {
		req.TargetLanguage = "ko"
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

	// ── Step 1: 음성 전사 ───────────────────────────────────────────────────
	start := time.Now()
	result, transcribeUsage, err := h.llm.Transcribe(r.Context(), req)
	transcribeDuration := time.Since(start).Milliseconds()

	if err != nil {
		log.Printf("Transcribe error (lang=%s): %v", req.Language, err)
		h.usage.LogAsync(nil, "transcribe", req.Language, transcribeUsage, transcribeDuration, "", err.Error())
		writeError(w, http.StatusInternalServerError, "transcription failed: "+err.Error())
		return
	}
	h.usage.LogAsync(nil, "transcribe", req.Language, transcribeUsage, transcribeDuration, result.Script, "")

	// ── Step 2: 발음기호 + 번역 어노테이션 ────────────────────────────────────
	sentences := make([]string, len(result.SyncItems))
	for i, item := range result.SyncItems {
		sentences[i] = item.Sentence
	}

	annotStart := time.Now()
	annotations, annotUsage, annotErr := h.llm.AnnotateTranscription(r.Context(), sentences, req.Language, req.TargetLanguage)
	annotDuration := time.Since(annotStart).Milliseconds()

	if annotErr != nil {
		// 어노테이션 실패는 치명적이지 않음 — 전사 결과만 반환
		log.Printf("AnnotateTranscription error (lang=%s→%s): %v", req.Language, req.TargetLanguage, annotErr)
		h.usage.LogAsync(nil, "annotate", req.Language, annotUsage, annotDuration, "", annotErr.Error())
	} else {
		h.usage.LogAsync(nil, "annotate", req.Language, annotUsage, annotDuration, "", "")
		// 어노테이션 결과를 SyncItem에 병합
		for i := range result.SyncItems {
			if i < len(annotations) {
				result.SyncItems[i].Phonetics = annotations[i].Phonetics
				result.SyncItems[i].Translation = annotations[i].Translation
			}
		}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
