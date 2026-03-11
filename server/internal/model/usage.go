package model

import "time"

// LLMUsage holds token counts returned by the LLM provider for a single call.
type LLMUsage struct {
	Provider     string // "gemini" | "qwen"
	Model        string
	InputTokens  int
	OutputTokens int
}

// UsageLog is the DB record for a single LLM call.
type UsageLog struct {
	ID            uint64
	UserID        *uint64  // nullable — auth may be disabled
	Endpoint      string   // "transcribe" | "tone_evaluate" | "grammar" | "vocabulary" | "chat"
	Provider      string
	Model         string
	Language      string
	InputTokens   int
	OutputTokens  int
	DurationMs    int64
	ResultPreview string   // first 500 chars
	Error         string
	CreatedAt     time.Time
}
