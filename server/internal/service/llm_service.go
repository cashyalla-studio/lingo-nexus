package service

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/liel/lingo-nexus-server/internal/model"
)

const (
	// Qwen: 중국어 성조 평가 전용 (중국어 오디오 이해 최강)
	qwenEndpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions"
	qwenModel    = "qwen-omni-turbo" // 오디오 입력 지원 + 중국어 특화

	// Gemini: 중국어 외 언어 발음 평가 (다국어 균형)
	geminiEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent"
)

// LLMService는 언어에 따라 Qwen 또는 Gemini를 선택해 발음 평가를 수행합니다.
type LLMService struct {
	QwenAPIKey   string
	GeminiAPIKey string
	httpClient   *http.Client
}

func NewLLMService(qwenKey, geminiKey string) *LLMService {
	return &LLMService{
		QwenAPIKey:   qwenKey,
		GeminiAPIKey: geminiKey,
		httpClient:   &http.Client{Timeout: 30 * time.Second},
	}
}

// EvaluateTone은 언어 코드에 따라 적합한 모델을 선택해 성조/발음을 평가합니다.
// language == "zh" → Qwen (중국어 성조 최적화)
// 그 외           → Gemini 2.5 Flash Lite (다국어 균형)
func (s *LLMService) EvaluateTone(ctx context.Context, req model.ToneEvalRequest) (model.ToneEvalResponse, error) {
	if req.Language == "zh" {
		return s.evaluateWithQwen(ctx, req)
	}
	return s.evaluateWithGemini(ctx, req)
}

// ── Qwen ─────────────────────────────────────────────────────────────────────

func (s *LLMService) evaluateWithQwen(ctx context.Context, req model.ToneEvalRequest) (model.ToneEvalResponse, error) {
	prompt := buildTonePrompt(req)

	body := map[string]any{
		"model": qwenModel,
		"messages": []map[string]any{
			{
				"role": "user",
				"content": []map[string]any{
					{
						"type": "input_audio",
						"input_audio": map[string]string{
							"data":   req.AudioBase64,
							"format": "wav",
						},
					},
					{
						"type": "text",
						"text": prompt,
					},
				},
			},
		},
	}

	respBody, err := s.doPost(ctx, qwenEndpoint, "Bearer "+s.QwenAPIKey, body)
	if err != nil {
		return model.ToneEvalResponse{}, fmt.Errorf("qwen request: %w", err)
	}

	return parseOpenAICompatibleResponse(respBody)
}

// ── Gemini ────────────────────────────────────────────────────────────────────

func (s *LLMService) evaluateWithGemini(ctx context.Context, req model.ToneEvalRequest) (model.ToneEvalResponse, error) {
	prompt := buildTonePrompt(req)
	url := geminiEndpoint + "?key=" + s.GeminiAPIKey

	body := map[string]any{
		"contents": []map[string]any{
			{
				"parts": []map[string]any{
					{
						"inline_data": map[string]string{
							"mime_type": "audio/wav",
							"data":      req.AudioBase64,
						},
					},
					{"text": prompt},
				},
			},
		},
	}

	respBody, err := s.doPost(ctx, url, "", body)
	if err != nil {
		return model.ToneEvalResponse{}, fmt.Errorf("gemini request: %w", err)
	}

	return parseGeminiResponse(respBody)
}

// ── 음성 전사 (Transcription) ──────────────────────────────────────────────────

// Transcribe는 언어에 따라 Qwen(zh) 또는 Gemini(그 외)로 음성을 전사합니다.
// 타임스탬프는 문장 길이 비례로 계산합니다.
func (s *LLMService) Transcribe(ctx context.Context, req model.TranscribeRequest) (model.TranscribeResponse, error) {
	var sentences []string
	var err error

	if req.Language == "zh" {
		sentences, err = s.transcribeWithQwen(ctx, req.AudioBase64)
	} else {
		sentences, err = s.transcribeWithGemini(ctx, req.AudioBase64, req.Language)
	}
	if err != nil {
		return model.TranscribeResponse{}, err
	}

	return buildTranscribeResponse(sentences, req.DurationMs), nil
}

