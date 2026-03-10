package model

// AskGrammarRequest is sent by the client for grammar explanation.
type AskGrammarRequest struct {
	Sentence   string `json:"sentence"`
	UILanguage string `json:"ui_language"` // e.g. "ko", "en", "ja"
}

// AskVocabularyRequest is sent by the client for vocabulary explanation.
type AskVocabularyRequest struct {
	Word       string `json:"word"`
	Context    string `json:"context"`
	UILanguage string `json:"ui_language"`
}

// ChatMessage represents a single message in a conversation.
type AIChatMessage struct {
	Role    string `json:"role"`    // "user" | "assistant"
	Content string `json:"content"`
}

// ChatRequest is sent by the client for a conversation turn.
type ChatRequest struct {
	Messages     []AIChatMessage `json:"messages"`
	SystemPrompt string          `json:"system_prompt"`
}

// TextAIResponse wraps any text AI response.
type TextAIResponse struct {
	Reply string `json:"reply"`
}
