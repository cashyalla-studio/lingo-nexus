package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"

	"github.com/liel/lingo-nexus-server/internal/db"
	"github.com/liel/lingo-nexus-server/internal/handler"
	appMiddleware "github.com/liel/lingo-nexus-server/internal/middleware"
	"github.com/liel/lingo-nexus-server/internal/service"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// ── Database ────────────────────────────────────────────────────────────
	database, err := db.Open()
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer database.Close()

	// ── Services ────────────────────────────────────────────────────────────
	qwenKey := os.Getenv("QWEN_API_KEY")
	geminiKey := os.Getenv("GEMINI_API_KEY")
	if qwenKey == "" || geminiKey == "" {
		log.Println("Warning: QWEN_API_KEY or GEMINI_API_KEY not set — audio AI will fail")
	}

	llmSvc := service.NewLLMService(qwenKey, geminiKey)
	authSvc := service.NewAuthService(database)
	creditSvc := service.NewCreditService(database)

	// ── Handlers ─────────────────────────────────────────────────────────────
	toneHandler := handler.NewToneHandler(llmSvc, creditSvc)
	transcribeHandler := handler.NewTranscribeHandler(llmSvc, creditSvc)
	authHandler := handler.NewAuthHandler(authSvc)
	userHandler := handler.NewUserHandler(database)
	creditHandler := handler.NewCreditHandler(creditSvc)
	aiHandler := handler.NewAIHandler(llmSvc)

	// ── Middleware ────────────────────────────────────────────────────────────
	// TODO(testing): re-enable before production
	_ = appMiddleware.Auth(authSvc) // authMiddleware — commented out for local testing

	r := chi.NewRouter()
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

	isDev := os.Getenv("APP_ENV") == "development"

	// ── Routes ───────────────────────────────────────────────────────────────
	r.Get("/health", handler.Health)

	// Dev-only: API docs (Scalar UI)
	if isDev {
		r.Get("/docs", handler.DocsHandler)
		r.Get("/openapi.yaml", handler.OpenAPIHandler)
		log.Println("Dev mode: API docs available at /docs")
	}

	r.Route("/api/v1", func(r chi.Router) {
		r.Get("/ping", handler.Ping)

		// Auth (public)
		r.Post("/auth/login", authHandler.Login)
		r.Post("/auth/refresh", authHandler.Refresh)

		// Protected routes
		r.Group(func(r chi.Router) {
			// TODO(testing): re-enable auth middleware before production
			// r.Use(authMiddleware)

			// User
			r.Get("/user/me", userHandler.GetMe)

			// Credits
			r.Get("/credits", creditHandler.GetStatus)
			r.Post("/credits/purchase", creditHandler.Purchase)
			r.Get("/credits/products", creditHandler.GetProducts)

			// Text AI (free for all authenticated users)
			r.Post("/ai/grammar", aiHandler.Grammar)
			r.Post("/ai/vocabulary", aiHandler.Vocabulary)
			r.Post("/ai/chat", aiHandler.Chat)

			// Audio AI (requires credits or daily free quota)
			r.Post("/tone/evaluate", toneHandler.EvaluateTone)
			r.Post("/sync/transcribe", transcribeHandler.Transcribe)
		})
	})

	addr := fmt.Sprintf(":%s", port)
	log.Printf("Server starting on %s", addr)
	if err := http.ListenAndServe(addr, r); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
