# LingoNexus — 전체 코드베이스 분석 문서

> 작성 기준일: 2026-03-15
> 대상: Flutter 앱(app/) + Go API 서버(server/) 전체

---

## 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [저장소 구조](#2-저장소-구조)
3. [서버 (Go)](#3-서버-go)
   - 3.1 [진입점 & 라우터](#31-진입점--라우터)
   - 3.2 [API 엔드포인트 전체 목록](#32-api-엔드포인트-전체-목록)
   - 3.3 [데이터 모델](#33-데이터-모델)
   - 3.4 [서비스 계층](#34-서비스-계층)
   - 3.5 [핸들러 계층](#35-핸들러-계층)
   - 3.6 [미들웨어](#36-미들웨어)
   - 3.7 [데이터베이스](#37-데이터베이스)
   - 3.8 [외부 AI 연동](#38-외부-ai-연동)
   - 3.9 [크레딧 과금 정책](#39-크레딧-과금-정책)
   - 3.10 [인증/토큰 정책](#310-인증토큰-정책)
4. [클라이언트 (Flutter)](#4-클라이언트-flutter)
   - 4.1 [진입점 & 앱 초기화](#41-진입점--앱-초기화)
   - 4.2 [패키지 의존성](#42-패키지-의존성)
   - 4.3 [핵심 모델](#43-핵심-모델)
   - 4.4 [코어 서비스](#44-코어-서비스)
   - 4.5 [코어 Provider](#45-코어-provider)
   - 4.6 [Feature: Player (오디오 재생)](#46-feature-player-오디오-재생)
   - 4.7 [Feature: Scanner (라이브러리 스캔)](#47-feature-scanner-라이브러리-스캔)
   - 4.8 [Feature: Sync (오토싱크)](#48-feature-sync-오토싱크)
   - 4.9 [Feature: Shadowing (쉐도잉 스튜디오)](#49-feature-shadowing-쉐도잉-스튜디오)
   - 4.10 [Feature: Phonetics (발음 훈련)](#410-feature-phonetics-발음-훈련)
   - 4.11 [Feature: Tutor (AI 튜터)](#411-feature-tutor-ai-튜터)
   - 4.12 [Feature: Library (라이브러리 시트)](#412-feature-library-라이브러리-시트)
   - 4.13 [Feature: Podcast (팟캐스트)](#413-feature-podcast-팟캐스트)
   - 4.14 [Feature: Conversation (AI 대화)](#414-feature-conversation-ai-대화)
   - 4.15 [Feature: Stats (학습 통계)](#415-feature-stats-학습-통계)
   - 4.16 [Feature: Settings (설정)](#416-feature-settings-설정)
   - 4.17 [Feature: Auth (인증)](#417-feature-auth-인증)
   - 4.18 [Feature: Tutorial (온보딩)](#418-feature-tutorial-온보딩)
   - 4.19 [Feature: Active Recall (복습)](#419-feature-active-recall-복습)
   - 4.20 [Feature: Bookmarks (즐겨찾기)](#420-feature-bookmarks-즐겨찾기)
   - 4.21 [Feature: Home (메인 네비게이션)](#421-feature-home-메인-네비게이션)
5. [로컬라이제이션](#5-로컬라이제이션)
6. [튜토리얼 시스템](#6-튜토리얼-시스템)
7. [클라이언트-서버 통신 규약](#7-클라이언트-서버-통신-규약)
8. [보안 정책](#8-보안-정책)
9. [핵심 아키텍처 패턴](#9-핵심-아키텍처-패턴)
10. [외부 서비스 통합 전체](#10-외부-서비스-통합-전체)
11. [주요 워크플로우](#11-주요-워크플로우)
12. [알려진 이슈 / TODO](#12-알려진-이슈--todo)
13. [환경 변수 & 설정](#13-환경-변수--설정)
14. [테스트 인프라](#14-테스트-인프라)

---

## 1. 프로젝트 개요

**LingoNexus**(앱 내 브랜드: "Scripta Sync")는 오디오 쉐도잉 + AI 튜터 기반의 언어 학습 앱이다.

| 구분 | 기술 스택 |
|------|----------|
| 모바일/데스크톱 앱 | Flutter 3.2+ (Dart 3.2+), Riverpod |
| API 서버 | Go, chi 라우터, MySQL |
| AI — 중국어 | Alibaba Qwen (qwen3-omni-flash, DashScope) |
| AI — 기타 언어 | Google Gemini 2.5 Flash Lite |
| 인증 | Google Sign-In + JWT |
| 결제 | 인앱 결제 (IAP) — 크레딧 팩 + 구독 |

**핵심 가치:**
- 자막 동기화된 오디오 청취 (타임스탬프 + 발음기호 + 번역 자동 생성)
- AI 발음/문법/어휘 교정
- 쉐도잉 정확도 평가 (accuracy / intonation / fluency)
- 14개 UI 언어, 9개 학습 언어

---

## 2. 저장소 구조

```
lingo_nexus/
├── app/                         ← Flutter 앱
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── config/          ← 서버 URL 등 설정
│   │   │   ├── models/          ← StudyItem, SyncItem, ChatMessage ...
│   │   │   ├── providers/       ← auth_provider, locale_provider, ai_provider
│   │   │   ├── services/        ← 모든 비즈니스 서비스
│   │   │   ├── theme/           ← 다크 테마
│   │   │   └── tutorial/        ← 튜토리얼 상태
│   │   ├── features/
│   │   │   ├── player/          ← 오디오 재생 엔진
│   │   │   ├── scanner/         ← 디렉터리 스캔 + 라이브러리
│   │   │   ├── sync/            ← 오토싱크 (전사+타임스탬프)
│   │   │   ├── shadowing/       ← 쉐도잉 스튜디오
│   │   │   ├── phonetics/       ← 발음 훈련 허브
│   │   │   ├── tutor/           ← AI 튜터 팝업
│   │   │   ├── library/         ← 라이브러리 바텀시트
│   │   │   ├── podcast/         ← 팟캐스트 구독
│   │   │   ├── conversation/    ← AI 대화
│   │   │   ├── stats/           ← 학습 통계/히트맵
│   │   │   ├── settings/        ← 설정 화면
│   │   │   ├── auth/            ← 로그인 화면
│   │   │   ├── home/            ← 메인 네비게이션
│   │   │   ├── tutorial/        ← 온보딩 오버레이
│   │   │   ├── active_recall/   ← 플래시카드 복습
│   │   │   └── bookmarks/       ← 오디오 즐겨찾기
│   │   ├── generated/l10n/      ← flutter gen-l10n 생성 코드
│   │   └── l10n/                ← ARB 소스 파일
│   ├── test/                    ← Flutter 테스트
│   └── pubspec.yaml
├── server/
│   ├── cmd/api/main.go          ← 서버 진입점
│   ├── internal/
│   │   ├── handler/             ← HTTP 핸들러
│   │   ├── model/               ← 도메인 모델
│   │   ├── service/             ← 비즈니스 로직
│   │   ├── middleware/          ← 인증 미들웨어
│   │   └── db/                  ← DB 연결
│   ├── testutil/                ← 테스트 헬퍼
│   └── go.mod
├── docs/                        ← 공유 문서 (이 파일 포함)
└── Makefile
```

---

## 3. 서버 (Go)

### 3.1 진입점 & 라우터

**`server/cmd/api/main.go`**

- 포트: 환경변수 `PORT` (기본 `8080`)
- 라우터: `github.com/go-chi/chi/v5`
- CORS: `github.com/go-chi/cors` — 모든 오리진 허용 (개발 설정)
- DB: MySQL (`internal/db/db.go` 연결 풀)

**서비스 초기화 순서:**
1. DB 연결 (`db.Open()`)
2. 서비스 인스턴스 생성 (`AuthService`, `CreditService`, `UsageService`, `LlmService`)
3. 핸들러 인스턴스 생성 (서비스 주입)
4. 라우터 설정 (공개 라우트 → 보호 라우트)
5. `http.ListenAndServe()`

**라우트 그룹:**
```
/ (public)
  GET  /health
  GET  /api/v1/ping
  POST /api/v1/auth/login
  POST /api/v1/auth/refresh

/api/v1 (protected - Auth middleware, 현재 테스트용으로 비활성화)
  GET  /user/me
  GET  /credits
  POST /credits/purchase
  GET  /credits/products
  POST /tone/evaluate
  POST /sync/transcribe
  POST /sync/annotate
  POST /ai/grammar
  POST /ai/vocabulary
  POST /ai/chat
  POST /shadowing/score
  POST /content/import
  GET  /content/file/{fileID}/{filename}

/docs (개발 환경만)
  GET  /docs           ← Scalar UI API 문서
  GET  /openapi.yaml   ← OpenAPI 3.0 스펙
```

**Go 의존성 (`go.mod`):**

| 패키지 | 버전 | 용도 |
|--------|------|------|
| `github.com/go-chi/chi/v5` | v5.2.1 | HTTP 라우터 |
| `github.com/go-chi/cors` | v1.2.1 | CORS 처리 |
| `github.com/go-sql-driver/mysql` | v1.8.1 | MySQL 드라이버 |
| `github.com/golang-jwt/jwt/v5` | v5.2.2 | JWT 토큰 생성/검증 |

---

### 3.2 API 엔드포인트 전체 목록

#### 공개 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| `GET` | `/health` | 헬스 체크 |
| `GET` | `/api/v1/ping` | 핑 |
| `POST` | `/api/v1/auth/login` | Google 로그인 |
| `POST` | `/api/v1/auth/refresh` | 토큰 갱신 |

**`POST /api/v1/auth/login` 요청:**
```json
{
  "provider": "google",
  "id_token": "eyJ..."
}
```
**응답:**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "abc123...",
  "expires_in": 86400,
  "user": { "id": 1, "email": "...", "name": "...", "avatar_url": "..." }
}
```

**`POST /api/v1/auth/refresh` 요청:**
```json
{ "refresh_token": "abc123..." }
```

---

#### 보호 엔드포인트 (Bearer JWT 필요)

**사용자**

| 메서드 | 경로 | 설명 |
|--------|------|------|
| `GET` | `/api/v1/user/me` | 본인 프로필 조회 |

---

**크레딧**

| 메서드 | 경로 | 설명 |
|--------|------|------|
| `GET` | `/api/v1/credits` | 크레딧 상태 조회 |
| `POST` | `/api/v1/credits/purchase` | IAP 영수증으로 크레딧 지급 |
| `GET` | `/api/v1/credits/products` | 판매 상품 목록 |

**`GET /api/v1/credits` 응답:**
```json
{
  "balance": 3600,
  "balance_minutes": 60,
  "daily_free_used": 120,
  "daily_free_total": 180,
  "has_subscription": true,
  "subscription_plan": "pro",
  "expires_at": "2026-04-15T00:00:00Z"
}
```

**`POST /api/v1/credits/purchase` 요청:**
```json
{
  "product_id": "xyz.cashyalla.scrypta.sync.sub.pro",
  "receipt_data": "base64...",
  "platform": "android",
  "transaction_id": "GPA.1234"
}
```

---

**오디오 AI (크레딧 소진)**

| 메서드 | 경로 | 설명 |
|--------|------|------|
| `POST` | `/api/v1/tone/evaluate` | 중국어 성조 발음 평가 |
| `POST` | `/api/v1/sync/transcribe` | 오디오 전사 + 타임스탬프 + 발음기호 + 번역 |
| `POST` | `/api/v1/sync/annotate` | 문장 목록에 발음기호/번역 추가 (기기 STT 연동) |

**`POST /api/v1/tone/evaluate` 요청:**
```json
{
  "audio_base64": "base64...",
  "word": "你好",
  "pinyin": "nǐhǎo",
  "tone": "3-3",
  "language": "zh",
  "duration_ms": 800
}
```
**응답:**
```json
{
  "correct": true,
  "detected_pattern": "3-3",
  "score": 92,
  "feedback": "성조가 정확합니다."
}
```

**`POST /api/v1/sync/transcribe` 요청:**
```json
{
  "audio_base64": "base64...",
  "language": "ja",
  "duration_ms": 45000,
  "target_language": "ko"
}
```
**응답:**
```json
{
  "script": "全文 스크립트...",
  "sync_items": [
    {
      "start_ms": 0,
      "end_ms": 3200,
      "sentence": "こんにちは",
      "phonetics": "コンニチワ",
      "translation": "안녕하세요"
    }
  ]
}
```

**`POST /api/v1/sync/annotate` 요청:**
```json
{
  "sentences": ["こんにちは", "ありがとう"],
  "language": "ja",
  "target_language": "ko"
}
```
**응답:**
```json
[
  { "phonetics": "コンニチワ", "translation": "안녕하세요" },
  { "phonetics": "アリガトウ", "translation": "감사합니다" }
]
```

---

**텍스트 AI (인증된 사용자 무료)**

| 메서드 | 경로 | 설명 |
|--------|------|------|
| `POST` | `/api/v1/ai/grammar` | 문법 설명 |
| `POST` | `/api/v1/ai/vocabulary` | 어휘/표현 설명 |
| `POST` | `/api/v1/ai/chat` | 멀티턴 대화 |

**`POST /api/v1/ai/grammar` 요청:**
```json
{
  "sentence": "彼女が来なかったのは病気だったからです。",
  "ui_language": "ko"
}
```
**응답:** `{ "reply": "이 문장은 ~のは~からです 구문으로..." }`

**`POST /api/v1/ai/vocabulary` 요청:**
```json
{
  "word": "のに",
  "context": "彼女が来ないのに怒っている",
  "ui_language": "ko"
}
```

**`POST /api/v1/ai/chat` 요청:**
```json
{
  "messages": [
    { "role": "user", "content": "こんにちは" },
    { "role": "assistant", "content": "こんにちは！" }
  ],
  "system_prompt": "You are a Japanese language tutor..."
}
```

---

**쉐도잉 평가**

| 메서드 | 경로 | 설명 |
|--------|------|------|
| `POST` | `/api/v1/shadowing/score` | 쉐도잉 녹음 채점 |

**요청:**
```json
{
  "audio_base64": "base64...",
  "original_text": "こんにちは、元気ですか？",
  "language": "ja"
}
```
**응답:**
```json
{
  "accuracy": 85,
  "intonation": 78,
  "fluency": 82,
  "transcription": "こんにちわ、元気ですか",
  "incorrect_words": ["こんにちわ"],
  "feedback": "「こんにちは」의 발음을 주의하세요."
}
```

---

**콘텐츠 임포트**

| 메서드 | 경로 | 설명 |
|--------|------|------|
| `POST` | `/api/v1/content/import` | URL에서 오디오 다운로드 (yt-dlp) |
| `GET` | `/api/v1/content/file/{fileID}/{filename}` | 다운로드된 파일 서빙 |

**`POST /api/v1/content/import` 요청:**
```json
{
  "url": "https://www.youtube.com/watch?v=...",
  "language": "ja",
  "title": "일본어 뉴스"
}
```
**응답:**
```json
{
  "title": "일본어 뉴스",
  "audio_url": "/api/v1/content/file/abc123/audio.mp3",
  "file_id": "abc123",
  "duration_ms": 180000
}
```

---

### 3.3 데이터 모델

**`server/internal/model/`**

#### 사용자 & 인증

```go
// model/user.go
type User struct {
    ID         int64
    Email      string
    Name       string
    AvatarURL  string
    Provider   string   // "google"
    ProviderID string   // Google subject
    CreatedAt  time.Time
    UpdatedAt  time.Time
}

type AuthRequest struct {
    Provider    string `json:"provider"`
    IDToken     string `json:"id_token"`
    AccessToken string `json:"access_token,omitempty"`
}

type AuthResponse struct {
    AccessToken  string `json:"access_token"`
    RefreshToken string `json:"refresh_token"`
    ExpiresIn    int    `json:"expires_in"`
    User         *User  `json:"user"`
}
```

#### 오디오 처리

```go
// model/transcribe.go
type ToneEvalRequest struct {
    AudioBase64 string  `json:"audio_base64"`
    Word        string  `json:"word"`
    Pinyin      string  `json:"pinyin"`
    Tone        string  `json:"tone"`
    Language    string  `json:"language"`
    DurationMs  int     `json:"duration_ms"`
}

type ToneEvalResponse struct {
    Correct         bool    `json:"correct"`
    DetectedPattern string  `json:"detected_pattern"`
    Score           int     `json:"score"`
    Feedback        string  `json:"feedback"`
}

type TranscribeRequest struct {
    AudioBase64    string `json:"audio_base64"`
    Language       string `json:"language"`
    DurationMs     int    `json:"duration_ms"`
    TargetLanguage string `json:"target_language"`
}

type TranscribeSyncItem struct {
    StartMs     int    `json:"start_ms"`
    EndMs       int    `json:"end_ms"`
    Sentence    string `json:"sentence"`
    Phonetics   string `json:"phonetics"`
    Translation string `json:"translation"`
}

type TranscribeResponse struct {
    Script    string               `json:"script"`
    SyncItems []TranscribeSyncItem `json:"sync_items"`
}

type AnnotateRequest struct {
    Sentences      []string `json:"sentences"`
    Language       string   `json:"language"`
    TargetLanguage string   `json:"target_language"`
}

type AnnotationItem struct {
    Phonetics   string `json:"phonetics"`
    Translation string `json:"translation"`
}
```

#### AI & 콘텐츠

```go
// model/ai.go
type AIChatMessage struct {
    Role    string `json:"role"`
    Content string `json:"content"`
}

type ChatRequest struct {
    Messages     []AIChatMessage `json:"messages"`
    SystemPrompt string          `json:"system_prompt"`
}

type AskGrammarRequest struct {
    Sentence   string `json:"sentence"`
    UILanguage string `json:"ui_language"`
}

type AskVocabularyRequest struct {
    Word       string `json:"word"`
    Context    string `json:"context"`
    UILanguage string `json:"ui_language"`
}

type TextAIResponse struct {
    Reply string `json:"reply"`
}

// model/shadowing.go
type ShadowingScoreRequest struct {
    AudioBase64  string `json:"audio_base64"`
    OriginalText string `json:"original_text"`
    Language     string `json:"language"`
}

type ShadowingScoreResponse struct {
    Accuracy        int      `json:"accuracy"`
    Intonation      int      `json:"intonation"`
    Fluency         int      `json:"fluency"`
    Transcription   string   `json:"transcription"`
    IncorrectWords  []string `json:"incorrect_words"`
    Feedback        string   `json:"feedback"`
}

// model/content.go
type ContentImportRequest struct {
    URL      string `json:"url"`
    Language string `json:"language"`
    Title    string `json:"title"`
}

type ContentImportResponse struct {
    Title    string `json:"title"`
    AudioURL string `json:"audio_url"`
    FileID   string `json:"file_id"`
    Duration int    `json:"duration_ms"`
}
```

#### 크레딧 & 사용량

```go
// model/credit.go
type CreditAccount struct {
    UserID           int64
    Balance          int       // 초 단위
    DailyFreeUsed    int       // 당일 무료 사용 초
    DailyFreeResetAt time.Time
    UpdatedAt        time.Time
}

type CreditTransaction struct {
    ID          int64
    UserID      int64
    Amount      int    // 양수: 충전, 음수: 차감
    Type        string // "purchase" | "subscription" | "daily_free" | "usage"
    Description string
    ProductID   string
    CreatedAt   time.Time
}

type Subscription struct {
    ID                    int64
    UserID                int64
    Plan                  string    // "basic" | "pro" | "premium"
    CreditsPerMonth       int
    StartedAt             time.Time
    ExpiresAt             time.Time
    Platform              string    // "ios" | "android"
    OriginalTransactionID string
    CreatedAt             time.Time
}

type CreditStatusResponse struct {
    Balance          int       `json:"balance"`
    BalanceMinutes   int       `json:"balance_minutes"`
    DailyFreeUsed    int       `json:"daily_free_used"`
    DailyFreeTotal   int       `json:"daily_free_total"`
    HasSubscription  bool      `json:"has_subscription"`
    SubscriptionPlan string    `json:"subscription_plan"`
    ExpiresAt        time.Time `json:"expires_at,omitempty"`
}

type PurchaseRequest struct {
    ProductID     string `json:"product_id"`
    ReceiptData   string `json:"receipt_data"`
    Platform      string `json:"platform"`
    TransactionID string `json:"transaction_id"`
}

type InAppProduct struct {
    ID             string
    Type           string // "credits" | "subscription"
    Credits        int
    CreditsPerMonth int
    Plan           string
}

// model/usage.go
type LLMUsage struct {
    Provider     string
    Model        string
    InputTokens  int
    OutputTokens int
}

type UsageLog struct {
    ID            int64
    UserID        int64
    Endpoint      string
    Provider      string
    Model         string
    Language      string
    InputTokens   int
    OutputTokens  int
    DurationMs    int
    ResultPreview string // 500자 truncate
    Error         string
    CreatedAt     time.Time
}
```

---

### 3.4 서비스 계층

#### LLM 서비스 (`service/llm_service.go`)

AI 공급자를 언어에 따라 라우팅한다.

**라우팅 규칙:**

| 학습 언어 | AI 공급자 | 모델 |
|----------|----------|------|
| `zh`, `zh-CN`, `zh-TW`, `cmn` 등 | Alibaba Qwen (DashScope) | `qwen3-omni-flash` |
| 그 외 모든 언어 | Google Gemini | `gemini-2.5-flash-lite` |

**공개 메서드:**

```go
func (s *LlmService) EvaluateTone(ctx, req *ToneEvalRequest) (*ToneEvalResponse, *LLMUsage, error)
    // 중국어 성조 평가 (오디오 입력 필요 → Qwen)
    // 프롬프트: "오디오의 성조가 {tone}인지 평가, JSON 반환"
    // 반환 JSON: {correct, detected_pattern, score, feedback}

func (s *LlmService) Transcribe(ctx, req *TranscribeRequest) (*TranscribeResponse, *LLMUsage, error)
    // 오디오 → 전사 + 타임스탬프 + 발음기호 + 번역
    // 중국어: Qwen 멀티모달, 기타: Gemini
    // 반환 JSON: {sentences: [{start_ms, end_ms, sentence, phonetics, translation}]}

func (s *LlmService) AnnotateTranscription(ctx, sentences, lang, targetLang) ([]AnnotationItem, *LLMUsage, error)
    // 텍스트 전용 — 기기 STT 결과에 발음기호+번역 추가
    // 항상 Gemini (텍스트만)
    // 반환 JSON: {annotations: [{phonetics, translation}]}

func (s *LlmService) AskGrammar(ctx, sentence, uiLang) (string, *LLMUsage, error)
    // 문법 설명 — Gemini 텍스트

func (s *LlmService) AskVocabulary(ctx, word, context, uiLang) (string, *LLMUsage, error)
    // 어휘 설명 — Gemini 텍스트

func (s *LlmService) Chat(ctx, messages, systemPrompt) (string, *LLMUsage, error)
    // 멀티턴 대화 — Gemini 텍스트
```

**Qwen API 호출 방식:**
```
POST https://dashscope-intl.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation
Authorization: Bearer {QWEN_API_KEY}

Body:
{
  "model": "qwen3-omni-flash",
  "input": {
    "messages": [
      {
        "role": "user",
        "content": [
          { "audio": "data:audio/mp3;base64,{base64}" },
          { "text": "{prompt}" }
        ]
      }
    ]
  },
  "parameters": { "result_format": "message" }
}
```
> OpenAI 호환 엔드포인트는 오디오 입력 미지원 → 네이티브 멀티모달 API 사용

**Gemini API 호출 방식:**
```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key={GEMINI_API_KEY}

Body:
{
  "contents": [
    {
      "role": "user",
      "parts": [
        { "inline_data": { "mime_type": "audio/mp3", "data": "{base64}" } },
        { "text": "{prompt}" }
      ]
    }
  ]
}
```
- 토큰 카운트: `usageMetadata.promptTokenCount` / `candidatesTokenCount`

---

#### 인증 서비스 (`service/auth_service.go`)

```go
func (s *AuthService) LoginWithGoogle(ctx, idToken) (*AuthResponse, error)
    1. https://oauth2.googleapis.com/tokeninfo?id_token={token} 검증
    2. 이메일/이름/아바타 추출
    3. DB UPSERT users (신규 시 credit_accounts 생성)
    4. JWT access token (24h, HS256) 발급
    5. Refresh token (랜덤 32바이트) 생성 → SHA256 해시 → DB 저장
    6. AuthResponse 반환

func (s *AuthService) RefreshAccessToken(ctx, refreshToken) (*AuthResponse, error)
    1. SHA256(refreshToken) → DB 조회
    2. 만료 확인
    3. 토큰 로테이션: 구 토큰 삭제 + 신규 발급
    4. AuthResponse 반환

func (s *AuthService) ValidateAccessToken(tokenStr) (userID int64, error)
    1. jwt.ParseWithClaims(HS256)
    2. "sub" 클레임 → userID 반환
```

**JWT 구조:**
```json
{
  "sub": "123",
  "iat": 1710000000,
  "exp": 1710086400
}
```

---

#### 크레딧 서비스 (`service/credit_service.go`)

```go
func (s *CreditService) GetStatus(ctx, userID) (*CreditStatusResponse, error)
    - 잔액, 일일 무료 사용량, 구독 정보 조회

func (s *CreditService) CheckAndDeductAudio(ctx, userID, durationMs) error
    트랜잭션 내:
    1. credit_accounts WHERE id=userID FOR UPDATE (비관적 잠금)
    2. 날짜 바뀌면 daily_free_used = 0 리셋
    3. 무료 할당량 우선 소진 (DailyFreeSeconds = 180초)
    4. 잔여는 balance에서 차감 (BillingIncrementSec = 6초 단위 올림)
    5. 잔액 부족 시 402 에러 반환
    6. CreditTransaction 기록

func (s *CreditService) AddCreditsFromPurchase(ctx, userID, req *PurchaseRequest) error
    1. 상품 카탈로그에서 productID 조회
    2. credits 팩: balance += product.Credits
    3. subscription: subscriptions 레코드 생성 + monthly credits 지급
    4. CreditTransaction 기록

func (s *CreditService) GetProducts() []InAppProduct
    // 상품 카탈로그 반환 (하드코딩)
```

**상품 카탈로그:**

| 상품 ID | 종류 | 크레딧/초 |
|---------|------|----------|
| `xyz.cashyalla.scrypta.sync.credits.c10` | 크레딧 팩 | 600초 (10분) |
| `xyz.cashyalla.scrypta.sync.credits.c130` | 크레딧 팩 | 7,800초 (130분) |
| `xyz.cashyalla.scrypta.sync.credits.c1500` | 크레딧 팩 | 90,000초 (1,500분) |
| `xyz.cashyalla.scrypta.sync.sub.basic` | 구독 | 18,000초/월 (300분) |
| `xyz.cashyalla.scrypta.sync.sub.pro` | 구독 | 60,000초/월 (1,000분) |
| `xyz.cashyalla.scrypta.sync.sub.premium` | 구독 | 180,000초/월 (3,000분) |

---

#### 사용량 로그 서비스 (`service/usage_service.go`)

```go
func (s *UsageService) LogAsync(userID, endpoint, language, usage *LLMUsage, durationMs, resultPreview, errStr)
    // 비동기 goroutine (fire-and-forget)
    // llm_usage_logs 테이블에 INSERT
    // resultPreview는 500자로 잘라 저장
```

---

### 3.5 핸들러 계층

**`server/internal/handler/`**

각 핸들러는 서비스 포인터를 필드로 갖는 구조체다.

#### `auth_handler.go`
```go
type AuthHandler struct { authSvc *service.AuthService }
func (h *AuthHandler) Login(w, r)   // POST /auth/login
func (h *AuthHandler) Refresh(w, r) // POST /auth/refresh
func (h *AuthHandler) GetMe(w, r)   // GET  /user/me
```

#### `tone_handler.go`
```go
type ToneHandler struct { llmSvc, creditSvc, usageSvc }
func (h *ToneHandler) Evaluate(w, r)
    1. JSON decode ToneEvalRequest
    2. (TODO) CheckAndDeductAudio
    3. llmSvc.EvaluateTone()
    4. usageSvc.LogAsync()
    5. JSON encode ToneEvalResponse
```

#### `transcribe_handler.go`
```go
type TranscribeHandler struct { llmSvc, creditSvc, usageSvc }
func (h *TranscribeHandler) Transcribe(w, r) // POST /sync/transcribe
func (h *TranscribeHandler) Annotate(w, r)   // POST /sync/annotate
```

#### `ai_handler.go`
```go
type AIHandler struct { llmSvc, usageSvc }
func (h *AIHandler) Grammar(w, r)    // POST /ai/grammar
func (h *AIHandler) Vocabulary(w, r) // POST /ai/vocabulary
func (h *AIHandler) Chat(w, r)       // POST /ai/chat
```

#### `credit_handler.go`
```go
type CreditHandler struct { creditSvc }
func (h *CreditHandler) GetStatus(w, r)  // GET  /credits
func (h *CreditHandler) Purchase(w, r)   // POST /credits/purchase
func (h *CreditHandler) GetProducts(w, r) // GET /credits/products
```

#### `shadowing_handler.go`
```go
type ShadowingHandler struct { llmSvc, creditSvc, usageSvc }
func (h *ShadowingHandler) Score(w, r) // POST /shadowing/score
    1. JSON decode ShadowingScoreRequest
    2. llmSvc.Transcribe() → 전사
    3. 단어 단위 정확도 계산
    4. JSON encode ShadowingScoreResponse
```

#### `annotate_handler.go`
```go
type AnnotateHandler struct { llmSvc, usageSvc }
func (h *AnnotateHandler) Annotate(w, r) // POST /sync/annotate
```

#### `content_handler.go`
```go
type ContentHandler struct { ... }
func (h *ContentHandler) Import(w, r)   // POST /content/import
    1. JSON decode ContentImportRequest
    2. exec.LookPath("yt-dlp") 확인
    3. yt-dlp로 오디오 다운로드 → 임시 파일
    4. fileID 생성
    5. JSON encode ContentImportResponse

func (h *ContentHandler) ServeFile(w, r) // GET /content/file/{fileID}/{filename}
    // 다운로드된 파일 서빙 (Range request 지원)
```

---

### 3.6 미들웨어

**`server/internal/middleware/auth.go`**

```go
func Auth(authSvc) func(http.Handler) http.Handler
    1. Authorization 헤더에서 Bearer 토큰 추출
    2. authSvc.ValidateAccessToken(token) → userID
    3. context.WithValue(r.Context(), "userID", userID)
    4. 실패 시 401 JSON 에러 응답
```

> **현재 상태:** `main.go`에서 미들웨어 적용이 주석 처리됨 (테스트 중)
> - `// r.Use(middleware.Auth(authSvc))` — 운영 전 반드시 재활성화

---

### 3.7 데이터베이스

**`server/internal/db/db.go`**

```go
func Open() (*sql.DB, error)
    DSN 조합:
      DATABASE_URL 환경변수 있으면 그대로 사용
      없으면: {MYSQL_USER}:{MYSQL_PASSWORD}@tcp({MYSQL_HOST}:{MYSQL_PORT})/{MYSQL_DATABASE}?charset=utf8mb4&parseTime=True&loc=UTC

    연결 풀 설정:
      MaxOpenConns: 25
      MaxIdleConns: 10
      ConnMaxLifetime: 5분
```

**MySQL 테이블 (추정):**
- `users` — 사용자 계정
- `refresh_tokens` — 리프레시 토큰 (SHA256 해시)
- `credit_accounts` — 사용자별 크레딧 잔액
- `credit_transactions` — 크레딧 입출금 내역
- `subscriptions` — 구독 정보
- `llm_usage_logs` — AI 사용 로그

---

### 3.8 외부 AI 연동

#### Alibaba Qwen (DashScope 국제 서버)

```
엔드포인트: https://dashscope-intl.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation
모델: qwen3-omni-flash
입력: 오디오 base64 (data URL) + 텍스트 프롬프트
인증: Authorization: Bearer {QWEN_API_KEY}
용도: 중국어 성조 평가, 중국어 전사
```

#### Google Gemini

```
엔드포인트: https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent
인증: ?key={GEMINI_API_KEY}
입력: 오디오 inline_data + 텍스트 (멀티모달) 또는 텍스트만
용도: 비중국어 전사, 문법/어휘/대화, 어노테이션
```

#### Google OAuth 토큰 검증

```
GET https://oauth2.googleapis.com/tokeninfo?id_token={token}
반환: email, name, picture, sub
```

#### yt-dlp (콘텐츠 임포트)

```
서버에 yt-dlp 바이너리 필요
exec.Command("yt-dlp", url, "-x", "--audio-format", "mp3", "-o", outputPath)
YouTube, SoundCloud 등 오디오 추출
```

---

### 3.9 크레딧 과금 정책

| 항목 | 값 |
|------|-----|
| 일일 무료 할당 | **180초 (3분)** |
| 과금 단위 | **6초 올림** |
| 업로드 최대 길이 | **600초 (10분)** |
| 잔액 단위 | 초(seconds) |

**계산 예시:**
- 17초 오디오 → 18초 청구 (6초 올림)
- 무료 잔여 120초 있을 때 200초 오디오 → 무료 120초 + 크레딧 80초 차감

---

### 3.10 인증/토큰 정책

| 항목 | 값 |
|------|-----|
| 알고리즘 | HS256 |
| Access Token 유효기간 | 24시간 |
| Refresh Token 유효기간 | 30일 |
| Refresh Token 저장 | SHA256 해시로 DB에 저장 |
| 토큰 로테이션 | 갱신 시 구 토큰 즉시 삭제 |

---

## 4. 클라이언트 (Flutter)

### 4.1 진입점 & 앱 초기화

**`app/lib/main.dart`**

```dart
void main() {
  runApp(ProviderScope(child: ScriptaSyncApp()));
}

class ScriptaSyncApp extends ConsumerWidget {
  // 로케일 Provider 감지 → MaterialApp.locale 업데이트
  // l10n delegates 설정
  // IntroScreen → _AppInit 로 전환
}

class _AppInit extends ConsumerStatefulWidget {
  initState():
    1. authProvider.restoreSession() — 저장된 토큰으로 자동 로그인
    2. studyItemsNotifier.initLibrary() — 저장된 경로 스캔
    3. FileOpenEventService.listen() — "다음으로 열기" 이벤트 처리
    4. TempCleanupService.cleanup() — 오래된 임시 파일 삭제
}
```

---

### 4.2 패키지 의존성

**`app/pubspec.yaml`**

| 카테고리 | 패키지 | 버전 | 용도 |
|----------|--------|------|------|
| 상태 관리 | `flutter_riverpod` | ^2.6.1 | Provider 패턴 |
| 보안 저장소 | `flutter_secure_storage` | ^10.0.0 | Keychain/Keystore |
| 로컬 저장소 | `shared_preferences` | ^2.3.0 | 설정/스트릭 |
| 오디오 재생 | `just_audio` | ^0.10.5 | AudioPlayer |
| 오디오 파형 | `audio_waveforms` | ^2.0.2 | 파형 시각화 |
| 오디오 녹음 | `record` | ^5.2.0 | 마이크 녹음 |
| TTS | `flutter_tts` | ^4.2.0 | 텍스트→음성 |
| STT | `speech_to_text` | ^7.0.0 | 기기 내장 STT (Android) |
| HTTP | `http` | ^1.3.0 | REST API 호출 |
| HTTP 파싱 | `http_parser` | ^4.1.2 | HTTP 파싱 |
| 경로 | `path_provider` | ^2.1.5 | 앱 디렉터리 |
| 파일 선택 | `file_picker` | ^10.3.10 | 파일/디렉터리 선택 |
| 경로 유틸 | `path` | ^1.9.1 | 경로 조작 |
| 폰트 | `google_fonts` | ^8.0.2 | Google Fonts |
| 공유 | `share_plus` | ^10.1.4 | 콘텐츠 공유 |
| Google 로그인 | `google_sign_in` | ^6.2.2 | OAuth 인증 |
| FFmpeg | `ffmpeg_kit_flutter_new` | ^4.1.0 | 오디오 변환 |
| 압축 | `archive` | ^4.0.2 | ZIP 처리 |
| 국제화 | `intl` | ^0.20.2 | l10n |
| 국제화 프레임워크 | `flutter_localizations` | SDK | l10n 지원 |

---

### 4.3 핵심 모델

**`app/lib/core/models/`**

#### StudyItem

```dart
class StudyItem {
  final String title;
  final String audioPath;
  final String? scriptPath;
  final StudyItemSource source;        // local | iCloud | googleDrive
  final Duration lastPosition;
  final Duration? totalDuration;
  final DateTime? lastPlayedAt;
  final List<SyncItem>? syncItems;
  final String? language;              // 학습 언어 코드

  // 계산 속성
  double get progressRatio            // 0.0 ~ 1.0
  Duration get progressTimeLeft
  bool get isCompleted                // progressRatio >= 0.95

  StudyItem copyWith({...})
}

enum StudyItemSource { local, iCloud, googleDrive }
```

#### SyncItem

```dart
class SyncItem {
  final Duration startTime;
  final Duration endTime;
  final String sentence;
  final String? phonetics;    // 발음기호 (pinyin/hiragana/IPA)
  final String? translation;  // 모국어 번역

  String get formattedTime    // "MM:SS" 형식
}
```

#### ChatMessage

```dart
class ChatMessage {
  final String role;     // "user" | "assistant"
  final String content;
}
```

#### 기타 모델

| 모델 | 위치 | 설명 |
|------|------|------|
| `BookmarkItem` | `core/models/` | 오디오 즐겨찾기 (position + note) |
| `LanguageOption` | `core/models/` | 학습 언어 메타데이터 (code, name, flag) |
| `PronunciationHistoryEntry` | `core/models/` | 쉐도잉 시도 기록 |
| `ShadowDeckItem` | `core/models/` | 플래시카드 항목 |

---

### 4.4 코어 서비스

**`app/lib/core/services/`**

#### SecureStorageService (`secure_storage_service.dart`)

```dart
class SecureStorageService {
  final FlutterSecureStorage _storage;

  Future<void> saveAccessToken(String token)
  Future<String?> getAccessToken()
  Future<void> saveRefreshToken(String token)
  Future<String?> getRefreshToken()
  Future<void> clearAuthTokens()
}

final secureStorageProvider = Provider((ref) => SecureStorageService());
```

#### LlmService (`llm_service.dart`)

```dart
class LlmService {
  // 서버 /api/v1/ai/* 엔드포인트 호출

  Future<String> askGrammar(String sentence, {String uiLang = 'ko'})
      → POST /api/v1/ai/grammar

  Future<String> askVocabulary(String word, String context, {String uiLang = 'ko'})
      → POST /api/v1/ai/vocabulary

  Future<String> chat(List<ChatMessage> messages, String newMessage, {String systemPrompt = ''})
      → POST /api/v1/ai/chat

  // 공통 내부 메서드
  Future<Map<String, dynamic>> _postText(String path, Map body)
      → AccessToken 가져와서 Bearer 헤더 추가
      → 30초 타임아웃
      → 401 → 인증 에러
      → 402 → 크레딧 부족 에러
}

final llmServiceProvider = Provider((ref) => LlmService(ref));
```

#### StreakService (`streak_service.dart`)

```dart
class StreakData {
  final int current;  // 현재 연속 일수
  final int longest;  // 최장 연속 일수
  final int totalDays; // 총 학습 일수
}

class StreakService {
  Future<StreakData> recordStudyToday()
      // 어제 학습 → 연속 +1
      // 오래됨 → 리셋 1
      // 오늘 이미 기록 → 유지
      // longest 갱신
      // totalDays +1

  Future<StreakData> getStreakData()
      // 2일 이상 미학습 시 current = 0

  // SharedPreferences 키:
  // 'streak_current', 'streak_last_date', 'streak_longest', 'streak_total_days'
}
```

#### ProgressService (`progress_service.dart`)

```dart
class ProgressService {
  // audioPath를 키로 SharedPreferences에 저장

  Future<void> saveProgress(String audioPath, Duration position, Duration total)
  Future<Map?> loadProgress(String audioPath)
      // → {position: Duration, lastPlayedAt: DateTime, totalDuration: Duration}

  Future<void> saveSyncItems(String audioPath, List<SyncItem> items)
  Future<List<SyncItem>?> loadSyncItems(String audioPath)

  Future<void> saveSpeed(String audioPath, double speed)
  Future<double> loadSpeed(String audioPath)  // 기본값 1.0

  Future<void> saveLanguage(String audioPath, String language)
  Future<String?> loadLanguage(String audioPath)
}
```

#### BookmarkService (`bookmark_service.dart`)

```dart
class BookmarkService {
  Future<void> addBookmark(String audioPath, Duration position, String note)
  Future<List<BookmarkItem>> getBookmarksForAudio(String audioPath)
  Future<void> removeBookmark(String id)
}
```

#### JournalService (`journal_service.dart`)

```dart
class JournalService {
  Future<void> recordActivity(String studiedTitle, int minutesStudied)
      // 날짜별 학습 분 기록 → 히트맵에 사용

  Future<Map<DateTime, int>> getActivityMap()
      // 날짜 → 학습 분 맵
}
```

#### LibraryPersistenceService (`library_persistence_service.dart`)

```dart
class LibraryPersistenceService {
  Future<List<String>> loadPaths()         // 이전 스캔 경로 목록
  Future<void> addPath(String dirPath)
  Future<void> removePath(String dirPath)

  // macOS 보안 범위 북마크
  Future<void> saveBookmark(String path, String bookmark)
  Future<Map<String, String>> loadBookmarks()  // path → bookmark
}
```

#### iCloudService (`icloud_service.dart`)

```dart
class iCloudService {
  // macOS iCloud Drive 네이티브 연동

  Future<Directory?> getContainerDirectory()
  Future<String?> createBookmark(String path)      // 보안 범위 북마크 생성
  Future<String?> resolveBookmark(String bookmark) // 경로 복원
  Future<void> stopAccessing(String path)          // 보안 범위 해제
}
```

#### GoogleDriveService (`google_drive_service.dart`)

```dart
class GoogleDriveService {
  // google_sign_in 토큰 사용 → Drive REST API v3

  Future<List<DriveFile>> listFiles(String parentId)
      // GET https://www.googleapis.com/drive/v3/files

  Future<File> downloadFile(String fileId, String filename)
      // GET https://www.googleapis.com/drive/v3/files/{fileId}?alt=media

  Future<String> createFolder(String parentId, String name)
      // POST https://www.googleapis.com/drive/v3/files
}
```

#### NativeSttService (`native_stt_service.dart`)

```dart
class NativeSttService {
  Future<bool> isAvailable(String language)
      // iOS: SFSpeechRecognizer.isAvailable(locale)
      // Android: speech_to_text.initialize()
      // 기타: false

  Future<String> transcribeFile(String audioPath, String language)
      // iOS: Objective-C 브릿지 → AVAudioEngine + SFSpeechRecognizer
      // Android: speech_to_text 플러그인
      // 반환 JSON:
      // {
      //   "text": "전체 텍스트",
      //   "segments": [
      //     {"word": "단어", "start_sec": 0.5, "end_sec": 1.2}
      //   ]
      // }
}
```

#### SrtParserService (`srt_parser_service.dart`)

```dart
class SrtParserService {
  List<SyncItem> parse(String srtContent)
      // SRT 포맷 파싱:
      // 1\n00:00:01,000 --> 00:00:03,500\n자막 텍스트\n
      // → List<SyncItem>
}
```

#### SubscriptionService (`subscription_service.dart`)

인앱 결제 처리 (IAP 영수증 검증 포함)

#### TempCleanupService (`temp_cleanup_service.dart`)

```dart
class TempCleanupService {
  Future<void> cleanup()
      // 임시 디렉터리에서 24시간 이상 된 파일 삭제
      // 대상: 녹음 파일, 다운로드된 콘텐츠
}
```

#### CacheService (`cache_service.dart`)

```dart
// 인메모리 + 디스크 캐시
// AI 응답 결과 캐싱 (동일 문장 재요청 방지)
```

---

### 4.5 코어 Provider

**`app/lib/core/providers/`**

#### AuthProvider (`auth_provider.dart`)

```dart
// 상태: AsyncValue<AuthUser?>
final authUserProvider = StateNotifierProvider<AuthUserNotifier, AsyncValue<AuthUser?>>

class AuthUserNotifier extends StateNotifier<AsyncValue<AuthUser?>> {
  Future<void> restoreSession()
      → authService.restoreSession()
      → 성공: state = AsyncData(user)
      → 실패: state = AsyncData(null)

  Future<void> signInWithGoogle()
      → authService.signInWithGoogle()
      → state = AsyncData(user)

  Future<void> signOut()
      → authService.signOut()
      → state = AsyncData(null)

  bool get isLoggedIn
  AuthUser? get user
}
```

**AuthService (`auth_service.dart`)**

```dart
class AuthService {
  Future<AuthUser> signInWithGoogle()
      1. GoogleSignIn(scopes: [email, profile, Drive.readonly]).signIn()
      2. account.authentication.idToken 획득
      3. POST /api/v1/auth/login {provider: "google", id_token: ...}
      4. secureStorage.saveAccessToken(accessToken)
      5. secureStorage.saveRefreshToken(refreshToken)
      6. AuthUser.fromJson(response["user"]) 반환

  Future<AuthUser?> restoreSession()
      1. secureStorage.getAccessToken()
      2. GET /api/v1/user/me (Bearer accessToken)
      3. 200 → AuthUser 반환
      4. 401 → refreshToken으로 갱신 시도
      5. 실패 → clearAuthTokens(), null 반환

  Future<void> signOut()
      1. GoogleSignIn().signOut()
      2. secureStorage.clearAuthTokens()

  Future<String?> getValidAccessToken()
      // 유효한 토큰 반환 또는 자동 갱신
}
```

**AuthUser 모델:**
```dart
class AuthUser {
  final int id;
  final String email;
  final String name;
  final String avatarUrl;

  factory AuthUser.fromJson(Map<String, dynamic> json)
}
```

#### LocaleProvider (`locale_provider.dart`)

```dart
class LocaleNotifier extends StateNotifier<Locale?> {
  Future<void> _load()
      // SharedPreferences 'app_locale' 키 로드
      // 형식: 'ko' 또는 'en_US'

  Future<void> setLocale(Locale? locale)
      // SharedPreferences 저장 + state 업데이트
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>

// 지원 로케일 목록:
const supportedLocales = [
  Locale('ko'),
  Locale('en', 'US'), Locale('en', 'GB'), Locale('en', 'AU'),
  Locale('ja'),
  Locale('zh', 'CN'), Locale('zh', 'TW'),
  Locale('de'),
  Locale('es'),
  Locale('pt'),
  Locale('fr', 'FR'), Locale('fr', 'CA'),
  Locale('ar'),
  Locale('he'),
]
```

#### AiProvider (`ai_provider.dart`)

```dart
enum AiProviderType { gemini, openai }

// 활성 AI 공급자 선택 (서버가 자동 라우팅하므로 클라이언트에서는 참조용)
final activeAiProvider = StateProvider<AiProviderType>
```

---

### 4.6 Feature: Player (오디오 재생)

**`app/lib/features/player/`**

#### AudioEngine

```dart
class AudioEngine {
  final AudioPlayer _player;  // just_audio

  // A-B 구간 반복
  Duration? _abStart, _abEnd;
  void setAbLoop(Duration start, Duration end)
  void clearAbLoop()
  bool get isAbLoopActive

  // 재생 제어
  Future<void> loadFile(String path)
  Future<void> togglePlayPause()
  Future<void> seek(Duration position)
  Future<void> skipForward([int seconds = 10])
  Future<void> skipBackward([int seconds = 10])
  Future<void> setSpeed(double speed)
  Future<void> toggleLoopMode()  // Off → One → All → Off
}

final audioEngineProvider = Provider<AudioEngine>
```

#### Player Providers

```dart
// 재생 상태 스트림
final isPlayingProvider = StreamProvider<bool>
    → audioEngine._player.playingStream

final playbackSpeedProvider = StreamProvider<double>
    → audioEngine._player.speedStream

final loopModeProvider = StreamProvider<LoopMode>
    → audioEngine._player.loopModeStream

final positionProvider = StreamProvider<Duration>
    → audioEngine._player.positionStream

final durationProvider = StreamProvider<Duration?>
    → audioEngine._player.durationStream

// 현재 재생 아이템
final currentStudyItemProvider = StateProvider<StudyItem?>

final currentScriptContentProvider = FutureProvider<String>
    // currentStudyItem.scriptPath → File.readAsString()

// 싱크 아이템
final currentSyncItemsProvider = StateProvider<List<SyncItem>>

// 현재 활성 문장 인덱스 (자동 하이라이팅)
final activeSentenceIndexProvider = Provider<int>
    // positionProvider + currentSyncItemsProvider 조합
    // syncItems.indexWhere(item => item.startTime <= pos < item.endTime)

// 재생 속도 제안
final speedUpgradeSuggestionProvider = Provider<bool>
    // progress >= 70% && speed < 1.25 → true (속도 올리기 제안)

// A-B 루프 상태
final abLoopProvider = StateNotifierProvider<AbLoopNotifier, AbLoopState>
class AbLoopNotifier extends StateNotifier<AbLoopState> {
  void setStart(Duration d)
  void setEnd(Duration d)
  void clear()
}

// 진행률 자동 저장 (5초마다)
final progressTrackingProvider = Provider<void>
    // position 스트림 구독
    // 5초마다: progressService.saveProgress()
    // 10초 청취 후: streakService.recordStudyToday()
    // 1분마다: journalService.recordActivity()

// 자동 다음 트랙 재생
final autoPlayNextProvider = Provider<void>
    // 트랙 완료 이벤트 감지
    // loopOne → 반복, loopAll → 다음 (순환), off → 다음 (없으면 정지)
```

#### Player Screen 주요 UI 요소

```dart
class PlayerScreen extends ConsumerStatefulWidget {
  // 파형 시각화: AnimatedWaveform + WaveformPainter
  // 스크립트 표시: 싱크 아이템 리스트 (activeSentenceIndex로 하이라이팅)
  // 속도 슬라이더: 0.5x ~ 3.0x
  // 루프 버튼: LoopMode 순환
  // A-B 버튼: 구간 설정/해제
  // 문장 탭 → AI 문법 설명 팝업 (TutorPopup)
  // 어휘 탭 → AI 어휘 설명 팝업
  // 쉐도잉 버튼 → ShadowingStudioScreen 이동
}
```

---

### 4.7 Feature: Scanner (라이브러리 스캔)

**`app/lib/features/scanner/`**

#### StudyItemsNotifier

```dart
class StudyItemsNotifier extends StateNotifier<AsyncValue<List<StudyItem>>> {

  Future<void> initLibrary()
      1. libraryPersistenceService.loadPaths() → 저장된 경로 목록
      2. macOS: 보안 범위 북마크 해석
      3. 각 경로 → directoryScannerService.scanDirectory()
      4. progressService.loadProgress() / loadSyncItems() / loadLanguage() 적용
      5. state = AsyncData(items)

  Future<void> pickAndScanDirectory()
      1. FilePicker.getDirectoryPath()
      2. scanDirectory(path)
      3. libraryPersistenceService.addPath(path)
      4. state 병합

  Future<void> syncFromICloud()
      1. iCloudService.getContainerDirectory()
      2. scanDirectory(iCloudPath)
      3. state 병합

  Future<void> removeDirectory(String path)
      // 해당 경로의 아이템 제거 + 경로 저장소에서 삭제

  Future<void> addItems(List<StudyItem> items)
      // 임포트된 아이템 병합 (audioPath 중복 제거)

  Future<void> attachScript(String audioPath, String scriptPath)
      // SyncItem 있으면 저장, scriptPath 업데이트

  Future<void> removeItem(String audioPath)

  Future<void> addSingleFile(String filePath)
      // "다음으로 열기" 이벤트 처리
      // 오디오 파일이면 StudyItem으로 래핑

  Future<void> updateItemProgress(String audioPath, Duration pos, Duration total)
  Future<void> setItemLanguage(String audioPath, String? language)
}

final studyItemsProvider = StateNotifierProvider<StudyItemsNotifier, AsyncValue<List<StudyItem>>>
```

#### DirectoryScannerService

```dart
class DirectoryScannerService {
  Future<List<StudyItem>> scanDirectory(String dirPath)
      // 확장자 필터: .mp3, .m4a, .wav, .flac, .aac, .ogg
      // 동일 이름 .txt 파일 → scriptPath로 페어링
      // .srt 파일 → SrtParserService로 파싱 → SyncItems 직접 적용
      // StudyItemSource.local로 생성
}
```

#### UrlImportService (`url_import_service.dart`)

```dart
class UrlImportService {
  Future<StudyItem> importFromUrl(String url, {String? language, String? title})
      // POST /api/v1/content/import
      // 응답의 audio_url로 파일 다운로드
      // StudyItem 생성 후 studyItemsNotifier.addItems()
}
```

#### SampleContentService (`sample_content_service.dart`)

```dart
class SampleContentService {
  Future<List<StudyItem>> loadSampleContent()
      // assets/data/ 에서 샘플 오디오+스크립트 로드
      // 앱 최초 실행 시 사용
}
```

---

### 4.8 Feature: Sync (오토싱크)

**`app/lib/features/sync/auto_sync_service.dart`**

두 가지 경로로 전사+싱크를 수행한다.

**경로 1: 기기 내장 STT (iOS/Android 우선)**

```dart
if (await nativeSttService.isAvailable(language)) {
  // 1. 기기 STT로 오디오 파일 전사
  String jsonResult = await nativeSttService.transcribeFile(audioPath, language);
  // 반환: {"text": "...", "segments": [{"word": ..., "start_sec": ..., "end_sec": ...}]}

  // 2. 단어 세그먼트를 문장 단위로 그루핑
  List<Sentence> sentences = _groupSegmentsIntoSentences(segments);
  // 그루핑 조건:
  //   a) 문장 부호로 끝남: . ? ! 。 ？ ！ …
  //   b) 다음 단어와 공백 > 0.8초
  //   c) 오디오 끝

  // 3. 서버에 발음기호+번역 요청
  List<AnnotationItem> annotations = await _fetchAnnotations(
    sentences.map((s) => s.text).toList(),
    language,
    targetLanguage,
  );
  // POST /api/v1/sync/annotate

  // 4. SyncItem 조합
  return sentences.zip(annotations).map((s, a) => SyncItem(
    startTime: s.start, endTime: s.end,
    sentence: s.text,
    phonetics: a.phonetics,
    translation: a.translation,
  )).toList();
}
```

**경로 2: 서버 전체 처리 (폴백)**

```dart
// 1. 오디오 파일 base64 인코딩
String base64Audio = base64Encode(await File(audioPath).readAsBytes());

// 2. 서버 전사 요청 (오디오 업로드)
TranscribeResponse response = await _transcribe(base64Audio, language, durationMs, targetLanguage);
// POST /api/v1/sync/transcribe

// 3. SyncItem 변환
return response.syncItems.map((item) => SyncItem(
  startTime: Duration(milliseconds: item.startMs),
  endTime: Duration(milliseconds: item.endMs),
  sentence: item.sentence,
  phonetics: item.phonetics,
  translation: item.translation,
)).toList();
```

**어노테이션 스크립트 생성:**

```dart
String generateAnnotatedScript(List<SyncItem> syncItems) {
  // 형식:
  // [00:15] こんにちは、元気ですか？
  //         コンニチワ、ゲンキデスカ？
  //         안녕하세요, 잘 지내세요?
}
```

---

### 4.9 Feature: Shadowing (쉐도잉 스튜디오)

**`app/lib/features/shadowing/shadowing_provider.dart`**

#### 상태 머신

```
idle → [startRecording] → recording → [stopRecording] → processing → [scoreComplete] → done
done → [reset] → idle (기록 유지)
done → [newSession] → idle (기록 초기화)
```

```dart
enum ShadowingState { idle, recording, processing, done }
enum ComparisonPlaybackMode { none, playingOriginal, playingRecording }
```

#### ShadowingNotifier

```dart
class ShadowingNotifier extends StateNotifier<ShadowingState> {

  Future<void> loadHistoryForSentence(String text)
      // PronunciationHistoryService.getHistory(SHA256(text))
      // _history 리스트 업데이트

  Future<void> startRecording()
      1. record.Record().start(path: tempPath, encoder: AudioEncoder.aacLc)
      2. state = ShadowingState.recording

  Future<void> stopRecording()
      1. record.stop()
      2. _recordingPath 저장
      3. state = ShadowingState.processing (잠깐)
      4. state = ShadowingState.idle (채점 대기)

  Future<ShadowingScore> scoreRecording(String originalText, String language)
      시도 1: 기기 STT (NativeSttService 이용 가능 시)
        a. transcribeFile(_recordingPath, language)
        b. JSON 파싱 → {text, segments}
        c. _calculateLocalScore(transcription, originalText) 적용
      시도 2: 서버 채점 (기기 STT 불가 또는 실패 시)
        a. base64 인코딩
        b. POST /api/v1/shadowing/score
        c. ShadowingScoreResponse 변환
      결과:
        _attemptCount++
        _bestScore 갱신
        PronunciationHistoryService.addEntry()
        state = ShadowingState.done

  Future<void> playRecording()
      AudioPlayer.setFilePath(_recordingPath).play()

  Future<void> playOriginalSegment(String audioPath, Duration start, Duration end)
      AudioPlayer.setClip(start, end).play()

  Future<void> playComparison()
      1. playOriginalSegment()
      2. await delay 600ms
      3. playRecording()
      (ComparisonPlaybackMode 업데이트)

  void reset()     // idle + 녹음파일 삭제 (기록 유지)
  void newSession() // idle + 기록 초기화
}
```

**로컬 채점 알고리즘:**

```dart
ShadowingScore _calculateLocalScore(String transcription, String original) {
  // 1. 소문자화 + 구두점 제거 + 토큰화
  List<String> origWords = tokenize(original);
  List<String> transWords = tokenize(transcription);

  // 2. 정확도: 일치 단어 수 / 원본 단어 수 * 100
  int matched = origWords.where((w) => transWords.contains(w)).length;
  int accuracy = (matched / origWords.length * 100).round();

  // 3. 유창성: 단어 수 비율 기반 (1에 가까울수록 좋음)
  double ratio = transWords.length / origWords.length;
  int fluency = (100 - (1.0 - ratio).abs() * 50).round().clamp(0, 100);

  // 4. 억양: (accuracy + fluency) / 2 (로컬에서는 추정)
  int intonation = ((accuracy + fluency) / 2).round();

  // 5. 틀린 단어 찾기
  List<String> incorrect = origWords.where((w) => !transWords.contains(w)).toList();

  return ShadowingScore(accuracy, intonation, fluency, transcription, incorrect);
}
```

**시도 제한:** `maxAttempts = 5` (세션당)

**이력 저장:**
```dart
PronunciationHistoryService.addEntry(PronunciationHistoryEntry(
  sentenceId: SHA256(sentence),
  sentence: sentence,
  accuracy: score.accuracy,
  intonation: score.intonation,
  fluency: score.fluency,
  recordedAt: DateTime.now(),
))
```

---

### 4.10 Feature: Phonetics (발음 훈련)

**`app/lib/features/phonetics/`**

#### PhoneticHub 화면 (`phonetics_hub_screen.dart`)

발음 훈련 메뉴 허브:

| 하위 기능 | 화면 | 설명 |
|----------|------|------|
| TTS 연습 | `tts_practice_screen.dart` | 단어 말하기 + TTS 비교 |
| 최소쌍 훈련 | `minimal_pair_screen.dart` (features/minimal_pair/) | 음소 대비 훈련 (예: /l/ vs /r/) |
| 피치 악센트 | `pitch_accent_screen.dart` | 일본어/중국어 성조·악센트 시각화 |
| 가나 드릴 | `kana_drill_screen.dart` | 히라가나/가타카나 인식 훈련 |
| IPA 참조 | (인라인) | 국제 음성 기호 표 |

#### TTS 연습 (`tts_practice_screen.dart`)

```dart
// FlutterTts로 목표 단어 재생
// 사용자가 말하면 STT로 인식 → 비교
// 점수 표시
```

#### 최소쌍 훈련 (`minimal_pair_screen.dart`)

```dart
// 두 단어 쌍 (예: "ship" vs "sheep")
// 랜덤으로 하나 TTS 재생
// 사용자가 어떤 단어인지 선택
// 정답률 추적
```

#### 피치 악센트 (`pitch_accent_screen.dart`)

```dart
// 중국어: 사성(1~4성) 피치 패턴 시각화
// 일본어: 어절 악센트 패턴 표시
// FlutterTts 재생 + 시각화 동시 제공
```

#### 가나 드릴 (`kana_drill_screen.dart`)

```dart
// 히라가나/가타카나 문자 플래시카드
// 로마자 입력 → 채점
// 틀린 문자 추가 반복
```

---

### 4.11 Feature: Tutor (AI 튜터)

**`app/lib/features/tutor/`**

플레이어 화면에서 문장 탭 시 팝업으로 동작한다.

```dart
class TutorPopup extends ConsumerWidget {
  final String sentence;
  final String? selectedWord;

  // 문법 설명 탭: llmServiceProvider.askGrammar(sentence)
  // 어휘 설명 탭: llmServiceProvider.askVocabulary(selectedWord, sentence)
  // 로딩 스피너 → 결과 텍스트 표시
  // 에러 시 재시도 버튼
}
```

---

### 4.12 Feature: Library (라이브러리 시트)

**`app/lib/features/library/library_sheet.dart`**

모달 바텀시트로 StudyItem 목록을 표시한다.

```dart
class LibrarySheet extends ConsumerWidget {
  // studyItemsProvider.when(loading/data/error)
  // 아이템 탭 → currentStudyItemProvider 업데이트 → PlayerScreen 이동
  // 슬라이드 삭제 → studyItemsNotifier.removeItem()
  // 디렉터리 추가 버튼 → pickAndScanDirectory()
  // 구글 드라이브 버튼 → GoogleDriveBrowserScreen
  // iCloud 버튼 → syncFromICloud()
  // 진행률 바 표시 (StudyItem.progressRatio)
  // 언어 선택 칩
}
```

**Google Drive 브라우저 (`google_drive_browser_screen.dart`):**

```dart
class GoogleDriveBrowserScreen extends ConsumerWidget {
  // googleDriveService.listFiles(folderId) → 파일/폴더 목록
  // 폴더 탭 → 하위 탐색
  // 파일 탭 → downloadFile() → StudyItem 생성
  // 이동 경로 표시 (Breadcrumbs)
}
```

---

### 4.13 Feature: Podcast (팟캐스트)

**`app/lib/features/podcast/`**

```dart
// RSS 피드 URL 구독
// 에피소드 목록 파싱
// 에피소드 다운로드 → 라이브러리 추가
// 에피소드 재생 (PlayerScreen으로 이동)
// 구독 목록 LocalStorage 저장
```

---

### 4.14 Feature: Conversation (AI 대화)

**`app/lib/features/conversation/conversation_screen.dart`**

```dart
class ConversationScreen extends ConsumerStatefulWidget {
  // 대화 히스토리: List<ChatMessage>
  // 사용자 입력 → llmService.chat(messages, newMessage, systemPrompt)
  // 스트리밍 미지원 (일괄 응답)
  // 대화 초기화 버튼
  // 시스템 프롬프트 설정 가능 (역할극/학습 모드)
}
```

---

### 4.15 Feature: Stats (학습 통계)

**`app/lib/features/stats/`**

```dart
class StatsScreen extends ConsumerWidget {
  // 학습 히트맵: journalService.getActivityMap()
  //   - 달력 형식으로 날짜별 학습 강도 시각화
  // 스트릭 표시: streakService.getStreakData()
  //   - 현재/최장/총계
  // 공유 카드: share_plus로 스크린샷 공유
  // 언어별 학습 시간 분포 (파이차트)
}

// stats_provider.dart (신규 파일)
final statsProvider = FutureProvider<StatsData>
    // journalService + streakService 조합
```

---

### 4.16 Feature: Settings (설정)

**`app/lib/features/settings/settings_screen.dart`**

```dart
// UI 언어 선택: localeProvider.setLocale()
// 구독/크레딧 관리: CreditStatusWidget
//   - GET /api/v1/credits → 잔액 표시
//   - GET /api/v1/credits/products → 상품 목록
//   - 구매 버튼 → subscriptionService.purchase()
// Google 계정 연결/해제
// 앱 버전 정보
// (레거시) AI API 키 직접 입력 칸 — 서버 기반으로 전환 후 deprecated
```

---

### 4.17 Feature: Auth (인증)

**`app/lib/features/auth/login_screen.dart`**

```dart
class LoginScreen extends ConsumerWidget {
  // Google 로그인 버튼
  // authProvider.signInWithGoogle()
  // 로딩 상태 표시
  // 에러 스낵바
  // 오프라인 사용 계속 버튼 (게스트 모드)
}
```

---

### 4.18 Feature: Tutorial (온보딩)

**`app/lib/core/tutorial/tutorial_state.dart`**

```dart
enum TutorialStep {
  importFile,       // 오디오 파일 가져오기
  playerControls,   // 플레이어 컨트롤 사용법
  aiTutor,          // AI 문법/어휘 설명
  phonetics,        // 발음 훈련 허브
  podcast,          // 팟캐스트 구독
  done,             // 완료
}

class TutorialStepData {
  final TutorialStep step;
  final String emoji;
  final String title;
  final String description;
  final String targetKey;  // 가리킬 위젯 GlobalKey
}

const List<TutorialStepData> tutorialSteps = [...]
```

**튜토리얼 Provider:**

```dart
final tutorialProvider = StateNotifierProvider<TutorialNotifier, TutorialStep?>
class TutorialNotifier extends StateNotifier<TutorialStep?> {
  Future<void> initialize()     // SharedPreferences에서 완료 여부 로드
  void nextStep()               // 다음 단계 진행
  void skipTutorial()           // 건너뛰기
  Future<void> resetTutorial()  // 재시작 (개발/설정에서)
}
```

> **규칙:** 신규 기능 추가 또는 기존 기능 대폭 수정 시 `tutorialSteps` 리스트 반드시 업데이트

---

### 4.19 Feature: Active Recall (복습)

**`app/lib/features/active_recall/active_recall_screen.dart`**

```dart
// ShadowDeckItem 기반 플래시카드 복습
// 앞면: 문장 (또는 단어)
// 뒷면: 발음기호 + 번역
// 자가 평가 (알았다 / 몰랐다)
// 복습 기록으로 다음 복습 예정 계산 (간격 반복 방식 간소화)
```

---

### 4.20 Feature: Bookmarks (즐겨찾기)

**`app/lib/features/bookmarks/bookmarks_screen.dart`**

```dart
// bookmarkService.getBookmarksForAudio(currentStudyItem.audioPath)
// 북마크 리스트 표시 (시간 + 메모)
// 탭 → 해당 위치로 seek
// 슬라이드 삭제 → bookmarkService.removeBookmark()
// 플레이어에서 북마크 추가 버튼
```

---

### 4.21 Feature: Home (메인 네비게이션)

**`app/lib/features/home/home_screen.dart`**

```dart
class MainNavigationScreen extends ConsumerStatefulWidget {
  // BottomNavigationBar 5개 탭:
  //   0. 라이브러리 (LibrarySheet 통합)
  //   1. 발음 (PhoneticHub)
  //   2. 대화 (ConversationScreen)
  //   3. 팟캐스트 (PodcastScreen)
  //   4. 설정 (SettingsScreen)

  // 현재 재생 중인 아이템 있으면 미니 플레이어 표시
  // 미니 플레이어 탭 → PlayerScreen으로 이동
}
```

---

## 5. 로컬라이제이션

**ARB 소스:** `app/lib/l10n/app_<locale>.arb`
**생성 코드:** `app/lib/generated/l10n/app_localizations_<locale>.dart`
**재생성 명령:** `flutter gen-l10n`

**지원 로케일 (14개):**

| 로케일 코드 | 언어 |
|------------|------|
| `ko` | 한국어 |
| `en_US`, `en_GB`, `en_AU` | 영어 (미국/영국/호주) |
| `ja` | 일본어 |
| `zh_CN`, `zh_TW` | 중국어 (간체/번체) |
| `de` | 독일어 |
| `es` | 스페인어 |
| `pt` | 포르투갈어 |
| `fr_FR`, `fr_CA` | 프랑스어 (프랑스/캐나다) |
| `ar` | 아랍어 |
| `he` | 히브리어 |

**규칙:**
- 모든 사용자 노출 텍스트는 ARB 키 사용 (하드코딩 금지)
- RTL 언어 (ar, he) 자동 지원 (Flutter MaterialApp)

---

## 6. 튜토리얼 시스템

6단계 온보딩 오버레이. 앱 최초 실행 시 표시되며 언제든 설정에서 재시작 가능.

| 단계 | 이름 | 대상 위젯 |
|------|------|----------|
| 1 | importFile | 파일 가져오기 버튼 |
| 2 | playerControls | 플레이어 컨트롤 영역 |
| 3 | aiTutor | 문장 탭 버튼 |
| 4 | phonetics | 발음 탭 |
| 5 | podcast | 팟캐스트 탭 |
| 6 | done | (완료) |

---

## 7. 클라이언트-서버 통신 규약

**Base URL 설정:**

```dart
// app/lib/core/config/server_config.dart
const String baseUrl = String.fromEnvironment(
  'SERVER_URL',
  defaultValue: 'http://localhost:8080',
);
// 빌드 시 오버라이드:
// flutter run --dart-define=SERVER_URL=https://api.example.com
```

**공통 헤더:**

```
Content-Type: application/json
Authorization: Bearer {accessToken}  ← 보호 엔드포인트
```

**에러 응답 형식:**

```json
{
  "error": "에러 메시지"
}
```

**HTTP 상태 코드 처리:**

| 코드 | 의미 | 클라이언트 처리 |
|------|------|---------------|
| 200 | 성공 | 정상 처리 |
| 401 | 인증 실패 | 토큰 갱신 시도 → 로그인 화면 |
| 402 | 크레딧 부족 | 구매 유도 다이얼로그 |
| 413 | 오디오 너무 큼 | 에러 스낵바 |
| 500 | 서버 에러 | 에러 스낵바 |

**타임아웃:** 30초 (텍스트 AI), 60초 (오디오 전사)

---

## 8. 보안 정책

### 토큰 관리

```
Access Token:
  - 저장소: FlutterSecureStorage (iOS Keychain, Android Keystore)
  - 형식: JWT HS256
  - 유효기간: 24시간

Refresh Token:
  - 저장소: FlutterSecureStorage
  - 서버 DB: SHA256 해시로 저장
  - 유효기간: 30일
  - 정책: 갱신 시 로테이션 (1회용)
```

### API 키 보안

- 클라이언트 앱에 AI API 키 **절대 하드코딩 금지**
- Gemini / Qwen / JWT_SECRET 모두 서버 환경변수
- 모든 LLM 호출은 서버를 통해 프록시

### 파일 경로 보안

- 콘텐츠 임포트: `{fileID}/{filename}` — path traversal 방지
- macOS iCloud: 보안 범위 북마크 (앱 샌드박스 준수)
- 임시 파일: 24시간 후 자동 삭제

### 인증 미들웨어 상태

> ⚠️ **현재:** `main.go`에서 Auth 미들웨어 **비활성화** (테스트 목적)
> 운영 배포 전 반드시 재활성화 필요

---

## 9. 핵심 아키텍처 패턴

### Riverpod 상태 관리

```dart
// Provider 종류별 사용 패턴

Provider<T>          // 불변 싱글턴 서비스
StateProvider<T>     // 단순 값 상태 (currentStudyItem 등)
StateNotifierProvider // 메서드 있는 복잡한 상태 (StudyItemsNotifier)
FutureProvider<T>    // 비동기 단일 값 (자동 로딩/에러 처리)
StreamProvider<T>    // 연속 스트림 (오디오 위치, 재생 상태)

// 소비 패턴
ref.watch(provider)  // 상태 변경 시 위젯 rebuild
ref.read(provider)   // 1회 읽기 (이벤트 핸들러에서)
ref.listen(provider, callback) // 사이드 이펙트

// AsyncValue 처리
provider.when(
  loading: () => CircularProgressIndicator(),
  data: (value) => Widget(value),
  error: (e, st) => ErrorWidget(e),
)
```

### 서비스 로케이터 패턴

```dart
// 모든 서비스는 최상위 Provider로 등록
final serviceProvider = Provider<MyService>((ref) => MyService(ref.read(depProvider)));

// 사용
final service = ref.read(serviceProvider);
```

### 단방향 데이터 흐름

```
User Action
    ↓
StateNotifier.method()
    ↓
Service.operation()
    ↓ (async)
state = newState
    ↓
UI rebuild (ref.watch)
```

### 플랫폼별 분기

```dart
if (Platform.isIOS) {
  // Swift 네이티브 브릿지
} else if (Platform.isAndroid) {
  // Android 플러그인
} else {
  // 기본 동작 또는 비활성화
}
```

### 오디오 파이프라인

```
파일 시스템 (mp3/m4a/wav)
    ↓ just_audio
AudioPlayer (싱글턴 Provider)
    ↓ Stream
positionStream → activeSentenceIndex → UI 하이라이팅
durationStream → 진행률 표시
playingStream → 재생 버튼 상태
```

---

## 10. 외부 서비스 통합 전체

| 서비스 | 사용 위치 | 인증 방식 | 용도 |
|--------|----------|----------|------|
| Google Sign-In | 클라이언트 → 서버 | OAuth 2.0 idToken | 사용자 인증 |
| Google Drive API v3 | 클라이언트 직접 | OAuth 2.0 accessToken | 파일 브라우징/다운로드 |
| Gemini 2.5 Flash Lite | 서버 | API Key | 텍스트/오디오 AI |
| Qwen3-omni-flash (DashScope) | 서버 | API Key | 중국어 오디오 AI |
| Google OAuth tokeninfo | 서버 | - | idToken 검증 |
| yt-dlp | 서버 (바이너리) | - | YouTube 오디오 추출 |
| MySQL | 서버 | DSN | 사용자/크레딧/로그 |
| iOS SFSpeechRecognizer | 앱 (네이티브) | - | 기기 STT |
| Android SpeechToText | 앱 (플러그인) | - | 기기 STT |
| macOS iCloud Drive | 앱 (네이티브) | 보안 범위 북마크 | 파일 동기화 |
| IAP (iOS/Android) | 앱 | 영수증 검증 | 크레딧 구매 |

---

## 11. 주요 워크플로우

### 워크플로우 1: 오디오 학습 전체 흐름

```
[파일 선택/임포트]
    FilePicker / Google Drive / iCloud / URL import
    ↓
[라이브러리 추가]
    StudyItemsNotifier.addItems()
    ↓
[오토싱크 실행]
    경로 1: NativeStt → Annotate API
    경로 2: Transcribe API (오디오 업로드)
    → SyncItem 목록 생성 (타임스탬프 + 발음기호 + 번역)
    ↓
[오디오 재생 & 스크립트 학습]
    PlayerScreen
    - 싱크 하이라이팅
    - 속도 조절
    - A-B 구간 반복
    - 문장 탭 → AI 문법/어휘 설명
    ↓
[쉐도잉 연습]
    ShadowingStudioScreen
    - 원본 재생 → 따라 말하기 녹음
    - 채점 (accuracy/intonation/fluency)
    - 비교 재생 (원본 → 녹음)
    - 이력 저장
```

### 워크플로우 2: 인증 & 크레딧 흐름

```
[앱 시작]
    restoreSession() → accessToken → /api/v1/user/me
    성공 → 로그인 상태
    실패 → refreshToken으로 갱신 시도
    최종 실패 → 게스트 모드 or 로그인 화면
    ↓
[오디오 AI 기능 사용 시]
    checkAndDeductAudio(durationMs)
    1. 일일 무료 (180초) 우선 차감
    2. 초과분 크레딧 차감
    3. 잔액 부족 → 402 → 구매 유도
    ↓
[IAP 구매]
    CreditHandler.Purchase()
    영수증 → 크레딧 지급 or 구독 생성
```

### 워크플로우 3: 발음 훈련 흐름

```
[PhoneticHub]
    ↓
    선택: TTS 연습 / 최소쌍 / 피치 악센트 / 가나 드릴
    ↓
[TTS 연습]
    FlutterTts.speak(word) → 들으면서 따라 말하기
    STT 인식 → 목표 단어와 비교
    ↓
[최소쌍]
    두 단어 무작위 재생 → 사용자 선택 → 정답 확인
    ↓
[통계 기록]
    JournalService.recordActivity()
    StreakService.recordStudyToday()
```

---

## 12. 알려진 이슈 / TODO

| 우선순위 | 위치 | 내용 |
|---------|------|------|
| **높음** | `server/cmd/api/main.go:56` | Auth 미들웨어 비활성화 — 운영 전 재활성화 필수 |
| **높음** | 각 핸들러 | 크레딧 차감 체크 일부 주석 처리 — 운영 전 재활성화 필수 |
| 중간 | `shadowing_provider.dart` | 억양(intonation) 점수 로컬 알고리즘 단순화 — 서버 채점 더 정확 |
| 중간 | `features/podcast/` | 팟캐스트 기능 미완성 (모델+서비스 있음, UI 부분 구현) |
| 낮음 | `features/phonetics/` | 성별별 IPA 미구현 |
| 낮음 | `features/phonetics/` | 음소 단위 평가 부분 구현 |
| 낮음 | Google Drive 통합 | 클라이언트 직접 호출 — 토큰 노출 위험, 서버 프록시 전환 검토 |

---

## 13. 환경 변수 & 설정

### 서버 환경 변수

| 변수 | 기본값 | 필수 | 설명 |
|------|--------|------|------|
| `PORT` | `8080` | | 서버 포트 |
| `QWEN_API_KEY` | - | ✅ | Alibaba Qwen API 키 |
| `GEMINI_API_KEY` | - | ✅ | Google Gemini API 키 |
| `JWT_SECRET` | `dev-secret-change-in-production` | ✅ | JWT 서명 키 |
| `APP_ENV` | `development` | | `development` → `/docs` 활성화 |
| `DATABASE_URL` | - | (택1) | MySQL DSN 전체 |
| `MYSQL_USER` | `lingo` | (택1) | DB 사용자 |
| `MYSQL_PASSWORD` | `lingopassword` | (택1) | DB 비밀번호 |
| `MYSQL_HOST` | `localhost` | (택1) | DB 호스트 |
| `MYSQL_PORT` | `3306` | (택1) | DB 포트 |
| `MYSQL_DATABASE` | `lingo_nexus` | (택1) | DB 이름 |

### Flutter 빌드 변수

```bash
# 개발
flutter run --dart-define=SERVER_URL=http://localhost:8080

# 운영
flutter build apk --dart-define=SERVER_URL=https://api.lingonexus.app
```

### Makefile 단축키

```makefile
make app        # flutter run -d android
make server     # go run ./cmd/api
make dev        # 서버 + 앱 동시 실행
make test       # 전체 테스트
make app-l10n   # flutter gen-l10n
```

---

## 14. 테스트 인프라

### 서버 테스트

```
server/internal/handler/
  ai_handler_test.go       ← AI 핸들러 유닛 테스트
  auth_handler_test.go     ← 인증 핸들러 유닛 테스트
  health_test.go           ← 헬스체크 테스트

server/internal/middleware/
  auth_middleware_test.go  ← 미들웨어 테스트

server/internal/service/
  auth_service_test.go     ← 인증 서비스 테스트
  credit_service_test.go   ← 크레딧 서비스 테스트
  usage_service_test.go    ← 사용량 서비스 테스트

server/internal/service/
  interfaces.go            ← 서비스 인터페이스 (목 주입용)

server/testutil/           ← 공통 테스트 헬퍼
```

```bash
cd server
go test ./...
```

### Flutter 테스트

```
app/test/
  core/                    ← 코어 서비스 유닛 테스트
  helpers/                 ← 테스트 헬퍼 (목 생성 등)
```

```bash
cd app
flutter test
flutter test test/core/streak_service_test.dart  # 특정 파일
```

**Mock 방식:** `mocktail` 패키지 (타입 안전 모킹)

---

## 15. 누락 보완: 추가 Feature 상세

### Feature: Clip (오디오 클립 편집)

**`app/lib/core/services/clip_service.dart`**
**`app/lib/features/clip/clip_editor_screen.dart`**

FFmpeg 기반 오디오 편집 기능. 긴 오디오에서 원하는 구간만 잘라 별도 학습 자료로 저장한다.

**ClipService 메서드:**

```dart
class ClipService {
  // 저장 경로: {AppDocuments}/clips/

  Future<List<StudyItem>> loadClips()
      // clips/ 디렉터리 스캔 → StudyItem 목록

  Future<String?> trimAudio({sourcePath, start, end, title})
      // FFmpeg: -ss {start} -i "{src}" -t {dur} -c copy ... "{dest}" -y
      // copy 실패 시 재인코딩 폴백
      // Windows에서는 미지원 (FFmpeg 제한)
      // 반환: 저장된 파일 경로

  Future<String?> saveClipScript({clipAudioPath, syncItems, start, end})
      // syncItems에서 start~end 겹치는 문장 추출 → .txt 저장

  Future<String?> exportClipAsZip(StudyItem clip)
      // 오디오 + 스크립트 → .zip 임시 파일
      // share_plus로 외부 공유

  Future<List<double>> extractWaveform(String audioPath, {int samples = 120})
      // FFmpeg astats 필터: -af "asetnsamples={n},astats=metadata=1:reset=1"
      // RMS 레벨(dB) 추출 → 0~1 정규화 (dB 범위: -60 ~ 0)
      // 실패 시 해시 기반 의사난수 파형 생성

  Future<List<StudyItem>> autoSplitAndSave({sourcePath, baseTitle, minSilence, silenceThresholdDb})
      // detectSpeechSegments() 로 구간 감지
      // 2초 미만 구간 제외
      // 각 구간 trimAudio() → 라이브러리 추가

  Future<List<(Duration, Duration)>> detectSpeechSegments(sourcePath, ...)
      // FFmpeg silencedetect 필터: noise=-40dB, d={minSilence}
      // silence_start/end 타임스탬프 파싱
      // 말하기 구간 (start, end) 리스트 반환
}
```

**ClipEditorScreen UI:**

```
파형 + 드래그 핸들 (_WaveformRangeSelector)
  - 실제 파형 비동기 로드 (extractWaveform)
  - 로딩 중: 의사난수 파형 표시
  - 시작(녹색)/끝(빨강) 드래그 핸들
  - 선택 구간 하이라이팅
  - 싱크 아이템 경계선 마커 (파란 세로선)

시간 표시 (시작 / 선택 길이 / 끝)

버튼:
  미리듣기 → ClippingAudioSource(start, end).play()
  구간 감지 → detectSpeechSegments()
  자동 분할 저장 → autoSplitAndSave()
  내보내기 (zip) → exportClipAsZip() + Share.shareXFiles()
  클립으로 저장 → trimAudio() + saveClipScript() → 라이브러리 추가

문장 선택 목록 (syncItems 있을 때):
  - 문장 탭 → 해당 구간으로 range 이동
  - + 버튼 → 현재 range에 해당 문장 포함 확장

감지된 구간 목록 (silenceSegments 있을 때):
  - 탭 → range 설정
```

**_WaveformRangePainter (CustomPainter):**
- 선택 구간 배경 칠
- 파형 막대 그래프 (선택 내/외 색상 구분)
- 싱크 마커 세로선
- 시작/끝 핸들 (드래그 그립 3줄 표시)

---

### Feature: Scribe (받아쓰기 연습)

**`app/lib/features/scribe/scribe_mode_screen.dart`**

오디오 구간을 듣고 텍스트로 받아쓰는 딕테이션(dictation) 훈련 기능.

**상태 머신:**
```
listening → [재생 완료] → typing → [check()] → revealed
revealed → [retry()] → listening
```

```dart
enum ScribeState { listening, typing, revealed }

class ScribeModeScreen {
  final String originalText;   // 정답 텍스트
  final String audioPath;      // 오디오 파일
  final Duration startTime;    // 구간 시작
  final Duration endTime;      // 구간 끝
}
```

**채점 알고리즘:**
```dart
void _check() {
  // 1. 소문자화 + 구두점 제거 + 토큰화
  origWords = normalize(originalText).split()
  inputWords = normalize(userInput).split()

  // 2. 단어별 Levenshtein 거리 ≤ 1이면 정답 (오타 허용)
  for each origWord:
    isCorrect = inputWords.any((w) => levenshtein(w, origWord) <= 1)

  // 3. 점수 = 정답 단어 수 / 전체 단어 수 * 100

  // 4. 결과: 단어별 색상 표시 (초록: 정답, 빨강: 오답)
}
```

**재생 설정:**
- 속도: 0.5x / 0.75x / 1.0x
- 재생 횟수 표시 (`_playCount`)
- 구간 자동 정지 (Timer(segmentDuration))

**점수 색상 기준:**
- 90점 이상 → 초록 (AppTheme.success)
- 70~89점 → 파랑 (primary)
- 70점 미만 → 빨강 (AppTheme.danger)

---

### Feature: Playlist (재생 목록)

**`app/lib/features/playlist/playlist_provider.dart`**

```dart
// StudyItem 목록 순서 관리
// 이전/다음 트랙 네비게이션
// autoPlayNextProvider와 연동
```

---

### Feature: Shadow Deck (쉐도잉 덱)

**`app/lib/features/shadowing/shadow_deck_provider.dart`**
**`app/lib/features/shadowing/shadow_deck_screen.dart`**
**`app/lib/core/services/shadow_deck_service.dart`**

쉐도잉 연습용 플래시카드 덱.

```dart
class ShadowDeckItem {
  String sentence;
  String? phonetics;
  String? translation;
  String audioPath;
  Duration startTime;
  Duration endTime;
  // 복습 예정일, 성공 횟수 등
}

class ShadowDeckService {
  Future<void> addItem(ShadowDeckItem item)
  Future<List<ShadowDeckItem>> getDueItems()    // 오늘 복습할 항목
  Future<void> markReviewed(String id, bool success)
  Future<void> removeItem(String id)
}

// ShadowDeckScreen:
// - 카드 앞면: 발음기호 + 번역 (문장 숨김)
// - 탭 → 해당 오디오 구간 재생
// - 녹음 → 채점 → 성공/실패 표시
// - 간격 반복 알고리즘으로 다음 복습 예정 설정
```

---

### Feature: Subscription & Credits (구독/크레딧 화면)

**`app/lib/features/subscription/subscription_screen.dart`**
**`app/lib/features/subscription/subscription_provider.dart`**
**`app/lib/features/credits/credits_screen.dart`**

```dart
// SubscriptionScreen:
//   - GET /api/v1/credits → 현재 상태 표시
//   - GET /api/v1/credits/products → 상품 목록
//   - 구독 플랜 카드 (Basic/Pro/Premium)
//   - 크레딧 팩 카드 (일회성 구매)
//   - IAP 구매 버튼 → subscriptionService.purchase()

// SubscriptionProvider:
final subscriptionStatusProvider = FutureProvider<CreditStatusResponse>
final productsProvider = FutureProvider<List<InAppProduct>>

// CreditsScreen:
//   - 잔액, 일일 무료 사용량 표시
//   - 크레딧 사용 내역 (transactions)
```

---

### Feature: Marketplace (마켓플레이스)

**`app/lib/features/marketplace/marketplace_screen.dart`**

```dart
// 학습 콘텐츠 마켓플레이스
// 언어별 큐레이션된 오디오 콘텐츠 탐색
// URL 임포트와 연동
```

---

### Feature: Intro (인트로 화면)

**`app/lib/features/intro/intro_screen.dart`**

```dart
// 앱 최초 실행 또는 비로그인 상태 진입점
// 앱 소개 슬라이드
// Google 로그인 버튼 → LoginScreen
// 게스트로 시작 → MainNavigationScreen (일부 기능 제한)
```

---

### Feature: Legal (법적 문서)

**`app/lib/features/legal/privacy_screen.dart`**
**`app/lib/features/legal/terms_screen.dart`**

```dart
// 개인정보처리방침 및 서비스 이용약관
// WebView 또는 인라인 텍스트로 표시
// 설정 화면에서 접근
```

---

### Feature: Script Attach (스크립트 연결)

**`app/lib/features/library/script_attach_sheet.dart`**

```dart
// 오디오 아이템에 스크립트 파일 수동 연결
// FilePicker로 .txt/.srt 선택
// studyItemsNotifier.attachScript(audioPath, scriptPath)
// SRT 파일이면 SrtParserService로 자동 파싱 → SyncItems 생성
```

---

### Feature: Auto Sync Setup (오토싱크 설정)

**`app/lib/features/sync/auto_sync_setup_screen.dart`**

```dart
// 오토싱크 실행 전 설정 화면
// 학습 언어 선택
// 목표 언어(번역 대상) 선택
// STT 경로 vs 서버 전체 처리 경로 선택
// 크레딧 소요 예상량 표시
// "시작" → AutoSyncService.transcribe() 호출
```

---

### Feature: AI Tutor Sheet (AI 튜터 시트)

**`app/lib/features/tutor/ai_tutor_sheet.dart`**
**`app/lib/features/tutor/tutor_provider.dart`**

```dart
// 플레이어에서 문장 탭 시 바텀시트로 표시

class AiTutorSheet extends ConsumerWidget {
  // 탭 구조:
  //   문법 설명 | 어휘 설명 | AI 대화

  // 문법: llmService.askGrammar(sentence) → 결과 텍스트
  // 어휘: 단어 탭 → llmService.askVocabulary(word, sentence)
  // 대화: ConversationScreen과 동일 UI (컨텍스트: 현재 문장)
}

// TutorProvider:
final grammarExplanationProvider = FutureProvider.family<String, String>
    // sentence → /api/v1/ai/grammar

final vocabularyExplanationProvider = FutureProvider.family<String, (String, String)>
    // (word, context) → /api/v1/ai/vocabulary
```

---

### Feature: Bookmarks Provider

**`app/lib/features/bookmarks/bookmarks_provider.dart`**

```dart
final bookmarksProvider = StateNotifierProvider.family<BookmarksNotifier, List<BookmarkItem>, String>
    // String: audioPath

class BookmarksNotifier extends StateNotifier<List<BookmarkItem>> {
  Future<void> addBookmark(Duration position, String note)
  Future<void> removeBookmark(String id)
  Future<void> loadBookmarks(String audioPath)
}
```

---

### Feature: Conversation Provider

**`app/lib/features/conversation/conversation_provider.dart`**

```dart
final conversationProvider = StateNotifierProvider<ConversationNotifier, List<ChatMessage>>

class ConversationNotifier extends StateNotifier<List<ChatMessage>> {
  Future<void> sendMessage(String text, {String systemPrompt = ''})
      1. state = [...state, ChatMessage(role: "user", content: text)]
      2. llmService.chat(state, text, systemPrompt: systemPrompt)
      3. state = [...state, ChatMessage(role: "assistant", content: reply)]

  void clearHistory()
}
```

---

### 추가 서비스 파일 목록

| 파일 | 역할 |
|------|------|
| `core/services/pronunciation_history_service.dart` | 쉐도잉 시도 이력 CRUD (SharedPreferences) |
| `core/services/shadow_deck_service.dart` | 쉐도잉 덱 아이템 CRUD + 간격 반복 |
| `core/services/streak_provider.dart` | StreakService의 Riverpod Provider 정의 |
| `core/services/file_open_service.dart` | OS 파일 열기 이벤트 수신 + Scanner에 전달 |
| `core/tutorial/tutorial_service.dart` | 튜토리얼 완료 여부 저장/로드 |
| `core/tutorial/tutorial_provider.dart` | TutorialNotifier Provider 정의 |
| `features/phonetics/phoneme_eval_service.dart` | 음소 단위 발음 평가 (부분 구현) |
| `features/phonetics/phonetics_quiz_screen.dart` | 발음 퀴즈 화면 |
| `features/phonetics/ipa_data.dart` | IPA 기호 데이터 테이블 |
| `features/phonetics/ipa_lookup_service.dart` | IPA 기호 검색 서비스 |
| `features/phonetics/pitch_accent_data.dart` | 피치 악센트 데이터 (일본어/중국어) |
| `features/phonetics/pitch_accent_widget.dart` | 피치 악센트 시각화 커스텀 위젯 |
| `features/phonetics/tts_service.dart` | FlutterTts 래퍼 서비스 |
| `features/minimal_pair/minimal_pair_data.dart` | 최소쌍 데이터셋 (언어별) |
| `features/stats/learning_heatmap.dart` | 학습 히트맵 커스텀 위젯 |
| `features/stats/share_card_screen.dart` | 학습 통계 공유 카드 스크린샷 |
| `features/podcast/podcast_model.dart` | Podcast, Episode 데이터 모델 |
| `features/podcast/podcast_service.dart` | RSS 파싱 + 에피소드 다운로드 |
| `features/podcast/podcast_provider.dart` | 팟캐스트 상태 Provider |
| `features/settings/api_key_settings_sheet.dart` | (레거시) API 키 직접 입력 시트 |

---

## 16. 전체 파일 목록 (총 분석 완료)

### 서버 Go 파일

```
server/cmd/api/main.go
server/internal/db/db.go (추정)
server/internal/handler/ai_handler.go
server/internal/handler/ai_handler_test.go
server/internal/handler/annotate_handler.go
server/internal/handler/auth_handler.go
server/internal/handler/auth_handler_test.go
server/internal/handler/content_handler.go
server/internal/handler/credit_handler.go
server/internal/handler/health_test.go
server/internal/handler/shadowing_handler.go
server/internal/handler/tone_handler.go
server/internal/handler/transcribe_handler.go
server/internal/middleware/auth.go
server/internal/middleware/auth_middleware_test.go
server/internal/model/content.go
server/internal/model/shadowing.go
server/internal/model/ (user, credit, ai 모델들)
server/internal/service/auth_service.go
server/internal/service/auth_service_test.go
server/internal/service/credit_service.go
server/internal/service/credit_service_test.go
server/internal/service/interfaces.go
server/internal/service/llm_service.go
server/internal/service/usage_service.go
server/internal/service/usage_service_test.go
server/testutil/ (테스트 헬퍼)
server/go.mod
server/api/ (OpenAPI 스펙)
```

### Flutter Dart 파일 (140개+)

```
app/lib/main.dart
app/lib/core/config/server_config.dart
app/lib/core/models/ (6개 모델)
app/lib/core/providers/ (3개: auth, locale, ai)
app/lib/core/services/ (17개 서비스)
app/lib/core/theme/app_theme.dart
app/lib/core/tutorial/ (3개: provider, service, state)
app/lib/features/active_recall/active_recall_screen.dart
app/lib/features/auth/login_screen.dart
app/lib/features/bookmarks/ (2개: provider, screen)
app/lib/features/clip/ (1개: clip_editor_screen)
app/lib/features/conversation/ (2개: provider, screen)
app/lib/features/credits/credits_screen.dart
app/lib/features/home/home_screen.dart
app/lib/features/intro/intro_screen.dart
app/lib/features/legal/ (2개: privacy, terms)
app/lib/features/library/ (3개: browser, sheet, script_attach)
app/lib/features/marketplace/marketplace_screen.dart
app/lib/features/minimal_pair/ (2개: data, screen)
app/lib/features/phonetics/ (9개: hub, quiz, tts, kana, pitch×3, ipa×2, phoneme_eval)
app/lib/features/player/ (4개: engine, provider, screen, widgets×2)
app/lib/features/playlist/playlist_provider.dart
app/lib/features/podcast/ (4개: model, provider, screen, service)
app/lib/features/scanner/ (4개: directory_scanner, sample_content, scanner_provider, url_import)
app/lib/features/scribe/scribe_mode_screen.dart
app/lib/features/settings/ (2개: api_key_sheet, settings_screen)
app/lib/features/shadowing/ (4개: provider, screen, shadow_deck_provider, shadow_deck_screen)
app/lib/features/stats/ (4개: heatmap, share_card, stats_provider, stats_screen)
app/lib/features/subscription/ (2개: provider, screen)
app/lib/features/sync/ (2개: auto_sync_service, auto_sync_setup_screen)
app/lib/features/tutor/ (2개: ai_tutor_sheet, tutor_provider)
app/lib/features/tutorial/tutorial_overlay.dart
app/lib/l10n/ (11개 ARB)
app/lib/generated/l10n/ (11개 생성 Dart)
```

---

*본 문서는 `lingo_nexus` 모노레포의 전체 코드베이스를 기반으로 작성되었습니다.*
*서버: Go 파일 30개+, 클라이언트: Dart 파일 140개+ 분석 완료.*
