package handler

import (
	"encoding/json"
	"log"
	"net/http"
	"strings"
	"time"
	"unicode"

	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/internal/service"
)

type ShadowingHandler struct {
	llm   service.LLMServiceInterface
	usage service.UsageLogServiceInterface
}

func NewShadowingHandler(llm service.LLMServiceInterface, usage service.UsageLogServiceInterface) *ShadowingHandler {
	return &ShadowingHandler{llm: llm, usage: usage}
}

// Score godoc
// POST /api/v1/shadowing/score
func (h *ShadowingHandler) Score(w http.ResponseWriter, r *http.Request) {
	var req model.ShadowingScoreRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body: "+err.Error())
		return
	}
	if req.AudioBase64 == "" || req.OriginalText == "" {
		writeError(w, http.StatusBadRequest, "audio_base64 and original_text are required")
		return
	}
	if req.Language == "" {
		req.Language = "en"
	}

	// Transcribe the user's shadowing audio (assume max 30s for shadowing clips)
	transcribeReq := model.TranscribeRequest{
		AudioBase64:    req.AudioBase64,
		Language:       req.Language,
		DurationMs:     30000,
		TargetLanguage: "ko",
	}

	start := time.Now()
	result, usage, err := h.llm.Transcribe(r.Context(), transcribeReq)
	durationMs := time.Since(start).Milliseconds()

	errMsg := ""
	if err != nil {
		errMsg = err.Error()
	}
	h.usage.LogAsync(nil, "shadowing_score", req.Language, usage, durationMs, result.Script, errMsg)

	if err != nil {
		log.Printf("ShadowingScore transcribe error (lang=%s): %v", req.Language, err)
		writeError(w, http.StatusInternalServerError, "transcription failed: "+err.Error())
		return
	}

	// Join all transcribed sentences into a single string for comparison
	var transcription string
	if len(result.SyncItems) > 0 {
		parts := make([]string, len(result.SyncItems))
		for i, item := range result.SyncItems {
			parts[i] = item.Sentence
		}
		transcription = strings.Join(parts, " ")
	} else {
		transcription = result.Script
	}

	resp := scoreTranscription(req.OriginalText, transcription)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func scoreTranscription(original, transcription string) model.ShadowingScoreResponse {
	origWords := tokenizeText(original)
	transWords := tokenizeText(transcription)

	transSet := make(map[string]bool, len(transWords))
	for _, w := range transWords {
		transSet[w] = true
	}

	var matched int
	var incorrect []string
	for _, w := range origWords {
		if transSet[w] {
			matched++
		} else {
			incorrect = append(incorrect, w)
		}
	}

	accuracy := 0
	if len(origWords) > 0 {
		accuracy = minInt(100, int(float64(matched)/float64(len(origWords))*100))
	}

	// Length-based fluency: penalise if transcription is much shorter or longer than original
	lenRatio := 1.0
	if len(origWords) > 0 {
		lenRatio = float64(len(transWords)) / float64(len(origWords))
		if lenRatio > 2.0 {
			lenRatio = 2.0
		}
	}
	fluency := minInt(100, int(100-absFloat(1.0-lenRatio)*50))
	intonation := (accuracy + fluency) / 2

	feedback := buildShadowingFeedback(accuracy, incorrect)

	return model.ShadowingScoreResponse{
		Accuracy:       accuracy,
		Intonation:     intonation,
		Fluency:        fluency,
		Transcription:  transcription,
		IncorrectWords: incorrect,
		Feedback:       feedback,
	}
}

// tokenizeText lowercases text, strips punctuation, and splits on whitespace.
func tokenizeText(text string) []string {
	clean := strings.Map(func(r rune) rune {
		if unicode.IsPunct(r) {
			return ' '
		}
		return unicode.ToLower(r)
	}, text)
	parts := strings.Fields(clean)
	result := make([]string, 0, len(parts))
	for _, p := range parts {
		if p != "" {
			result = append(result, p)
		}
	}
	return result
}

func absFloat(f float64) float64 {
	if f < 0 {
		return -f
	}
	return f
}

func buildShadowingFeedback(accuracy int, incorrect []string) string {
	if accuracy >= 90 {
		return "훌륭합니다! 거의 완벽한 발음이에요."
	} else if accuracy >= 70 {
		if len(incorrect) > 0 {
			limit := minInt(3, len(incorrect))
			return "좋습니다! 다음 단어를 더 연습해보세요: " + strings.Join(incorrect[:limit], ", ")
		}
		return "좋습니다! 계속 연습하세요."
	}
	return "계속 연습하면 좋아질 거예요. 천천히 따라 말해보세요."
}

func minInt(a, b int) int {
	if a < b {
		return a
	}
	return b
}