func (s *LLMService) transcribeWithQwen(ctx context.Context, audioBase64 string) ([]string, error) {
	prompt := `You are a Chinese (Mandarin) speech transcription assistant.
Listen to the audio and transcribe ALL spoken content.

Rules:
1. Use simplified Chinese characters
2. Split into natural sentences at pauses or topic boundaries
3. Keep each sentence to 1-3 clauses max
4. Do NOT translate — transcribe exactly what is said

Respond ONLY in this exact JSON format (no markdown):
{"sentences": ["第一句。", "第二句。"]}`

	body := map[string]any{
		"model": qwenModel,
		"messages": []map[string]any{
			{
				"role": "user",
				"content": []map[string]any{
					{
						"type": "input_audio",
						"input_audio": map[string]string{
							"data":   audioBase64,
							"format": "wav",
						},
					},
					{"type": "text", "text": prompt},
				},
			},
		},
	}

	respBody, err := s.doPost(ctx, qwenEndpoint, "Bearer "+s.QwenAPIKey, body)
	if err != nil {
		return nil, fmt.Errorf("qwen transcribe: %w", err)
	}
	return parseTranscribeSentences(respBody, "openai")
}

func (s *LLMService) transcribeWithGemini(ctx context.Context, audioBase64 string, language string) ([]string, error) {
	langNames := map[string]string{
		"en": "English", "ja": "Japanese", "ko": "Korean",
		"es": "Spanish", "de": "German", "fr": "French",
		"pt": "Portuguese", "ar": "Arabic",
	}
	langName, ok := langNames[language]
	if !ok {
		langName = "the spoken language"
	}

	prompt := fmt.Sprintf(`You are a speech transcription assistant.
Listen to the audio and transcribe ALL spoken content in %s.

Rules:
1. Transcribe accurately in the original language (do NOT translate)
2. Split into natural sentences at pauses or topic boundaries
3. Keep each sentence to 1-3 clauses max

Respond ONLY in this exact JSON format (no markdown):
{"sentences": ["First sentence.", "Second sentence."]}`, langName)

	url := geminiEndpoint + "?key=" + s.GeminiAPIKey
	body := map[string]any{
		"contents": []map[string]any{
			{
				"parts": []map[string]any{
					{
						"inline_data": map[string]string{
							"mime_type": "audio/wav",
							"data":      audioBase64,
						},
					},
					{"text": prompt},
				},
			},
		},
	}

	respBody, err := s.doPost(ctx, url, "", body)
	if err != nil {
		return nil, fmt.Errorf("gemini transcribe: %w", err)
	}
	return parseTranscribeSentences(respBody, "gemini")
}

// parseTranscribeSentences는 LLM 응답에서 {"sentences": [...]} JSON을 추출합니다.
func parseTranscribeSentences(body []byte, apiType string) ([]string, error) {
	var content string

	if apiType == "openai" {
		var raw struct {
			Choices []struct {
				Message struct {
					Content string `json:"content"`
				} `json:"message"`
			} `json:"choices"`
		}
		if err := json.Unmarshal(body, &raw); err != nil {
			return nil, fmt.Errorf("parse qwen response: %w", err)
		}
		if len(raw.Choices) == 0 {
			return nil, fmt.Errorf("empty choices from qwen")
		}
		content = raw.Choices[0].Message.Content
	} else {
		var raw struct {
			Candidates []struct {
				Content struct {
					Parts []struct {
						Text string `json:"text"`
					} `json:"parts"`
				} `json:"content"`
			} `json:"candidates"`
		}
		if err := json.Unmarshal(body, &raw); err != nil {
			return nil, fmt.Errorf("parse gemini response: %w", err)
		}
		if len(raw.Candidates) == 0 || len(raw.Candidates[0].Content.Parts) == 0 {
			return nil, fmt.Errorf("empty candidates from gemini")
		}
		content = raw.Candidates[0].Content.Parts[0].Text
	}

	var result struct {
		Sentences []string `json:"sentences"`
	}
	if err := json.Unmarshal([]byte(content), &result); err != nil {
		return nil, fmt.Errorf("parse sentences json (%q): %w", content, err)
	}
	if len(result.Sentences) == 0 {
		return nil, fmt.Errorf("no sentences in response")
	}
	return result.Sentences, nil
}

// buildTranscribeResponse는 문장 목록에서 길이 비례 타임스탬프를 계산합니다.
func buildTranscribeResponse(sentences []string, durationMs int64) model.TranscribeResponse {
	script := ""
	for i, s := range sentences {
		script += s
		if i < len(sentences)-1 {
			script += " "
		}
	}

	totalChars := 0
	for _, s := range sentences {
		totalChars += len([]rune(s))
	}

	syncItems := make([]model.TranscribeSyncItem, 0, len(sentences))
	currentMs := int64(0)
	for _, s := range sentences {
		chars := int64(len([]rune(s)))
		var segDuration int64
		if totalChars > 0 {
			segDuration = durationMs * chars / int64(totalChars)
		} else {
			segDuration = durationMs / int64(len(sentences))
		}
		syncItems = append(syncItems, model.TranscribeSyncItem{
			StartMs:  currentMs,
			EndMs:    currentMs + segDuration,
			Sentence: s,
		})
		currentMs += segDuration
	}

	return model.TranscribeResponse{
		Script:    script,
		SyncItems: syncItems,
	}
}

