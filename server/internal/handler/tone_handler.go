package handler

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/internal/service"
)

type ToneHandler struct {
	llm *service.LLMService
}

func NewToneHandler(llm *service.LLMService) *ToneHandler {
	return &ToneHandler{llm: llm}
}

// EvaluateTone godoc
// POST /api/v1/tone/evaluate
// Content-Type: application/json
//
// Body: ToneEvalRequest (audio_base64, word, pinyin, tone, language)
// Response: ToneEvalResponse (correct, detected_pattern, score, feedback)
func (h *ToneHandler) EvaluateTone(w http.ResponseWriter, r *http.Request) {
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
