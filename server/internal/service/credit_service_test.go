package service

import (
	"testing"

	"github.com/liel/lingo-nexus-server/internal/model"
)

// TestRoundUpSeconds tests the billing rounding helper.
func TestRoundUpSeconds(t *testing.T) {
	increment := model.BillingIncrementSec // 6 seconds

	tests := []struct {
		name       string
		durationMs int64
		want       int64
	}{
		{"zero ms rounds to 6s", 0, 6},
		{"1ms rounds up to 6s", 1, 6},
		{"999ms rounds to 6s (within first second)", 999, 6},
		{"1000ms is exactly 1s, rounds to 6s", 1000, 6},
		{"6000ms is exactly 6s, no rounding", 6000, 6},
		{"6001ms rounds to 12s", 6001, 12},
		{"11999ms rounds to 12s", 11999, 12},
		{"12000ms is exactly 12s", 12000, 12},
		{"60000ms is exactly 60s", 60000, 60},
		{"60001ms rounds to 66s", 60001, 66},
		{"max duration 10min stays at 600s", model.MaxAudioDurationMs, 600},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := roundUpSeconds(tt.durationMs, increment)
			if got != tt.want {
				t.Errorf("roundUpSeconds(%d, %d) = %d, want %d",
					tt.durationMs, increment, got, tt.want)
			}
		})
	}
}

// TestRoundUpSeconds_AlwaysMultipleOfIncrement ensures result is always divisible by increment.
func TestRoundUpSeconds_AlwaysMultipleOfIncrement(t *testing.T) {
	increment := 6
	for ms := int64(0); ms <= 120_000; ms += 137 { // irregular step to catch edge cases
		result := roundUpSeconds(ms, increment)
		if result%int64(increment) != 0 {
			t.Errorf("roundUpSeconds(%d, %d) = %d is not a multiple of %d", ms, increment, result, increment)
		}
		if result <= 0 {
			t.Errorf("roundUpSeconds(%d, %d) = %d must be positive", ms, increment, result)
		}
	}
}

// TestAddCreditsFromPurchase_UnknownProduct tests product validation (no DB needed).
func TestAddCreditsFromPurchase_UnknownProduct(t *testing.T) {
	svc := &CreditService{db: nil} // db is nil — we expect early return before any DB call
	err := svc.AddCreditsFromPurchase(nil, 1, model.PurchaseRequest{ProductID: "nonexistent.product.id"})
	if err == nil {
		t.Error("expected error for unknown product, got nil")
	}
}

// TestAddCreditsFromPurchase_KnownProductsExist tests that the product catalog is populated.
func TestAddCreditsFromPurchase_KnownProductsExist(t *testing.T) {
	knownProducts := []string{
		"xyz.cashyalla.scrypta.sync.credits.c10",
		"xyz.cashyalla.scrypta.sync.credits.c130",
		"xyz.cashyalla.scrypta.sync.credits.c1500",
		"xyz.cashyalla.scrypta.sync.sub.basic",
		"xyz.cashyalla.scrypta.sync.sub.pro",
		"xyz.cashyalla.scrypta.sync.sub.premium",
	}
	for _, id := range knownProducts {
		if _, ok := model.ProductCatalog[id]; !ok {
			t.Errorf("expected product %q to be in ProductCatalog", id)
		}
	}
}

// TestCheckAndDeductAudio_ExceedsMaxDuration tests the duration guard (no DB needed).
func TestCheckAndDeductAudio_ExceedsMaxDuration(t *testing.T) {
	svc := &CreditService{db: nil}
	overLimit := model.MaxAudioDurationMs + 1
	err := svc.CheckAndDeductAudio(nil, 1, overLimit)
	if err == nil {
		t.Error("expected error when audio exceeds max duration, got nil")
	}
}

// TestCheckAndDeductAudio_AtMaxDuration tests that exact max is not rejected.
// Note: This WILL try to use the DB — skip if DB is unavailable.
// Run this test as part of integration testing with a real/mock DB.
func TestCheckAndDeductAudio_AtMaxDuration_DurationAccepted(t *testing.T) {
	t.Skip("requires DB — run in integration test suite")
}
