package handler

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealth(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	w := httptest.NewRecorder()

	Health(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Health() status = %d, want %d", w.Code, http.StatusOK)
	}

	var body map[string]string
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatalf("Health() body is not valid JSON: %v", err)
	}
	if body["status"] != "ok" {
		t.Errorf("Health() body status = %q, want %q", body["status"], "ok")
	}
}

func TestPing(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/api/v1/ping", nil)
	w := httptest.NewRecorder()

	Ping(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("Ping() status = %d, want %d", w.Code, http.StatusOK)
	}

	var body map[string]string
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatalf("Ping() body is not valid JSON: %v", err)
	}
	if body["message"] != "pong" {
		t.Errorf("Ping() body message = %q, want %q", body["message"], "pong")
	}
}
