package handler

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	// appMiddleware "github.com/liel/lingo-nexus-server/internal/middleware" // TODO(testing): re-enable
	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/internal/service"
)

type ToneHandler struct {
	llm    service.LLMServiceInterface
	credit service.CreditServiceInterface
	usage  service.UsageLogServiceInterface
}

func NewToneHandler(llm service.LLMServiceInterface, credit service.CreditServiceInterface, usage service.UsageLogServiceInterface) *ToneHandler {
	return &ToneHandler{llm: llm, credit: credit, usage: usage}
}

// EvaluateTone godoc
// POST /api/v1/tone/evaluate
func (h *ToneHandler) EvaluateTone(w http.ResponseWriter, r *http.Request) {
	// TODO(testing): re-enable auth + credit checks before production
	// userID, ok := appMiddleware.GetUserID(r.Context())
	// if !ok {
	// 	writeError(w, http.StatusUnauthorized, "unauthorized")
	// 	return
	// }

	var req model.ToneEvalRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body: "+err.Error())
		return
	}
	if req.AudioBase64 == "" {
		writeError(w, http.StatusBadRequest, "audio_base64 is required")
		return
	}
	if req.Word == "" || req.Pinyin == "" {
		writeError(w, http.StatusBadRequest, "word and pinyin are required")
		return
	}
	if req.DurationMs <= 0 {
		req.DurationMs = 3000 // default 3s for tone evaluation
	}

	// TODO(testing): re-enable credit check before production
	// if err := h.credit.CheckAndDeductAudio(r.Context(), userID, req.DurationMs); err != nil {
	// 	writeError(w, http.StatusPaymentRequired, err.Error())
	// 	return
	// }

	start := time.Now()
	result, llmUsage, err := h.llm.EvaluateTone(r.Context(), req)
	durationMs := time.Since(start).Milliseconds()

	errStr := ""
	if err != nil {
		errStr = err.Error()
		log.Printf("EvaluateTone error (lang=%s): %v", req.Language, err)
		h.usage.LogAsync(nil, "tone_evaluate", req.Language, llmUsage, durationMs, "", errStr)
		writeError(w, http.StatusInternalServerError, "evaluation failed: "+errStr)
		return
	}

	preview := fmt.Sprintf("correct=%v score=%.2f detected=%s", result.Correct, result.Score, result.DetectedPattern)
	h.usage.LogAsync(nil, "tone_evaluate", req.Language, llmUsage, durationMs, preview, "")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(map[string]string{"error": msg})
}
