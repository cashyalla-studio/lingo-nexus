# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this monorepo.

## Repository Structure

```
lingo_nexus/
  app/      ← Flutter 앱 (Android / iOS / macOS / Web)
  server/   ← Go API 서버
  docs/     ← 공유 문서
  Makefile  ← 루트 편의 명령
```

## Commands

### Flutter App (`cd app` 필수)

```bash
# 실행
flutter run -d android
flutter run -d ios
flutter run -d macos

# 빌드
flutter build apk
flutter build ios

# 분석 / 테스트
flutter analyze
flutter test
flutter test test/path/to/test_file.dart

# 다국어 파일 재생성 (.arb 수정 후)
flutter gen-l10n
```

### Go Server (`cd server` 필수)

```bash
# 개발 실행
go run ./cmd/api

# 빌드
go build -o bin/api ./cmd/api

# 테스트
go test ./...

# 의존성 정리
go mod tidy
```

### 루트 Makefile 단축키

```bash
make app           # Flutter Android 실행
make server        # Go 서버 실행
make dev           # 서버 + 앱 동시 실행
make test          # 전체 테스트
make app-l10n      # 다국어 파일 재생성
```

## App Architecture (Flutter)

LingoNexus는 오디오 쉐도잉 + AI 튜터 언어 학습 앱입니다. 상태 관리는 **Riverpod** 사용.

### Feature Structure (`app/lib/features/`)

- **player** - 핵심 오디오 재생. `AudioEngine`이 `just_audio`의 `AudioPlayer`를 싱글턴 Riverpod `Provider`로 래핑. `currentStudyItemProvider`가 전역 "지금 재생 중" 상태.
- **scanner** - 로컬 디렉터리에서 `.mp3/.m4a/.wav` + 동일 이름 `.txt` 대본을 `StudyItem`으로 페어링.
- **sync** - `AutoSyncService`가 스크립트 + 오디오 길이로 문장 단위 `SyncItem` 타임스탬프 생성.
- **tutor** - `LlmService`가 OpenAI / Google Gemini REST API 직접 호출.
- **shadowing** - `ShadowingStudioScreen` 녹음/쉐도잉 연습.
- **library** - `LibrarySheet` 모달 바텀 시트.
- **home** - `MainNavigationScreen` (BottomNavigationBar).
- **settings** - API 키 / 앱 언어 설정.
- **phonetics** - TTS 발음 연습, 최소쌍, 피치 악센트, 가나 드릴.
- **tutorial** - 첫 실행 온보딩 오버레이.

### Core (`app/lib/core/`)

- **providers/ai_provider.dart** - `AiProviderType` enum, `activeAiProvider`.
- **providers/locale_provider.dart** - 앱 언어 선택 (`LocaleNotifier`), SharedPreferences 저장.
- **services/secure_storage_service.dart** - API 키 저장 (`flutter_secure_storage`).
- **services/streak_service.dart** - 연속 학습 스트릭 (SharedPreferences).
- **tutorial/tutorial_provider.dart** - 튜토리얼 단계 상태.
- **models/study_item.dart** - `StudyItem(title, audioPath, scriptPath?)`.
- **theme/app_theme.dart** - 다크 테마 전용.

### Localization

ARB 소스: `app/lib/l10n/app_<locale>.arb`. 생성 코드: `app/lib/generated/l10n/`.
지원 로케일: ko, ja, zh(CN/TW), en(US/GB/AU), de, es, pt, ar, he, fr(FR/CA).
`.arb` 수정 후 반드시 `flutter gen-l10n` 실행.

### Key Patterns

- 모든 Provider는 파일 최상단에 정의, `ref.watch`/`ref.read`로 소비.
- API 키는 코드에 절대 하드코딩 금지 — `SecureStorageService` 경유.
- 모든 사용자 노출 텍스트는 l10n ARB 키 사용 (하드코딩 금지).
- Android safe area: `SafeArea(top: false)` 래핑, 모달은 `useSafeArea: true`.

## Server Architecture (Go)

```
server/
  cmd/api/main.go          ← 진입점, HTTP 서버, 라우터 설정
  internal/
    handler/               ← HTTP 핸들러
    model/                 ← 도메인 모델 (struct)
    service/               ← 비즈니스 로직
    middleware/            ← 공통 미들웨어
  go.mod
```

- 라우터: `github.com/go-chi/chi/v5`
- CORS: `github.com/go-chi/cors`
- 포트: 환경변수 `PORT` (기본 8080)
- 패키지 경로: `github.com/liel/lingo-nexus-server`

## Tutorial Rule

**신규 기능 추가 또는 기존 기능 대폭 수정 시, `app/lib/core/tutorial/tutorial_state.dart`의 `tutorialSteps`를 반드시 함께 업데이트할 것.**
