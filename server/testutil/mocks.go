// Package testutil provides shared test helpers and mock implementations.
package testutil

import (
	"context"
	"errors"

	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/internal/service"
)

// ── Mock AuthService ──────────────────────────────────────────────────────────

// MockAuthService implements service.AuthServiceInterface for testing.
type MockAuthService struct {
	LoginWithGoogleFunc       func(ctx context.Context, idToken string) (*model.AuthResponse, error)
	RefreshAccessTokenFunc    func(ctx context.Context, refreshToken string) (*model.AuthResponse, error)
	ValidateAccessTokenFunc   func(tokenString string) (uint64, error)
}

func (m *MockAuthService) LoginWithGoogle(ctx context.Context, idToken string) (*model.AuthResponse, error) {
	if m.LoginWithGoogleFunc != nil {
		return m.LoginWithGoogleFunc(ctx, idToken)
	}
	return nil, errors.New("LoginWithGoogle not configured")
}

func (m *MockAuthService) RefreshAccessToken(ctx context.Context, refreshToken string) (*model.AuthResponse, error) {
	if m.RefreshAccessTokenFunc != nil {
		return m.RefreshAccessTokenFunc(ctx, refreshToken)
	}
	return nil, errors.New("RefreshAccessToken not configured")
}

func (m *MockAuthService) ValidateAccessToken(tokenString string) (uint64, error) {
	if m.ValidateAccessTokenFunc != nil {
		return m.ValidateAccessTokenFunc(tokenString)
	}
	return 0, errors.New("ValidateAccessToken not configured")
}

var _ service.AuthServiceInterface = (*MockAuthService)(nil)

// ── Mock LLMService ───────────────────────────────────────────────────────────

// MockLLMService implements service.LLMServiceInterface for testing.
type MockLLMService struct {
	AskGrammarFunc    func(ctx context.Context, sentence, uiLang string) (string, model.LLMUsage, error)
	AskVocabularyFunc func(ctx context.Context, word, contextSentence, uiLang string) (string, model.LLMUsage, error)
	ChatFunc          func(ctx context.Context, messages []model.AIChatMessage, systemPrompt string) (string, model.LLMUsage, error)
}

func (m *MockLLMService) AskGrammar(ctx context.Context, sentence, uiLang string) (string, model.LLMUsage, error) {
	if m.AskGrammarFunc != nil {
		return m.AskGrammarFunc(ctx, sentence, uiLang)
	}
	return "", model.LLMUsage{}, errors.New("AskGrammar not configured")
}

func (m *MockLLMService) AskVocabulary(ctx context.Context, word, contextSentence, uiLang string) (string, model.LLMUsage, error) {
	if m.AskVocabularyFunc != nil {
		return m.AskVocabularyFunc(ctx, word, contextSentence, uiLang)
	}
	return "", model.LLMUsage{}, errors.New("AskVocabulary not configured")
}

func (m *MockLLMService) Chat(ctx context.Context, messages []model.AIChatMessage, systemPrompt string) (string, model.LLMUsage, error) {
	if m.ChatFunc != nil {
		return m.ChatFunc(ctx, messages, systemPrompt)
	}
	return "", model.LLMUsage{}, errors.New("Chat not configured")
}

var _ service.LLMServiceInterface = (*MockLLMService)(nil)

// ── Mock CreditService ────────────────────────────────────────────────────────

// MockCreditService implements service.CreditServiceInterface for testing.
type MockCreditService struct {
	GetStatusFunc             func(ctx context.Context, userID uint64) (*model.CreditStatusResponse, error)
	CheckAndDeductAudioFunc   func(ctx context.Context, userID uint64, durationMs int64) error
	AddCreditsFromPurchaseFunc func(ctx context.Context, userID uint64, req model.PurchaseRequest) error
}

func (m *MockCreditService) GetStatus(ctx context.Context, userID uint64) (*model.CreditStatusResponse, error) {
	if m.GetStatusFunc != nil {
		return m.GetStatusFunc(ctx, userID)
	}
	return &model.CreditStatusResponse{}, nil
}

func (m *MockCreditService) CheckAndDeductAudio(ctx context.Context, userID uint64, durationMs int64) error {
	if m.CheckAndDeductAudioFunc != nil {
		return m.CheckAndDeductAudioFunc(ctx, userID, durationMs)
	}
	return nil
}

func (m *MockCreditService) AddCreditsFromPurchase(ctx context.Context, userID uint64, req model.PurchaseRequest) error {
	if m.AddCreditsFromPurchaseFunc != nil {
		return m.AddCreditsFromPurchaseFunc(ctx, userID, req)
	}
	return nil
}

var _ service.CreditServiceInterface = (*MockCreditService)(nil)

// ── Mock UsageLogService ──────────────────────────────────────────────────────

// MockUsageLogService implements service.UsageLogServiceInterface for testing.
type MockUsageLogService struct {
	Calls []UsageLogCall
}

type UsageLogCall struct {
	UserID        *uint64
	Endpoint      string
	Language      string
	Usage         model.LLMUsage
	DurationMs    int64
	ResultPreview string
	ErrStr        string
}

func (m *MockUsageLogService) LogAsync(userID *uint64, endpoint, language string, usage model.LLMUsage, durationMs int64, resultPreview, errStr string) {
	m.Calls = append(m.Calls, UsageLogCall{
		UserID: userID, Endpoint: endpoint, Language: language,
		Usage: usage, DurationMs: durationMs, ResultPreview: resultPreview, ErrStr: errStr,
	})
}

var _ service.UsageLogServiceInterface = (*MockUsageLogService)(nil)
