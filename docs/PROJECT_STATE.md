# 🚀 LingoNexus Project State & History

## 📅 진행 내역 (Completed Work)

### Phase 1 & 2
* **프로젝트 셋업:** Flutter (Riverpod, Clean Architecture), iOS/Android/macOS 플랫폼 셋업, `just_audio`, `flutter_secure_storage`, `http`, `file_picker` 패키지 연동 완료.
* **디렉터리 스캐너:** 기기 내 로컬 폴더를 스캔하여 `.mp3` 파일과 동일한 이름의 `.txt` 파일을 `StudyItem`으로 자동 바인딩 (`DirectoryScannerService`).
* **오디오 엔진:** `just_audio` 기반 배속 제어(0.5x~2.0x, 피치 보정 포함), 10초 스킵, 루프(반복 재생) 로직 구축.
* **AI Tutor System (The Brain):**
  * `LlmService` 구축: Google Gemini 1.5 Flash 및 OpenAI GPT-4o-mini API 직접 통신 모듈.
  * 텍스트 터치 시 하단에서 올라오는 AI 문법/예문 분석 팝업 UI 구현 (`AiTutorBottomSheet`).
  * 앱 내 API Key 설정 화면(`ApiKeySettingsSheet`) 및 기기 로컬 암호화 저장소 연동.

### UI/UX Refinement & Global Support (Recent Work)
* **Design System Update:** "Organic Neo-glass" 테마 적용. `AppTheme`을 Material 3 토큰 기반으로 전면 개편.
* **Intro & Home Redesign:** 
  * 'L' & 'N' 로고 애니메이션이 포함된 `IntroScreen` 구현.
  * 'Continue Studying' 및 최근 활동 리스트를 포함한 `HomeScreen` 구현.
  * 하단 네비게이션 바(Bottom Navigation Bar) 도입.
* **Player 고도화:** 
  * `AnimatedWaveform`을 통한 실시간 오디오 스펙트럼 시각화.
  * 문장 롱프레스 시 호출되는 통합 `AI Menu` 패널 구현.
* **Library Management:** 풀스크린 모달 형태의 `LibrarySheet` 및 콘텐츠 필터링(All, Audio Only, Pending Sync) 기능 추가.
* **Premium Feature Prototypes:** 
  * `AutoSyncSetupScreen`: 언어 선택 및 크레딧 결제/BYOK 워크플로우 UI.
  * `ShadowingStudioScreen`: 원어민 파형 비교 및 정확도/억양/유창성 평가 점수 UI.
* **다국어 지원 (i18n):** 한국어, 영어, 일본어, 중국어, 아랍어, 스페인어 등 14개 이상의 로캘 지원 및 RTL 대응 완료.
* **Core Library Upgrade:** `flutter_riverpod`, `just_audio`, `file_picker`, `flutter_secure_storage` 등을 최신 안정화 버전으로 업데이트 및 코드 최적화 완료.

## 🎯 다음 작전 목표 (Next Step - Phase 3)
* **Real Auto-Sync 고도화:** 임시 비율 할당 로직을 실제 Whisper API 또는 온디바이스 STT로 교체하여 완벽한 문장 단위 싱크(LRC) 동기화 구현.
* **Shadowing 엔진 연동:** UI 프로토타입에 실제 음성 녹음 및 채점 로직(LLM 또는 전용 음성 분석 API) 연동.
* **통계 및 설정 화면 완성:** Stats 및 Settings 화면의 상세 기능 구현.