// ── 텍스트 AI (Grammar / Vocabulary / Chat) ───────────────────────────────────

// AskGrammar uses Gemini to explain the grammar of a sentence.
func (s *LLMService) AskGrammar(ctx context.Context, sentence, uiLang string) (string, error) {
	langInstructions := map[string]string{
		"ko": "Use Korean for the explanation.",
		"ja": "Use Japanese for the explanation.",
		"zh": "Use Simplified Chinese for the explanation.",
		"en": "Use English for the explanation.",
		"de": "Use German for the explanation.",
		"es": "Use Spanish for the explanation.",
		"pt": "Use Portuguese for the explanation.",
		"fr": "Use French for the explanation.",
		"ar": "Use Arabic for the explanation.",
		"he": "Use Hebrew for the explanation.",
	}
	langInstr, ok := langInstructions[uiLang]
	if !ok {
		langInstr = "Use Korean for the explanation."
	}

	prompt := fmt.Sprintf(`You are a professional language tutor. Explain the grammar of the following sentence and provide 2 examples. %s

Sentence: "%s"`, langInstr, sentence)

	return s.askGeminiText(ctx, prompt)
}

// AskVocabulary uses Gemini to explain a word in context.
func (s *LLMService) AskVocabulary(ctx context.Context, word, contextSentence, uiLang string) (string, error) {
	langInstructions := map[string]string{
		"ko": "Use Korean for the explanation.", "ja": "Use Japanese.", "zh": "Use Simplified Chinese.",
		"en": "Use English.", "de": "Use German.", "es": "Use Spanish.",
		"pt": "Use Portuguese.", "fr": "Use French.", "ar": "Use Arabic.", "he": "Use Hebrew.",
	}
	langInstr := langInstructions[uiLang]
	if langInstr == "" {
		langInstr = "Use Korean for the explanation."
	}

	prompt := fmt.Sprintf(`You are a professional language tutor. For the word or phrase "%s" used in the sentence: "%s"

Provide:
1. **Meaning**: Primary meaning in this context
2. **Part of speech**
3. **Examples**: 2 example sentences
4. **Usage notes**: Nuance or common mistakes

%s Keep the response concise and practical.`, word, contextSentence, langInstr)

	return s.askGeminiText(ctx, prompt)
}

// Chat uses Gemini for multi-turn conversation.
func (s *LLMService) Chat(ctx context.Context, messages []model.AIChatMessage, systemPrompt string) (string, error) {
	contents := make([]map[string]any, 0, len(messages)+1)

	if systemPrompt != "" {
		contents = append(contents,
			map[string]any{"role": "user", "parts": []map[string]any{{"text": systemPrompt}}},
			map[string]any{"role": "model", "parts": []map[string]any{{"text": "Understood! I'm ready to help."}}},
		)
	}

	for _, m := range messages {
		role := m.Role
		if role == "assistant" {
			role = "model"
		}
		contents = append(contents, map[string]any{
			"role":  role,
			"parts": []map[string]any{{"text": m.Content}},
		})
	}

	url := geminiEndpoint + "?key=" + s.GeminiAPIKey
	body := map[string]any{"contents": contents}

	respBody, err := s.doPost(ctx, url, "", body)
	if err != nil {
		return "", fmt.Errorf("gemini chat: %w", err)
	}

	var raw struct {
		Candidates []struct {
			Content struct {
				Parts []struct {
					Text string `json:"text"`
				} `json:"parts"`
			} `json:"content"`
		} `json:"candidates"`
	}
	if err := json.Unmarshal(respBody, &raw); err != nil {
		return "", fmt.Errorf("parse chat response: %w", err)
	}
	if len(raw.Candidates) == 0 || len(raw.Candidates[0].Content.Parts) == 0 {
		return "", fmt.Errorf("empty chat response")
	}
	return raw.Candidates[0].Content.Parts[0].Text, nil
}

