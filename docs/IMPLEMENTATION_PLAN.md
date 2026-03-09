# LingoNexus 구현 현황 분석 및 에이전트 팀 구성 계획

## 현황 요약

Gemini가 앱의 **UI 뼈대(Shell)와 핵심 인프라**를 구축한 상태입니다.
실제 동작하는 기능은 제한적이며, 대부분의 핵심 기능이 하드코딩 또는 stub 상태입니다.

---

## 구현 완료 (Working)

| 기능 | 파일 | 상태 |
|------|------|------|
| 오디오 재생 엔진 | `audio_engine.dart` | 완료 — play/pause, 배속, 루프, ±10s skip |
| 디렉터리 스캐너 | `directory_scanner_service.dart` | 완료 — 오디오↔txt 페어링 |
| AI 문법 분석 (단방향) | `llm_service.dart` + `ai_tutor_sheet.dart` | 완료 — GPT-4o-mini, Gemini 1.5 Flash |
| API 키 저장 | `secure_storage_service.dart` | 완료 — Keychain/Keystore 암호화 |
| AI 프로바이더 전환 | `ai_provider.dart` | 완료 — Google/OpenAI 전환 |
| 다국어(10개 언어) | `lib/l10n/*.arb` | 완료 |
| 다크 테마 | `app_theme.dart` | 완료 |
| Library 라이브러리 목록 | `library_sheet.dart`, Drawer | 완료 |

---

## 미구현 기능 목록

### 🔴 Critical (앱의 핵심 가치 미구현)

1. **실시간 재생-스크립트 싱크**
   - Seekbar: `value: 0.3` 하드코딩, `positionStream`/`durationStream` 미연결
   - 활성 문장 강조: 항상 `index == 0` (첫 번째 줄만 활성)
   - 문장 탭 → 해당 오디오 위치 점프: `onTap: () {}` 빈 함수
   - 타임코드: 전부 `"00:00"` 하드코딩

2. **Auto-Sync 엔진**
   - `AutoSyncSetupScreen`: 3초 fake delay 후 성공 SnackBar만 표시
   - `AutoSyncService`: 글자 수 비례 분할(placeholder), 실제 STT 미연동
   - 생성된 `SyncItem` 목록을 `StudyItem`과 연결하여 저장하는 로직 없음

3. **쉐도잉 스튜디오 — 녹음**
   - `_toggleRecording()`: boolean 전환만 하고 실제 마이크 접근 없음
   - `record` 패키지 미설치
   - 발음 점수(85/72/90): 완전 하드코딩

### 🟡 Important (완성도에 필수)

4. **AI 튜터 채팅 (멀티턴)**
   - `AiTutorBottomSheet`의 입력창 전송 버튼: `onPressed: () {}` 빈 함수
   - 단방향 문법 설명만 가능, 후속 질문 불가

5. **Claude API 연동**
   - `LlmService.askGrammar()`: Claude 분기에서 하드코딩 문자열 반환

6. **어휘 도우미 (Vocabulary Helper)**
   - 메뉴 버튼 존재하지만 `onPressed: () {}` 빈 함수

7. **학습 진도 추적 & 홈 화면 데이터 연결**
   - 홈 화면 "Continue Studying": `"Home_With_Kids_29"` 하드코딩
   - Recent Activity: fake 5개 에피소드 하드코딩
   - 진행률 바: `value: 0.65` 하드코딩

### 🟢 Enhancement (설계는 있으나 미구현)

8. **Stats 화면**: `"Stats Screen (Coming Soon)"` placeholder
9. **Settings 화면**: `"Settings Screen (Coming Soon)"` placeholder
10. **크레딧/결제 시스템**: UI만 존재, 버튼 모두 빈 함수

---

## 에이전트 팀 구성 및 구현 계획

> 모델 선택 기준:
> - **Opus 4.6**: 복잡한 아키텍처 설계, 여러 파일에 걸친 상태 연동이 필요한 작업
> - **Sonnet 4.6**: 명확한 스펙의 기능 구현, API 연동, 중간 복잡도 작업
> - **Haiku 4.5**: 반복적인 UI 위젯, 간단한 로직 교체, 보일러플레이트

---

### Team A — 실시간 재생-스크립트 싱크 엔진
**모델**: `claude-opus-4-6`
**이유**: 스트림 기반 상태(position, duration, SyncItem)를 여러 Provider에 걸쳐 조율해야 하는 가장 복잡한 작업

