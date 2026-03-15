package handler

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/internal/service"
)

// AIHandler handles text-based AI requests (grammar, vocabulary, chat).
// These endpoints are auth-protected but do NOT deduct audio credits.
type AIHandler struct {
	llm   service.LLMServiceInterface
	usage service.UsageLogServiceInterface
}

func NewAIHandler(llm service.LLMServiceInterface, usage service.UsageLogServiceInterface) *AIHandler {
	return &AIHandler{llm: llm, usage: usage}
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

	start := time.Now()
	reply, llmUsage, err := h.llm.AskGrammar(r.Context(), req.Sentence, req.UILanguage)
	durationMs := time.Since(start).Milliseconds()

	if err != nil {
		h.usage.LogAsync(nil, "grammar", req.UILanguage, llmUsage, durationMs, "", err.Error())
		writeError(w, http.StatusInternalServerError, "AI request failed: "+err.Error())
		return
	}
	h.usage.LogAsync(nil, "grammar", req.UILanguage, llmUsage, durationMs, reply, "")

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

	start := time.Now()
	reply, llmUsage, err := h.llm.AskVocabulary(r.Context(), req.Word, req.Context, req.UILanguage)
	durationMs := time.Since(start).Milliseconds()

	if err != nil {
		h.usage.LogAsync(nil, "vocabulary", req.UILanguage, llmUsage, durationMs, "", err.Error())
		writeError(w, http.StatusInternalServerError, "AI request failed: "+err.Error())
		return
	}
	h.usage.LogAsync(nil, "vocabulary", req.UILanguage, llmUsage, durationMs, reply, "")

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

	start := time.Now()
	reply, llmUsage, err := h.llm.Chat(r.Context(), req.Messages, req.SystemPrompt)
	durationMs := time.Since(start).Milliseconds()

	if err != nil {
		h.usage.LogAsync(nil, "chat", "", llmUsage, durationMs, "", err.Error())
		writeError(w, http.StatusInternalServerError, "AI request failed: "+err.Error())
		return
	}
	h.usage.LogAsync(nil, "chat", "", llmUsage, durationMs, reply, "")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(model.TextAIResponse{Reply: reply})
}
