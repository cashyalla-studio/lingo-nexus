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
	// Qwen: 중국어 오디오 전용 — DashScope 네이티브 멀티모달 API 사용
	// (OpenAI 호환 엔드포인트는 오디오 입력 미지원)
	qwenNativeEndpoint = "https://dashscope-intl.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation"
	qwenModel          = "qwen3-omni-flash"

	// Gemini: 중국어 외 언어 발음 평가 (다국어 균형)
	geminiEndpoint  = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent"
	geminiModelName = "gemini-2.5-flash-lite"
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

// ── 성조 평가 ─────────────────────────────────────────────────────────────────

func (s *LLMService) EvaluateTone(ctx context.Context, req model.ToneEvalRequest) (model.ToneEvalResponse, model.LLMUsage, error) {
	if isChineseLanguage(req.Language) {
		return s.evaluateWithQwen(ctx, req)
	}
	return s.evaluateWithGemini(ctx, req)
}

func (s *LLMService) evaluateWithQwen(ctx context.Context, req model.ToneEvalRequest) (model.ToneEvalResponse, model.LLMUsage, error) {
	baseUsage := model.LLMUsage{Provider: "qwen", Model: qwenModel}
	prompt := buildTonePrompt(req)

	text, usage, err := s.callQwenNative(ctx, req.AudioBase64, prompt)
	if err != nil {
		return model.ToneEvalResponse{}, baseUsage, fmt.Errorf("qwen request: %w", err)
	}
	result, err := parseToneJSON(text)
	return result, usage, err
}

func (s *LLMService) evaluateWithGemini(ctx context.Context, req model.ToneEvalRequest) (model.ToneEvalResponse, model.LLMUsage, error) {
	baseUsage := model.LLMUsage{Provider: "gemini", Model: geminiModelName}
	prompt := buildTonePrompt(req)
	url := geminiEndpoint + "?key=" + s.GeminiAPIKey
	body := map[string]any{
		"contents": []map[string]any{
			{
				"parts": []map[string]any{
					{"inline_data": map[string]string{"mime_type": "audio/wav", "data": req.AudioBase64}},
					{"text": prompt},
				},
			},
		},
	}

	respBody, err := s.doPost(ctx, url, "", body)
	if err != nil {
		return model.ToneEvalResponse{}, baseUsage, fmt.Errorf("gemini request: %w", err)
	}

	usage := extractGeminiUsage(respBody)
	result, err := parseGeminiResponse(respBody)
	return result, usage, err
}

// ── 음성 전사 ─────────────────────────────────────────────────────────────────

func (s *LLMService) Transcribe(ctx context.Context, req model.TranscribeRequest) (model.TranscribeResponse, model.LLMUsage, error) {
	var sentences []string
	var usage model.LLMUsage
	var err error

	if isChineseLanguage(req.Language) {
		sentences, usage, err = s.transcribeWithQwen(ctx, req.AudioBase64)
	} else {
		sentences, usage, err = s.transcribeWithGemini(ctx, req.AudioBase64, req.Language)
	}
	if err != nil {
		return model.TranscribeResponse{}, usage, err
	}

	return buildTranscribeResponse(sentences, req.DurationMs), usage, nil
}

func (s *LLMService) transcribeWithQwen(ctx context.Context, audioBase64 string) ([]string, model.LLMUsage, error) {
	prompt := `You are a Chinese (Mandarin) speech transcription assistant.
Listen to the audio and transcribe ALL spoken content.

Rules:
1. Use simplified Chinese characters
2. Split into natural sentences at pauses or topic boundaries
3. Keep each sentence to 1-3 clauses max
4. Do NOT translate — transcribe exactly what is said

Respond ONLY in this exact JSON format (no markdown):
{"sentences": ["第一句。", "第二句。"]}`

	text, usage, err := s.callQwenNative(ctx, audioBase64, prompt)
	if err != nil {
		return nil, usage, fmt.Errorf("qwen transcribe: %w", err)
	}

	sentences, err := parseTranscribeSentencesFromText(text)
	return sentences, usage, err
}

func (s *LLMService) transcribeWithGemini(ctx context.Context, audioBase64 string, language string) ([]string, model.LLMUsage, error) {
	baseUsage := model.LLMUsage{Provider: "gemini", Model: geminiModelName}
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
					{"inline_data": map[string]string{"mime_type": "audio/wav", "data": audioBase64}},
					{"text": prompt},
				},
			},
		},
	}

	respBody, err := s.doPost(ctx, url, "", body)
	if err != nil {
		return nil, baseUsage, fmt.Errorf("gemini transcribe: %w", err)
	}

	usage := extractGeminiUsage(respBody)
	sentences, err := parseTranscribeSentences(respBody, "gemini")
	return sentences, usage, err
}

// ── 전사 어노테이션 (발음기호 + 번역) ──────────────────────────────────────────

