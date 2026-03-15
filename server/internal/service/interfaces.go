package service

import (
	"context"

	"github.com/liel/lingo-nexus-server/internal/model"
)

// AuthServiceInterface abstracts auth operations for handler/middleware testing.
type AuthServiceInterface interface {
	LoginWithGoogle(ctx context.Context, idToken string) (*model.AuthResponse, error)
	RefreshAccessToken(ctx context.Context, refreshToken string) (*model.AuthResponse, error)
	ValidateAccessToken(tokenString string) (uint64, error)
}

// LLMServiceInterface abstracts LLM operations for handler testing.
type LLMServiceInterface interface {
	AskGrammar(ctx context.Context, sentence, uiLang string) (string, model.LLMUsage, error)
	AskVocabulary(ctx context.Context, word, contextSentence, uiLang string) (string, model.LLMUsage, error)
	Chat(ctx context.Context, messages []model.AIChatMessage, systemPrompt string) (string, model.LLMUsage, error)
}

// CreditServiceInterface abstracts credit operations for handler testing.
type CreditServiceInterface interface {
	GetStatus(ctx context.Context, userID uint64) (*model.CreditStatusResponse, error)
	CheckAndDeductAudio(ctx context.Context, userID uint64, durationMs int64) error
	AddCreditsFromPurchase(ctx context.Context, userID uint64, req model.PurchaseRequest) error
}

// UsageLogServiceInterface abstracts usage logging for handler testing.
type UsageLogServiceInterface interface {
	LogAsync(userID *uint64, endpoint, language string, usage model.LLMUsage, durationMs int64, resultPreview, errStr string)
}

// Compile-time interface compliance checks.
var _ AuthServiceInterface = (*AuthService)(nil)
var _ LLMServiceInterface = (*LLMService)(nil)
var _ CreditServiceInterface = (*CreditService)(nil)
var _ UsageLogServiceInterface = (*UsageLogService)(nil)
