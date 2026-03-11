package service

import (
	"context"
	"database/sql"
	"log"
	"time"

	"github.com/liel/lingo-nexus-server/internal/model"
)

// UsageLogService writes LLM call logs to the DB.
type UsageLogService struct {
	db *sql.DB
}

func NewUsageLogService(db *sql.DB) *UsageLogService {
	return &UsageLogService{db: db}
}

// LogAsync writes a usage record asynchronously (fire-and-forget).
// userID may be nil when auth is disabled.
func (s *UsageLogService) LogAsync(
	userID *uint64,
	endpoint, language string,
	usage model.LLMUsage,
	durationMs int64,
	resultPreview, errStr string,
) {
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := s.insert(ctx, userID, endpoint, language, usage, durationMs, resultPreview, errStr); err != nil {
			log.Printf("usage log insert error: %v", err)
		}
	}()
}

func (s *UsageLogService) insert(
	ctx context.Context,
	userID *uint64,
	endpoint, language string,
	usage model.LLMUsage,
	durationMs int64,
	resultPreview, errStr string,
) error {
	const q = `
		INSERT INTO llm_usage_logs
			(user_id, endpoint, provider, model, language, input_tokens, output_tokens, duration_ms, result_preview, error)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`

	var uid any
	if userID != nil {
		uid = *userID
	}
	_, err := s.db.ExecContext(ctx, q,
		uid, endpoint, usage.Provider, usage.Model, language,
		usage.InputTokens, usage.OutputTokens, durationMs,
		truncateRune(resultPreview, 500), errStr,
	)
	return err
}

func truncateRune(s string, n int) string {
	r := []rune(s)
	if len(r) <= n {
		return s
	}
	return string(r[:n])
}
