package db

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

// Open opens a MySQL connection using DATABASE_URL env var.
// Falls back to building DSN from individual env vars.
func Open() (*sql.DB, error) {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		user := getEnvOrDefault("MYSQL_USER", "lingo")
		pass := getEnvOrDefault("MYSQL_PASSWORD", "lingopassword")
		host := getEnvOrDefault("MYSQL_HOST", "localhost")
		port := getEnvOrDefault("MYSQL_PORT", "3306")
		name := getEnvOrDefault("MYSQL_DATABASE", "lingo_nexus")
		dsn = fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true&charset=utf8mb4&loc=UTC",
			user, pass, host, port, name)
	}

	db, err := sql.Open("mysql", dsn)
	if err != nil {
		return nil, fmt.Errorf("sql.Open: %w", err)
	}

	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(10)
	db.SetConnMaxLifetime(5 * time.Minute)

	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("db.Ping: %w", err)
	}

	log.Println("Connected to MySQL")
	return db, nil
}

func getEnvOrDefault(key, defaultVal string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultVal
}