**담당 파일**:
- `lib/core/models/sync_item.dart` (확장)
- `lib/features/player/player_provider.dart` (positionStream 추가)
- `lib/features/player/audio_engine.dart` (position getter 추가)
- `lib/features/player/player_screen.dart` (ScriptLine 활성화 로직, Seekbar 연동, onTap 점프)
- `lib/features/scanner/scanner_provider.dart` (StudyItem별 SyncItem 저장 구조)

**세부 태스크**:
```
A-1. PlayerProvider에 positionProvider(StreamProvider<Duration>),
     durationProvider(StreamProvider<Duration?>) 추가
A-2. Seekbar의 value를 positionStream/durationStream으로 연동,
     onChanged 시 engine.seek() 호출
A-3. currentActiveSentenceIndexProvider 구현:
     positionStream + List<SyncItem>를 결합해 현재 활성 인덱스 계산
A-4. ScriptLine의 isActive를 실시간 인덱스로 교체,
     onTap에서 syncItem.startTime으로 seek 호출
A-5. 타임코드를 SyncItem.startTime으로 포맷팅하여 표시
```

---

### Team B — Auto-Sync 파이프라인
**모델**: `claude-sonnet-4-6`
**이유**: Whisper API 연동 + 데이터 영속성 설계가 필요하지만, 패턴이 기존 LlmService와 유사

**담당 파일**:
- `lib/features/sync/auto_sync_service.dart` (Whisper API 실제 연동)
- `lib/features/sync/auto_sync_setup_screen.dart` (실제 서비스 호출로 교체)
- `lib/core/models/study_item.dart` (syncItems 필드 추가)
- `lib/features/scanner/scanner_provider.dart` (SyncItem 캐시 관리)

**세부 태스크**:
```
B-1. AutoSyncService에 OpenAI Whisper API 호출 구현
     (audio 파일 → timestamped segments → List<SyncItem>)
B-2. AutoSyncSetupScreen에서 실제 AutoSyncService 호출,
     currentStudyItem의 audioPath를 전달
B-3. StudyItem에 List<SyncItem>? syncItems 필드 추가
B-4. 생성된 SyncItem을 StudyItem에 저장하고
     scannerProvider를 통해 앱 전역에 전파
B-5. (폴백) Whisper 미사용 시 개선된 문자 기반 분할 유지
```

---

### Team C — AI 튜터 멀티턴 채팅 + Claude 연동
**모델**: `claude-sonnet-4-6`
**이유**: HTTP 멀티턴 API 설계 + Claude Anthropic API 연동. 기존 LlmService 패턴 확장

**담당 파일**:
- `lib/core/services/llm_service.dart` (멀티턴 + Claude API 추가)
- `lib/features/tutor/tutor_provider.dart` (채팅 히스토리 Provider 추가)
- `lib/features/tutor/ai_tutor_sheet.dart` (채팅 UI 연동)

**세부 태스크**:
```
C-1. LlmService에 chatMessage(type, apiKey, history, newMessage) 메서드 추가
     - OpenAI: messages 배열로 히스토리 전달
     - Gemini: contents 배열로 멀티턴 구성
     - Claude: Anthropic API (claude-haiku-4-5-20251001) 연동
C-2. TutorProvider에 chatHistoryProvider(StateNotifierProvider<List<ChatMessage>>) 추가
C-3. AiTutorBottomSheet의 TextField + 전송 버튼 연결
     채팅 히스토리 ScrollView로 교체 (단방향 → 멀티턴)
C-4. Claude AiProviderType 분기 완성 (현재 stubbed)
```

---

### Team D — 쉐도잉 스튜디오 실제 녹음
**모델**: `claude-sonnet-4-6`
**이유**: 패키지 추가 + 마이크 권한 + 녹음 파일 처리. 명확한 스펙

**담당 파일**:
- `pubspec.yaml` (`record` 패키지 추가)
- `macos/Runner/DebugProfile.entitlements`, `Release.entitlements` (마이크 권한)
- `ios/Runner/Info.plist` (NSMicrophoneUsageDescription)
- `lib/features/shadowing/shadowing_studio_screen.dart`
- `lib/features/shadowing/shadowing_provider.dart` (신규)

**세부 태스크**:
```
D-1. pubspec.yaml에 record: ^6.x 추가
D-2. 플랫폼별 마이크 권한 설정 (macOS entitlements, iOS plist)
D-3. ShadowingProvider 구현:
     - 녹음 시작/중지 → 임시 파일 저장
     - 원본 오디오 재생 (AudioEngine 재사용)
D-4. ShadowingStudioScreen의 _toggleRecording()을 실제 녹음으로 교체
D-5. (기본 채점) Whisper로 녹음 파일 전사 → 원본 텍스트와 diff 비교
     → 단어별 accuracy 계산 (하드코딩 점수 제거)
```

