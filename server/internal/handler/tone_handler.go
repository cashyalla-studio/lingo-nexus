package handler

import (
	"encoding/json"
	"log"
	"net/http"

	// appMiddleware "github.com/liel/lingo-nexus-server/internal/middleware" // TODO(testing): re-enable
	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/internal/service"
)

type ToneHandler struct {
	llm    *service.LLMService
	credit *service.CreditService
}

func NewToneHandler(llm *service.LLMService, credit *service.CreditService) *ToneHandler {
	return &ToneHandler{llm: llm, credit: credit}
}

// EvaluateTone godoc
// POST /api/v1/tone/evaluate (auth required)
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

	result, err := h.llm.EvaluateTone(r.Context(), req)
	if err != nil {
		log.Printf("EvaluateTone error (lang=%s): %v", req.Language, err)
		writeError(w, http.StatusInternalServerError, "evaluation failed: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(map[string]string{"error": msg})
}
