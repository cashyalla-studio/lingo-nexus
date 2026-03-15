package handler

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/internal/service"
)

type AnnotateHandler struct {
	llm   service.LLMServiceInterface
	usage service.UsageLogServiceInterface
}

func NewAnnotateHandler(llm service.LLMServiceInterface, usage service.UsageLogServiceInterface) *AnnotateHandler {
	return &AnnotateHandler{llm: llm, usage: usage}
}

// Annotate godoc
// POST /api/v1/sync/annotate
// 기기 내장 STT로 전사된 문장 목록에 발음기호 + 번역을 추가합니다.
func (h *AnnotateHandler) Annotate(w http.ResponseWriter, r *http.Request) {
	var req model.AnnotateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body: "+err.Error())
		return
	}
	if len(req.Sentences) == 0 {
		writeError(w, http.StatusBadRequest, "sentences is required and must not be empty")
		return
	}
	if req.Language == "" {
		req.Language = "en"
	}
	if req.TargetLanguage == "" {
		req.TargetLanguage = "ko"
	}

	start := time.Now()
	annotations, usage, err := h.llm.AnnotateTranscription(r.Context(), req.Sentences, req.Language, req.TargetLanguage)
	duration := time.Since(start).Milliseconds()

	if err != nil {
		log.Printf("AnnotateTranscription error (lang=%s→%s): %v", req.Language, req.TargetLanguage, err)
		h.usage.LogAsync(nil, "annotate", req.Language, usage, duration, "", err.Error())
		writeError(w, http.StatusInternalServerError, "annotation failed: "+err.Error())
		return
	}
	h.usage.LogAsync(nil, "annotate", req.Language, usage, duration, "", "")

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(annotations)
}