---

### Team E — 어휘 도우미
**모델**: `claude-haiku-4-5-20251001`
**이유**: LlmService 패턴을 그대로 따르는 단순 기능 추가. Haiku로 충분

**담당 파일**:
- `lib/core/services/llm_service.dart` (askVocabulary 메서드 추가)
- `lib/features/vocabulary/vocabulary_sheet.dart` (신규)
- `lib/features/tutor/tutor_provider.dart` (vocabularyProvider 추가)
- `lib/features/player/player_screen.dart` (Vocabulary Helper 버튼 연결)

**세부 태스크**:
```
E-1. LlmService.askVocabulary(type, key, word, contextSentence) 구현
     프롬프트: 단어 뜻, 품사, 예문 2개, 뉘앙스 설명
E-2. VocabularyBottomSheet 위젯 구현 (AiTutorBottomSheet와 유사 구조)
E-3. PlayerScreen의 Vocabulary Helper 메뉴 버튼 연결
```

---

### Team F — 홈 화면 데이터 연결 + 진도 추적
**모델**: `claude-haiku-4-5-20251001`
**이유**: 기존 StudyItem 모델 확장 + SharedPreferences 연동. 복잡도 낮음

**담당 파일**:
- `pubspec.yaml` (`shared_preferences` 추가)
- `lib/core/models/study_item.dart` (lastPosition, lastPlayedAt 필드 추가)
- `lib/core/services/progress_service.dart` (신규)
- `lib/features/home/home_screen.dart` (하드코딩 데이터 Provider로 교체)

**세부 태스크**:
```
F-1. StudyItem에 Duration? lastPosition, DateTime? lastPlayedAt 추가
F-2. ProgressService: SharedPreferences에 재생 위치 저장/로드
F-3. AudioEngine.dispose() 또는 앱 생명주기 이벤트에서 진도 자동 저장
F-4. homeScreenProvider: lastPlayedItem, recentItems를 실제 데이터로 제공
F-5. HomeScreen의 하드코딩 문자열/값을 Provider 데이터로 교체
```

---

### Team G — Stats & Settings 화면
**모델**: `claude-haiku-4-5-20251001`
**이유**: UI 구현 중심. 데이터는 ProgressService(Team F)에 의존

**담당 파일**:
- `lib/features/stats/stats_screen.dart` (신규)
- `lib/features/settings/settings_screen.dart` (신규)
- `lib/features/home/home_screen.dart` (BottomNav `_screens` 배열 교체)

**세부 태스크**:
```
G-1. StatsScreen: 총 학습 시간, 완료 항목 수, 언어별 분류 (ProgressService 데이터)
G-2. SettingsScreen: AI 프로바이더 선택 UI, API 키 관리 링크,
     언어 설정, 데이터 초기화
G-3. MainNavigationScreen의 _screens 배열에 실제 Screen 위젯 연결
```

---

## 구현 우선순위 및 의존성 그래프

```
Team A (실시간 싱크)    ←── Team B (Auto-Sync 생성)
       ↓
Team D (쉐도잉)          ←── Team B (SyncItem 필요)

Team C (AI 채팅)         독립 실행 가능
Team E (어휘)            독립 실행 가능

Team F (진도 추적)       독립 실행 가능
Team G (Stats/Settings) ←── Team F (데이터 의존)
```

**권장 실행 순서**:
1. **Sprint 1** (병렬): Team A + Team C + Team F
2. **Sprint 2** (병렬): Team B + Team E + Team G
3. **Sprint 3**: Team D (Team B의 Whisper 연동 완료 후)

---

## 총 에이전트 배치 요약

| 팀 | 역할 | 모델 | 예상 변경 파일 수 |
|----|------|------|-----------------|
| A | 실시간 재생-스크립트 싱크 | Opus 4.6 | 5개 |
| B | Auto-Sync (Whisper) | Sonnet 4.6 | 4개 |
| C | AI 튜터 멀티턴 + Claude | Sonnet 4.6 | 3개 |
| D | 쉐도잉 실제 녹음 | Sonnet 4.6 | 5개 |
| E | 어휘 도우미 | Haiku 4.5 | 3개 (신규 1) |
| F | 진도 추적 | Haiku 4.5 | 3개 (신규 1) |
| G | Stats & Settings 화면 | Haiku 4.5 | 3개 (신규 2) |
