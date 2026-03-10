package service

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/liel/lingo-nexus-server/internal/model"
)

type CreditService struct {
	db *sql.DB
}

func NewCreditService(db *sql.DB) *CreditService {
	return &CreditService{db: db}
}

// GetStatus returns current credit status for a user.
func (s *CreditService) GetStatus(ctx context.Context, userID uint64) (*model.CreditStatusResponse, error) {
	acc, err := s.getAccount(ctx, userID)
	if err != nil {
		return nil, err
	}

	sub, err := s.getActiveSubscription(ctx, userID)
	if err != nil && err != sql.ErrNoRows {
		return nil, err
	}

	resp := &model.CreditStatusResponse{
		Balance:        acc.Balance,
		BalanceMinutes: acc.Balance / 60,
		DailyFreeUsed:  acc.DailyFreeUsed,
		DailyFreeTotal: model.DailyFreeSeconds,
	}
	if sub != nil {
		resp.HasSubscription = true
		resp.SubscriptionPlan = sub.Plan
		resp.ExpiresAt = sub.ExpiresAt.Format(time.RFC3339)
	}
	return resp, nil
}

// CheckAndDeductAudio checks free quota and credit balance, then deducts for audio usage.
// durationMs is the audio duration in milliseconds.
// Returns an error if the user has insufficient credits.
func (s *CreditService) CheckAndDeductAudio(ctx context.Context, userID uint64, durationMs int64) error {
	if durationMs > model.MaxAudioDurationMs {
		return fmt.Errorf("audio exceeds maximum allowed duration of %d minutes", model.MaxAudioDurationMs/60000)
	}

	durationSec := int(roundUpSeconds(durationMs, model.BillingIncrementSec))

	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Lock and fetch account
	var acc model.CreditAccount
	var resetDate string
	err = tx.QueryRowContext(ctx, `
		SELECT balance, daily_free_used, DATE_FORMAT(daily_free_reset_at, '%Y-%m-%d')
		FROM credit_accounts WHERE user_id = ? FOR UPDATE
	`, userID).Scan(&acc.Balance, &acc.DailyFreeUsed, &resetDate)
	if err == sql.ErrNoRows {
		// Create account if not exists
		if _, err2 := tx.ExecContext(ctx,
			`INSERT INTO credit_accounts (user_id) VALUES (?)`, userID); err2 != nil {
			return err2
		}
		acc = model.CreditAccount{}
	} else if err != nil {
		return err
	}

	// Reset daily counter if it's a new day
	today := time.Now().UTC().Format("2006-01-02")
	if resetDate != today {
		acc.DailyFreeUsed = 0
		if _, err := tx.ExecContext(ctx,
			`UPDATE credit_accounts SET daily_free_used = 0, daily_free_reset_at = ? WHERE user_id = ?`,
			today, userID); err != nil {
			return err
		}
	}

	// Determine how much of this request is covered by free quota
	freeRemaining := model.DailyFreeSeconds - acc.DailyFreeUsed
	if freeRemaining < 0 {
		freeRemaining = 0
	}

	fromFree := durationSec
	fromCredits := 0
	if durationSec > freeRemaining {
		fromFree = freeRemaining
		fromCredits = durationSec - freeRemaining
	}

	if fromCredits > 0 && acc.Balance < fromCredits {
		return fmt.Errorf("insufficient credits: need %d seconds (%d minutes), have %d seconds (%d minutes)",
			fromCredits, fromCredits/60, acc.Balance, acc.Balance/60)
	}

	// Deduct
	newBalance := acc.Balance - fromCredits
	newFreeUsed := acc.DailyFreeUsed + fromFree

	if _, err := tx.ExecContext(ctx, `
		UPDATE credit_accounts SET balance = ?, daily_free_used = ? WHERE user_id = ?
	`, newBalance, newFreeUsed, userID); err != nil {
		return err
	}

	// Record transaction
	if fromCredits > 0 {
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO credit_transactions (user_id, amount, type, description)
			VALUES (?, ?, 'audio_usage', ?)
		`, userID, -fromCredits, fmt.Sprintf("Audio processing: %ds", durationSec)); err != nil {
			return err
		}
	}

	return tx.Commit()
}

// AddCreditsFromPurchase adds credits after a verified in-app purchase.
func (s *CreditService) AddCreditsFromPurchase(ctx context.Context, userID uint64, req model.PurchaseRequest) error {
	product, ok := model.ProductCatalog[req.ProductID]
	if !ok {
		return fmt.Errorf("unknown product: %s", req.ProductID)
	}

	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()

	if product.Type == "credit" {
		if _, err := tx.ExecContext(ctx,
			`UPDATE credit_accounts SET balance = balance + ? WHERE user_id = ?`,
			product.Credits, userID); err != nil {
			return err
		}
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO credit_transactions (user_id, amount, type, description, product_id)
			VALUES (?, ?, 'purchase', ?, ?)
		`, userID, product.Credits, fmt.Sprintf("Credit pack: %s", req.ProductID), req.ProductID); err != nil {
			return err
		}
	} else if product.Type == "subscription" {
		now := time.Now().UTC()
		expiresAt := now.AddDate(0, 1, 0) // 1 month
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO subscriptions (user_id, plan, credits_per_month, started_at, expires_at, platform, original_transaction_id)
			VALUES (?, ?, ?, ?, ?, ?, ?)
		`, userID, product.Plan, product.CreditsPerMonth, now, expiresAt, req.Platform, req.TransactionID); err != nil {
			return err
		}
		// Grant monthly credits
		if _, err := tx.ExecContext(ctx,
			`UPDATE credit_accounts SET balance = balance + ? WHERE user_id = ?`,
			product.CreditsPerMonth, userID); err != nil {
			return err
		}
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO credit_transactions (user_id, amount, type, description, product_id)
			VALUES (?, ?, 'subscription_grant', ?, ?)
		`, userID, product.CreditsPerMonth,
			fmt.Sprintf("Subscription grant: %s (%d min)", product.Plan, product.CreditsPerMonth/60),
			req.ProductID); err != nil {
			return err
		}
	}

	return tx.Commit()
}

