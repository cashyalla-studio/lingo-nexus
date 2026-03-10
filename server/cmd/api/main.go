package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"

	"github.com/liel/lingo-nexus-server/internal/handler"
	"github.com/liel/lingo-nexus-server/internal/service"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// API 키는 환경변수로 주입 (QWEN_API_KEY, GEMINI_API_KEY)
	qwenKey := os.Getenv("QWEN_API_KEY")
	geminiKey := os.Getenv("GEMINI_API_KEY")
	if qwenKey == "" || geminiKey == "" {
		log.Println("Warning: QWEN_API_KEY or GEMINI_API_KEY not set — tone evaluation will fail")
	}

	llmSvc := service.NewLLMService(qwenKey, geminiKey)
	toneHandler := handler.NewToneHandler(llmSvc)
	transcribeHandler := handler.NewTranscribeHandler(llmSvc)

	r := chi.NewRouter()

	// Middleware
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.RequestID)
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type"},
		AllowCredentials: false,
		MaxAge:           300,
	}))

	// Routes
	r.Get("/health", handler.Health)

	r.Route("/api/v1", func(r chi.Router) {
		r.Get("/ping", handler.Ping)
		r.Post("/tone/evaluate", toneHandler.EvaluateTone)
		r.Post("/sync/transcribe", transcribeHandler.Transcribe)
	})

	addr := fmt.Sprintf(":%s", port)
	log.Printf("Server starting on %s", addr)
	if err := http.ListenAndServe(addr, r); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
