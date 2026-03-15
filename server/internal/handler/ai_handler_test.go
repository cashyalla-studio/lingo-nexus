package handler

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/liel/lingo-nexus-server/internal/model"
	"github.com/liel/lingo-nexus-server/testutil"
)

func TestAIHandler_Grammar(t *testing.T) {
	tests := []struct {
		name       string
		body       string
		mockSetup  func(*testutil.MockLLMService)
		wantStatus int
		wantReply  string
	}{
		{
			name:       "empty sentence returns 400",
			body:       `{"sentence":""}`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name:       "missing sentence field returns 400",
			body:       `{}`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name: "valid request returns 200 with reply",
			body: `{"sentence":"Hello world","ui_language":"en"}`,
			mockSetup: func(m *testutil.MockLLMService) {
				m.AskGrammarFunc = func(_ context.Context, sentence, uiLang string) (string, model.LLMUsage, error) {
					return "Grammar explanation here", model.LLMUsage{}, nil
				}
			},
			wantStatus: http.StatusOK,
			wantReply:  "Grammar explanation here",
		},
		{
			name: "missing ui_language defaults to ko",
			body: `{"sentence":"Hello world"}`,
			mockSetup: func(m *testutil.MockLLMService) {
				m.AskGrammarFunc = func(_ context.Context, _, uiLang string) (string, model.LLMUsage, error) {
					if uiLang != "ko" {
						return "", model.LLMUsage{}, errors.New("expected default ui_language ko, got: " + uiLang)
					}
					return "OK", model.LLMUsage{}, nil
				}
			},
			wantStatus: http.StatusOK,
		},
		{
			name: "LLM service error returns 500",
			body: `{"sentence":"Hello"}`,
			mockSetup: func(m *testutil.MockLLMService) {
				m.AskGrammarFunc = func(_ context.Context, _, _ string) (string, model.LLMUsage, error) {
					return "", model.LLMUsage{}, errors.New("LLM API timeout")
				}
			},
			wantStatus: http.StatusInternalServerError,
		},
		{
			name:       "malformed JSON returns 400",
			body:       `{bad json`,
			wantStatus: http.StatusBadRequest,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			llmMock := &testutil.MockLLMService{}
			if tt.mockSetup != nil {
				tt.mockSetup(llmMock)
			}
			usageMock := &testutil.MockUsageLogService{}
			h := NewAIHandler(llmMock, usageMock)

			req := httptest.NewRequest(http.MethodPost, "/api/v1/ai/grammar",
				bytes.NewBufferString(tt.body))
			req.Header.Set("Content-Type", "application/json")
			w := httptest.NewRecorder()

			h.Grammar(w, req)

			if w.Code != tt.wantStatus {
				t.Errorf("Grammar() status = %d, want %d (body: %s)",
					w.Code, tt.wantStatus, w.Body.String())
			}

			if tt.wantReply != "" && w.Code == http.StatusOK {
				var resp model.TextAIResponse
				if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
					t.Fatalf("response is not valid JSON: %v", err)
				}
				if resp.Reply != tt.wantReply {
					t.Errorf("reply = %q, want %q", resp.Reply, tt.wantReply)
				}
			}
		})
	}
}

