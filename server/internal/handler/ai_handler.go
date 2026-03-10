package handler

import (
	"encoding/json"
	"net/http"

	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/internal/service"
)

// AIHandler handles text-based AI requests (grammar, vocabulary, chat).
// These endpoints are auth-protected but do NOT deduct audio credits.
type AIHandler struct {
	llm *service.LLMService
}

func NewAIHandler(llm *service.LLMService) *AIHandler {
	return &AIHandler{llm: llm}
}

// POST /api/v1/ai/grammar
func (h *AIHandler) Grammar(w http.ResponseWriter, r *http.Request) {
	var req model.AskGrammarRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if req.Sentence == "" {
		writeError(w, http.StatusBadRequest, "sentence is required")
		return
	}
	if req.UILanguage == "" {
		req.UILanguage = "ko"
	}

	reply, err := h.llm.AskGrammar(r.Context(), req.Sentence, req.UILanguage)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "AI request failed: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(model.TextAIResponse{Reply: reply})
}

// POST /api/v1/ai/vocabulary
func (h *AIHandler) Vocabulary(w http.ResponseWriter, r *http.Request) {
	var req model.AskVocabularyRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if req.Word == "" {
		writeError(w, http.StatusBadRequest, "word is required")
		return
	}
	if req.UILanguage == "" {
		req.UILanguage = "ko"
	}

	reply, err := h.llm.AskVocabulary(r.Context(), req.Word, req.Context, req.UILanguage)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "AI request failed: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(model.TextAIResponse{Reply: reply})
}

// POST /api/v1/ai/chat
func (h *AIHandler) Chat(w http.ResponseWriter, r *http.Request) {
	var req model.ChatRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if len(req.Messages) == 0 {
		writeError(w, http.StatusBadRequest, "messages is required")
		return
	}

	reply, err := h.llm.Chat(r.Context(), req.Messages, req.SystemPrompt)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "AI request failed: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(model.TextAIResponse{Reply: reply})
}
