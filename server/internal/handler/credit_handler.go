package handler

import (
	"encoding/json"
	"net/http"

	"github.com/liel/lingo-nexus-server/internal/model"
	appMiddleware "github.com/liel/lingo-nexus-server/internal/middleware"
	"github.com/liel/lingo-nexus-server/internal/service"
)

type CreditHandler struct {
	creditSvc service.CreditServiceInterface
}

func NewCreditHandler(creditSvc service.CreditServiceInterface) *CreditHandler {
	return &CreditHandler{creditSvc: creditSvc}
}

// GET /api/v1/credits
func (h *CreditHandler) GetStatus(w http.ResponseWriter, r *http.Request) {
	userID, ok := appMiddleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	status, err := h.creditSvc.GetStatus(r.Context(), userID)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to get credit status: "+err.Error())
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(status)
}

// POST /api/v1/credits/purchase
// Body: PurchaseRequest
func (h *CreditHandler) Purchase(w http.ResponseWriter, r *http.Request) {
	userID, ok := appMiddleware.GetUserID(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	var req model.PurchaseRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}
	if req.ProductID == "" {
		writeError(w, http.StatusBadRequest, "product_id is required")
		return
	}

	if err := h.creditSvc.AddCreditsFromPurchase(r.Context(), userID, req); err != nil {
		writeError(w, http.StatusBadRequest, "purchase failed: "+err.Error())
		return
	}

	status, _ := h.creditSvc.GetStatus(r.Context(), userID)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(status)
}

// GET /api/v1/credits/products
func (h *CreditHandler) GetProducts(w http.ResponseWriter, r *http.Request) {
	products := make([]model.InAppProduct, 0, len(model.ProductCatalog))
	for _, p := range model.ProductCatalog {
		products = append(products, p)
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]any{"products": products})
}
