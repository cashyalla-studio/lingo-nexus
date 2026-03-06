# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on macOS (primary platform)
flutter run -d macos

# Run on iOS simulator
flutter run -d ios

# Build
flutter build macos
flutter build ios

# Analyze and lint
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Regenerate localization files after editing .arb files
flutter gen-l10n
```

## Architecture

LingoNexus is a Flutter language learning app (audio shadowing + AI tutor). State management uses **Riverpod** throughout.

### Feature Structure (`lib/features/`)

- **player** - Core audio playback. `AudioEngine` wraps `just_audio`'s `AudioPlayer` as a singleton Riverpod `Provider`. `PlayerProvider` exposes streams (`isPlayingProvider`, `playbackSpeedProvider`, `loopModeProvider`). `currentStudyItemProvider` is a `StateProvider<StudyItem?>` that acts as the global "now playing" state.
- **scanner** - `DirectoryScannerService` lets users pick a local directory, then pairs `.mp3/.m4a/.wav` audio files with same-named `.txt` script files into `StudyItem` objects.
- **sync** - `AutoSyncService` generates sentence-level `SyncItem` timestamps from a script + audio duration (currently uses character-count proportional approximation; architecture is designed to swap in Whisper/ML later).
- **tutor** - `LlmService` calls OpenAI (`gpt-4o-mini`) or Google Gemini (`gemini-1.5-flash`) REST APIs directly via `http`. Claude support is stubbed. `grammarExplanationProvider` is a `FutureProvider.family<String, String>` keyed by the selected sentence.
- **shadowing** - `ShadowingStudioScreen` for recording/shadowing practice (UI shell; recording not yet wired up).
- **library** - `LibrarySheet` shows the scanned study item list as a modal bottom sheet.
- **home** - `MainNavigationScreen` with a `BottomNavigationBar`; Library tab opens as a full-screen modal.
- **settings** - `ApiKeySettingsSheet` for inputting provider API keys stored via `flutter_secure_storage`.
- **intro** - Entry screen (`IntroScreen`).

### Core (`lib/core/`)

- **providers/ai_provider.dart** - `AiProviderType` enum (`google`, `openai`, `claude`). `activeAiProvider` (`StateNotifierProvider`) holds the selected AI. `currentApiKeyProvider` (`FutureProvider`) reads the correct key from secure storage based on the active provider.
- **services/secure_storage_service.dart** - Wraps `flutter_secure_storage` for persisting API keys.
- **services/llm_service.dart** - Raw HTTP calls to LLM APIs. One method: `askGrammar(type, apiKey, sentence)`.
- **models/study_item.dart** - `StudyItem(title, audioPath, scriptPath?)` — the fundamental data unit.
- **models/sync_item.dart** - `SyncItem(startTime, endTime, sentence)` — a timed sentence segment.
- **theme/app_theme.dart** - Dark theme only (`AppTheme.darkTheme`).

### Localization

ARB source files live in `lib/l10n/app_<locale>.arb`. Generated Dart code is in `lib/generated/l10n/`. Supported locales: ko, ja, zh, en (US/GB/AU), de, es, pt, ar, he, fr (FR/CA). After editing ARB files, run `flutter gen-l10n` to regenerate.

### Key Patterns

- All providers are defined at the top of their respective files and consumed via `ref.watch`/`ref.read` in widgets.
- `audioEngineProvider` is disposed via `ref.onDispose` to properly clean up the `AudioPlayer` instance.
- API keys are never stored in code — always fetched from `SecureStorageService` via `currentApiKeyProvider`.