func TestAIHandler_Vocabulary(t *testing.T) {
	tests := []struct {
		name       string
		body       string
		mockSetup  func(*testutil.MockLLMService)
		wantStatus int
	}{
		{
			name:       "empty word returns 400",
			body:       `{"word":""}`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name: "valid request returns 200",
			body: `{"word":"ephemeral","context":"life is ephemeral","ui_language":"en"}`,
			mockSetup: func(m *testutil.MockLLMService) {
				m.AskVocabularyFunc = func(_ context.Context, _, _, _ string) (string, model.LLMUsage, error) {
					return "Vocabulary explanation", model.LLMUsage{}, nil
				}
			},
			wantStatus: http.StatusOK,
		},
		{
			name: "LLM error returns 500",
			body: `{"word":"test"}`,
			mockSetup: func(m *testutil.MockLLMService) {
				m.AskVocabularyFunc = func(_ context.Context, _, _, _ string) (string, model.LLMUsage, error) {
					return "", model.LLMUsage{}, errors.New("service error")
				}
			},
			wantStatus: http.StatusInternalServerError,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			llmMock := &testutil.MockLLMService{}
			if tt.mockSetup != nil {
				tt.mockSetup(llmMock)
			}
			h := NewAIHandler(llmMock, &testutil.MockUsageLogService{})

			req := httptest.NewRequest(http.MethodPost, "/api/v1/ai/vocabulary",
				bytes.NewBufferString(tt.body))
			req.Header.Set("Content-Type", "application/json")
			w := httptest.NewRecorder()

			h.Vocabulary(w, req)

			if w.Code != tt.wantStatus {
				t.Errorf("Vocabulary() status = %d, want %d (body: %s)",
					w.Code, tt.wantStatus, w.Body.String())
			}
		})
	}
}

func TestAIHandler_Chat(t *testing.T) {
	tests := []struct {
		name       string
		body       string
		mockSetup  func(*testutil.MockLLMService)
		wantStatus int
	}{
		{
			name:       "empty messages array returns 400",
			body:       `{"messages":[]}`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name:       "missing messages field returns 400",
			body:       `{}`,
			wantStatus: http.StatusBadRequest,
		},
		{
			name: "valid chat request returns 200",
			body: `{"messages":[{"role":"user","content":"Hello!"}]}`,
			mockSetup: func(m *testutil.MockLLMService) {
				m.ChatFunc = func(_ context.Context, msgs []model.AIChatMessage, _ string) (string, model.LLMUsage, error) {
					return "Hi there!", model.LLMUsage{}, nil
				}
			},
			wantStatus: http.StatusOK,
		},
		{
			name: "LLM error returns 500",
			body: `{"messages":[{"role":"user","content":"Hello"}]}`,
			mockSetup: func(m *testutil.MockLLMService) {
				m.ChatFunc = func(_ context.Context, _ []model.AIChatMessage, _ string) (string, model.LLMUsage, error) {
					return "", model.LLMUsage{}, errors.New("API key invalid")
				}
			},
			wantStatus: http.StatusInternalServerError,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			llmMock := &testutil.MockLLMService{}
			if tt.mockSetup != nil {
				tt.mockSetup(llmMock)
			}
			h := NewAIHandler(llmMock, &testutil.MockUsageLogService{})

			req := httptest.NewRequest(http.MethodPost, "/api/v1/ai/chat",
				bytes.NewBufferString(tt.body))
			req.Header.Set("Content-Type", "application/json")
			w := httptest.NewRecorder()

			h.Chat(w, req)

			if w.Code != tt.wantStatus {
				t.Errorf("Chat() status = %d, want %d (body: %s)",
					w.Code, tt.wantStatus, w.Body.String())
			}
		})
	}
}

func TestAIHandler_Grammar_LogsUsage(t *testing.T) {
	llmMock := &testutil.MockLLMService{
		AskGrammarFunc: func(_ context.Context, _, _ string) (string, model.LLMUsage, error) {
			return "OK", model.LLMUsage{Provider: "gemini", InputTokens: 10}, nil
		},
	}
	usageMock := &testutil.MockUsageLogService{}
	h := NewAIHandler(llmMock, usageMock)

	req := httptest.NewRequest(http.MethodPost, "/api/v1/ai/grammar",
		bytes.NewBufferString(`{"sentence":"test"}`))
	w := httptest.NewRecorder()
	h.Grammar(w, req)

	if len(usageMock.Calls) != 1 {
		t.Fatalf("expected 1 usage log call, got %d", len(usageMock.Calls))
	}
	if usageMock.Calls[0].Endpoint != "grammar" {
		t.Errorf("usage log endpoint = %q, want %q", usageMock.Calls[0].Endpoint, "grammar")
	}
}