// ── Private helpers ───────────────────────────────────────────────────────────

func (s *CreditService) getAccount(ctx context.Context, userID uint64) (*model.CreditAccount, error) {
	var acc model.CreditAccount
	var resetDate string
	err := s.db.QueryRowContext(ctx, `
		SELECT user_id, balance, daily_free_used, DATE_FORMAT(daily_free_reset_at, '%Y-%m-%d'), updated_at
		FROM credit_accounts WHERE user_id = ?
	`, userID).Scan(&acc.UserID, &acc.Balance, &acc.DailyFreeUsed, &resetDate, &acc.UpdatedAt)
	if err == sql.ErrNoRows {
		// Create on demand
		s.db.ExecContext(ctx, `INSERT IGNORE INTO credit_accounts (user_id) VALUES (?)`, userID)
		return &model.CreditAccount{UserID: userID}, nil
	}
	if err != nil {
		return nil, err
	}

	// Reset daily if new day
	today := time.Now().UTC().Format("2006-01-02")
	if resetDate != today {
		acc.DailyFreeUsed = 0
	}
	return &acc, nil
}

func (s *CreditService) getActiveSubscription(ctx context.Context, userID uint64) (*model.Subscription, error) {
	var sub model.Subscription
	err := s.db.QueryRowContext(ctx, `
		SELECT id, user_id, plan, credits_per_month, started_at, expires_at, platform
		FROM subscriptions
		WHERE user_id = ? AND expires_at > NOW()
		ORDER BY expires_at DESC LIMIT 1
	`, userID).Scan(&sub.ID, &sub.UserID, &sub.Plan, &sub.CreditsPerMonth,
		&sub.StartedAt, &sub.ExpiresAt, &sub.Platform)
	if err != nil {
		return nil, err
	}
	return &sub, nil
}

// roundUpSeconds rounds durationMs up to the nearest increment seconds.
func roundUpSeconds(durationMs int64, increment int) int64 {
	seconds := (durationMs + 999) / 1000 // ceil to seconds
	inc := int64(increment)
	return ((seconds + inc - 1) / inc) * inc
}