func (s *LLMService) askGeminiText(ctx context.Context, prompt string) (string, error) {
	url := geminiEndpoint + "?key=" + s.GeminiAPIKey
	body := map[string]any{
		"contents": []map[string]any{
			{"parts": []map[string]any{{"text": prompt}}},
		},
	}

	respBody, err := s.doPost(ctx, url, "", body)
	if err != nil {
		return "", fmt.Errorf("gemini text: %w", err)
	}

	var raw struct {
		Candidates []struct {
			Content struct {
				Parts []struct {
					Text string `json:"text"`
				} `json:"parts"`
			} `json:"content"`
		} `json:"candidates"`
	}
	if err := json.Unmarshal(respBody, &raw); err != nil {
		return "", fmt.Errorf("parse gemini text: %w", err)
	}
	if len(raw.Candidates) == 0 || len(raw.Candidates[0].Content.Parts) == 0 {
		return "", fmt.Errorf("empty gemini response")
	}
	return raw.Candidates[0].Content.Parts[0].Text, nil
}

// ── 공통 유틸 ─────────────────────────────────────────────────────────────────

func buildTonePrompt(req model.ToneEvalRequest) string {
	toneDesc := map[int]string{
		1: "1st tone (mā) — high-level, stays flat and high",
		2: "2nd tone (má) — rising, low to high",
		3: "3rd tone (mǎ) — dipping, falls then rises (or stays low in connected speech)",
		4: "4th tone (mà) — falling, sharp drop from high to low",
		0: "neutral tone — short and light, no fixed pitch",
	}
	desc, ok := toneDesc[req.Tone]
	if !ok {
		desc = fmt.Sprintf("tone %d", req.Tone)
	}

	return fmt.Sprintf(`You are a Chinese pronunciation evaluator for Korean learners.
The speaker is attempting to pronounce "%s" (%s). Target: %s.

Analyze ONLY the tonal contour of the audio.
Respond ONLY in this exact JSON format (no markdown):
{
  "correct": <true|false>,
  "detected_pattern": "<brief description of actual pitch movement>",
  "score": <0.0 to 1.0>,
  "feedback": "<1-2 sentences in Korean explaining what to fix>"
}`, req.Word, req.Pinyin, desc)
}

func (s *LLMService) doPost(ctx context.Context, url, authHeader string, body any) ([]byte, error) {
	b, err := json.Marshal(body)
	if err != nil {
		return nil, err
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, url, bytes.NewReader(b))
	if err != nil {
		return nil, err
	}
	httpReq.Header.Set("Content-Type", "application/json")
	if authHeader != "" {
		httpReq.Header.Set("Authorization", authHeader)
	}

	resp, err := s.httpClient.Do(httpReq)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(respBody))
	}
	return respBody, nil
}

// parseOpenAICompatibleResponse는 Qwen (OpenAI 호환) 응답에서 JSON 문자열을 추출합니다.
func parseOpenAICompatibleResponse(body []byte) (model.ToneEvalResponse, error) {
	var raw struct {
		Choices []struct {
			Message struct {
				Content string `json:"content"`
			} `json:"message"`
		} `json:"choices"`
	}
	if err := json.Unmarshal(body, &raw); err != nil {
		return model.ToneEvalResponse{}, fmt.Errorf("parse openai response: %w", err)
	}
	if len(raw.Choices) == 0 {
		return model.ToneEvalResponse{}, fmt.Errorf("empty choices")
	}
	return parseToneJSON(raw.Choices[0].Message.Content)
}

// parseGeminiResponse는 Gemini 응답에서 JSON 문자열을 추출합니다.
func parseGeminiResponse(body []byte) (model.ToneEvalResponse, error) {
	var raw struct {
		Candidates []struct {
			Content struct {
				Parts []struct {
					Text string `json:"text"`
				} `json:"parts"`
			} `json:"content"`
		} `json:"candidates"`
	}
	if err := json.Unmarshal(body, &raw); err != nil {
		return model.ToneEvalResponse{}, fmt.Errorf("parse gemini response: %w", err)
	}
	if len(raw.Candidates) == 0 || len(raw.Candidates[0].Content.Parts) == 0 {
		return model.ToneEvalResponse{}, fmt.Errorf("empty candidates")
	}
	return parseToneJSON(raw.Candidates[0].Content.Parts[0].Text)
}

// parseToneJSON은 LLM이 반환한 JSON 문자열을 ToneEvalResponse로 파싱합니다.
func parseToneJSON(content string) (model.ToneEvalResponse, error) {
	var result model.ToneEvalResponse
	if err := json.Unmarshal([]byte(content), &result); err != nil {
		return model.ToneEvalResponse{}, fmt.Errorf("parse tone json (%q): %w", content, err)
	}
	return result, nil
}