// AnnotateTranscription은 전사된 문장 목록에 발음기호와 번역을 추가합니다.
// 모든 문장을 단일 Gemini 호출로 처리하여 비용을 최소화합니다.
func (s *LLMService) AnnotateTranscription(
	ctx context.Context,
	sentences []string,
	sourceLang, targetLang string,
) ([]model.AnnotationItem, model.LLMUsage, error) {
	baseUsage := model.LLMUsage{Provider: "gemini", Model: geminiModelName}
	if len(sentences) == 0 {
		return nil, baseUsage, nil
	}

	// 발음기호 시스템 결정
	phoneticSystem := map[string]string{
		"zh": "Pinyin (with tone marks, e.g. nǐ hǎo)",
		"ja": "Hiragana furigana + Romaji (e.g. 東京(とうきょう) / Tōkyō)",
		"ko": "Revised Romanization (e.g. annyeonghaseyo)",
		"ar": "Arabic transliteration (Buckwalter or standard)",
		"he": "Hebrew transliteration",
	}
	phonetic, ok := phoneticSystem[sourceLang]
	if !ok {
		phonetic = "IPA or standard romanization"
	}

	// 번역 대상 언어명
	targetLangName := map[string]string{
		"ko": "Korean", "en": "English", "ja": "Japanese",
		"zh": "Simplified Chinese", "de": "German", "es": "Spanish",
		"fr": "French", "pt": "Portuguese", "ar": "Arabic", "he": "Hebrew",
	}
	targetName, ok := targetLangName[targetLang]
	if !ok {
		targetName = "Korean"
	}

	// 번호 매긴 문장 목록
	numberedSentences := ""
	for i, s := range sentences {
		numberedSentences += fmt.Sprintf("%d. %s\n", i+1, s)
	}

	prompt := fmt.Sprintf(`You are a language annotation assistant.
For each numbered sentence below (source language: %s), provide:
1. Phonetic transcription using %s
2. Natural translation in %s

Sentences:
%s
Respond ONLY in this exact JSON format (no markdown, no explanation):
{"annotations":[{"phonetics":"...","translation":"..."},{"phonetics":"...","translation":"..."}]}

The annotations array MUST have exactly %d items in the same order as the input sentences.`,
		sourceLang, phonetic, targetName, numberedSentences, len(sentences))

	text, usage, err := s.askGeminiText(ctx, prompt)
	if err != nil {
		return nil, usage, fmt.Errorf("annotate transcription: %w", err)
	}

	var result struct {
		Annotations []model.AnnotationItem `json:"annotations"`
	}
	if err := json.Unmarshal([]byte(text), &result); err != nil {
		return nil, usage, fmt.Errorf("parse annotation json (%q): %w", text, err)
	}
	return result.Annotations, usage, nil
}

// ── 텍스트 AI (Grammar / Vocabulary / Chat) ───────────────────────────────────

func (s *LLMService) AskGrammar(ctx context.Context, sentence, uiLang string) (string, model.LLMUsage, error) {
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

func (s *LLMService) AskVocabulary(ctx context.Context, word, contextSentence, uiLang string) (string, model.LLMUsage, error) {
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

func (s *LLMService) Chat(ctx context.Context, messages []model.AIChatMessage, systemPrompt string) (string, model.LLMUsage, error) {
	contents := make([]map[string]any, 0, len(messages)+2)

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

	baseUsage := model.LLMUsage{Provider: "gemini", Model: geminiModelName}
	url := geminiEndpoint + "?key=" + s.GeminiAPIKey
	body := map[string]any{"contents": contents}

	respBody, err := s.doPost(ctx, url, "", body)
	if err != nil {
		return "", baseUsage, fmt.Errorf("gemini chat: %w", err)
	}

	usage := extractGeminiUsage(respBody)

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
		return "", usage, fmt.Errorf("parse chat response: %w", err)
	}
	if len(raw.Candidates) == 0 || len(raw.Candidates[0].Content.Parts) == 0 {
		return "", usage, fmt.Errorf("empty chat response")
	}
	return raw.Candidates[0].Content.Parts[0].Text, usage, nil
}

func (s *LLMService) askGeminiText(ctx context.Context, prompt string) (string, model.LLMUsage, error) {
	baseUsage := model.LLMUsage{Provider: "gemini", Model: geminiModelName}
	url := geminiEndpoint + "?key=" + s.GeminiAPIKey
	body := map[string]any{
		"contents": []map[string]any{
			{"parts": []map[string]any{{"text": prompt}}},
		},
	}

	respBody, err := s.doPost(ctx, url, "", body)
	if err != nil {
		return "", baseUsage, fmt.Errorf("gemini text: %w", err)
	}

	usage := extractGeminiUsage(respBody)

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
		return "", usage, fmt.Errorf("parse gemini text: %w", err)
	}
	if len(raw.Candidates) == 0 || len(raw.Candidates[0].Content.Parts) == 0 {
		return "", usage, fmt.Errorf("empty gemini response")
	}
	return raw.Candidates[0].Content.Parts[0].Text, usage, nil
}

