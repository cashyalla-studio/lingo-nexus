.PHONY: app server dev lint test

# ── App (Flutter) ──────────────────────────────────────────
app:
	cd app && flutter run -d android

app-ios:
	cd app && flutter run -d ios

app-macos:
	cd app && flutter run -d macos

app-build-android:
	cd app && flutter build apk --release

app-build-ios:
	cd app && flutter build ios --release

app-l10n:
	cd app && flutter gen-l10n

app-analyze:
	cd app && flutter analyze

app-test:
	cd app && flutter test

# ── Server (Go) ────────────────────────────────────────────
server:
	cd server && go run ./cmd/api

server-build:
	cd server && go build -o bin/api ./cmd/api

server-test:
	cd server && go test ./...

server-lint:
	cd server && golangci-lint run

server-tidy:
	cd server && go mod tidy

# ── Combined ───────────────────────────────────────────────
dev:
	@make -j2 server app

test:
	@make app-test
	@make server-test

lint:
	@make app-analyze
	@make server-lint
