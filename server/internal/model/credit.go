package model

import "time"

const (
	// DailyFreeSeconds is the free audio quota per day (3 minutes).
	DailyFreeSeconds = 180

	// MaxAudioDurationMs is the maximum allowed audio upload (10 minutes).
	MaxAudioDurationMs = 600_000

	// BillingIncrementSec rounds up billing to the nearest N seconds.
	BillingIncrementSec = 6

	// Plan credit allocations in seconds per month.
	PlanBasicSeconds   = 18_000  // 300 min
	PlanProSeconds     = 60_000  // 1000 min
	PlanPremiumSeconds = 180_000 // 3000 min
)

type CreditAccount struct {
	UserID           uint64    `json:"user_id"`
	Balance          int       `json:"balance"`           // seconds
	DailyFreeUsed    int       `json:"daily_free_used"`   // seconds used today
	DailyFreeResetAt time.Time `json:"daily_free_reset_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}

type CreditTransaction struct {
	ID          uint64    `json:"id"`
	UserID      uint64    `json:"user_id"`
	Amount      int       `json:"amount"` // positive=credit, negative=deduct (seconds)
	Type        string    `json:"type"`
	Description string    `json:"description,omitempty"`
	ProductID   string    `json:"product_id,omitempty"`
	CreatedAt   time.Time `json:"created_at"`
}

type Subscription struct {
	ID                    uint64    `json:"id"`
	UserID                uint64    `json:"user_id"`
	Plan                  string    `json:"plan"`
	CreditsPerMonth       int       `json:"credits_per_month"`
	StartedAt             time.Time `json:"started_at"`
	ExpiresAt             time.Time `json:"expires_at"`
	Platform              string    `json:"platform"`
	OriginalTransactionID string    `json:"original_transaction_id,omitempty"`
	CreatedAt             time.Time `json:"created_at"`
}

// CreditStatusResponse is returned by GET /api/v1/credits.
type CreditStatusResponse struct {
	Balance          int    `json:"balance"`            // seconds
	BalanceMinutes   int    `json:"balance_minutes"`    // balance / 60 for display
	DailyFreeUsed    int    `json:"daily_free_used"`    // seconds
	DailyFreeTotal   int    `json:"daily_free_total"`   // DailyFreeSeconds
	HasSubscription  bool   `json:"has_subscription"`
	SubscriptionPlan string `json:"subscription_plan,omitempty"`
	ExpiresAt        string `json:"expires_at,omitempty"`
}

// PurchaseRequest is sent by the client after an in-app purchase.
type PurchaseRequest struct {
	ProductID     string `json:"product_id"`
	ReceiptData   string `json:"receipt_data"`   // iOS receipt or Android purchase token
	Platform      string `json:"platform"`       // "ios" | "android"
	TransactionID string `json:"transaction_id"` // original transaction ID
}

// InAppProduct defines credit package and subscription products.
type InAppProduct struct {
	ID             string `json:"id"`
	Type           string `json:"type"` // "credit" | "subscription"
	Credits        int    `json:"credits,omitempty"`        // seconds
	CreditsPerMonth int   `json:"credits_per_month,omitempty"` // seconds
	Plan           string `json:"plan,omitempty"`
}

// ProductCatalog maps product IDs to their definitions.
var ProductCatalog = map[string]InAppProduct{
	// Credit packs (seconds)
	"xyz.cashyalla.scrypta.sync.credits.c10":   {ID: "xyz.cashyalla.scrypta.sync.credits.c10", Type: "credit", Credits: 600},     // 10 min
	"xyz.cashyalla.scrypta.sync.credits.c130":  {ID: "xyz.cashyalla.scrypta.sync.credits.c130", Type: "credit", Credits: 7800},   // 130 min
	"xyz.cashyalla.scrypta.sync.credits.c1500": {ID: "xyz.cashyalla.scrypta.sync.credits.c1500", Type: "credit", Credits: 90000}, // 1500 min
	// Subscriptions (seconds/month)
	"xyz.cashyalla.scrypta.sync.sub.basic":   {ID: "xyz.cashyalla.scrypta.sync.sub.basic", Type: "subscription", Plan: "basic", CreditsPerMonth: PlanBasicSeconds},
	"xyz.cashyalla.scrypta.sync.sub.pro":     {ID: "xyz.cashyalla.scrypta.sync.sub.pro", Type: "subscription", Plan: "pro", CreditsPerMonth: PlanProSeconds},
	"xyz.cashyalla.scrypta.sync.sub.premium": {ID: "xyz.cashyalla.scrypta.sync.sub.premium", Type: "subscription", Plan: "premium", CreditsPerMonth: PlanPremiumSeconds},
}