// ── Qwen DashScope 네이티브 API ───────────────────────────────────────────────
//
// OpenAI 호환 엔드포인트는 오디오 입력을 지원하지 않으므로
// DashScope 멀티모달 생성 API를 직접 호출합니다.

func (s *LLMService) callQwenNative(ctx context.Context, audioBase64, prompt string) (string, model.LLMUsage, error) {
	baseUsage := model.LLMUsage{Provider: "qwen", Model: qwenModel}

	body := map[string]any{
		"model": qwenModel,
		"input": map[string]any{
			"messages": []map[string]any{
				{
					"role": "user",
					"content": []map[string]any{
						{"audio": "data:audio/mp3;base64," + audioBase64},
						{"text": prompt},
					},
				},
			},
		},
		"parameters": map[string]any{
			"result_format": "message",
		},
	}

	respBody, err := s.doPost(ctx, qwenNativeEndpoint, "Bearer "+s.QwenAPIKey, body)
	if err != nil {
		return "", baseUsage, err
	}

	return parseDashScopeResponse(respBody)
}

// parseDashScopeResponse parses the DashScope native multimodal API response.
// Response shape: {"output":{"choices":[{"message":{"content":[{"text":"..."}]}}]},"usage":{...}}
func parseDashScopeResponse(body []byte) (string, model.LLMUsage, error) {
	var raw struct {
		Output struct {
			Choices []struct {
				Message struct {
					Content []struct {
						Text string `json:"text"`
					} `json:"content"`
				} `json:"message"`
			} `json:"choices"`
		} `json:"output"`
		Usage struct {
			InputTokens  int `json:"input_tokens"`
			OutputTokens int `json:"output_tokens"`
		} `json:"usage"`
	}
	if err := json.Unmarshal(body, &raw); err != nil {
		return "", model.LLMUsage{}, fmt.Errorf("parse dashscope response: %w", err)
	}

	usage := model.LLMUsage{
		Provider:     "qwen",
		Model:        qwenModel,
		InputTokens:  raw.Usage.InputTokens,
		OutputTokens: raw.Usage.OutputTokens,
	}

	if len(raw.Output.Choices) == 0 || len(raw.Output.Choices[0].Message.Content) == 0 {
		return "", usage, fmt.Errorf("empty response from qwen native API")
	}
	text := raw.Output.Choices[0].Message.Content[0].Text
	return text, usage, nil
}

// parseTranscribeSentencesFromText parses {"sentences":[...]} from plain text (not raw HTTP body).
func parseTranscribeSentencesFromText(text string) ([]string, error) {
	var result struct {
		Sentences []string `json:"sentences"`
	}
	if err := json.Unmarshal([]byte(text), &result); err != nil {
		return nil, fmt.Errorf("parse sentences json (%q): %w", text, err)
	}
	if len(result.Sentences) == 0 {
		return nil, fmt.Errorf("no sentences in response")
	}
	return result.Sentences, nil
}

// ── 언어 유틸 ─────────────────────────────────────────────────────────────────

// isChineseLanguage는 zh, zh-CN, zh-TW, zh-HK 등 중국어 계열 코드를 모두 인식합니다.
func isChineseLanguage(lang string) bool {
	return lang == "zh" || len(lang) >= 3 && lang[:3] == "zh-"
}

// ── 토큰 사용량 파싱 ───────────────────────────────────────────────────────────

// extractGeminiUsage parses token counts from a Gemini API response body.
// Gemini returns: {"usageMetadata": {"promptTokenCount": N, "candidatesTokenCount": M}}
func extractGeminiUsage(body []byte) model.LLMUsage {
	var raw struct {
		UsageMetadata struct {
			PromptTokenCount     int `json:"promptTokenCount"`
			CandidatesTokenCount int `json:"candidatesTokenCount"`
		} `json:"usageMetadata"`
	}
	_ = json.Unmarshal(body, &raw)
	return model.LLMUsage{
		Provider:     "gemini",
		Model:        geminiModelName,
		InputTokens:  raw.UsageMetadata.PromptTokenCount,
		OutputTokens: raw.UsageMetadata.CandidatesTokenCount,
	}
}

// extractQwenUsage parses token counts from a Qwen (OpenAI-compatible) response body.
// Qwen returns: {"usage": {"prompt_tokens": N, "completion_tokens": M}}
func extractQwenUsage(body []byte) model.LLMUsage {
	var raw struct {
		Usage struct {
			PromptTokens     int `json:"prompt_tokens"`
			CompletionTokens int `json:"completion_tokens"`
		} `json:"usage"`
	}
	_ = json.Unmarshal(body, &raw)
	return model.LLMUsage{
		Provider:     "qwen",
		Model:        qwenModel,
		InputTokens:  raw.Usage.PromptTokens,
		OutputTokens: raw.Usage.CompletionTokens,
	}
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
