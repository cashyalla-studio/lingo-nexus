# LingoNexus Design System & UI Architecture

## 디자인 컨셉: Neo-glass & Premium Minimal
"어둠 속에서 빛나는 단 하나의 문장." 본 디자인은 딥 다크(#0A0A0C) 베이스 위에 반투명한 레이어(Surface)를 차곡차곡 쌓아 올린 'Neo-glass' 스타일을 지향합니다. 불필요한 장식과 과한 그라데이션을 철저히 배제하고, 사용자의 시선이 머무는 '현재 재생 중인 스크립트'와 '핵심 조작 버튼'에만 맑고 선명한 민트 시안(#00E5FF) 포인트를 줍니다. 넉넉한 여백(16/24px)과 가독성을 극대화한 행간(1.6)을 통해, 학습자가 시각적 피로 없이 오직 '언어의 뉘앙스와 흐름'에만 몰입할 수 있는 프리미엄 학습 환경을 제공합니다.

## Theme Tokens (Material 3)
*   **Colors (HEX):**
    *   background: `#0A0A0C`
    *   surface: `#121318`
    *   surface2: `#1A1C23`
    *   outline: `#2A2C35`
    *   textPrimary: `#F2F2F5` (95% Opacity)
    *   textSecondary: `#A0A2AB` (60% Opacity)
    *   accentPrimary: `#00E5FF` (Mint/Cyan)
    *   accentSecondary: `#D580FF` (Purple/Pink)
    *   danger: `#FF5252`
    *   success: `#00E676`
*   **Typography:**
    *   display: 32px, Bold, LH 1.3
    *   title: 20px, SemiBold, LH 1.4
    *   body: 16px, Medium, LH 1.6 (학습용 넉넉한 행간)
    *   caption: 13px, Medium, LH 1.5
*   **Spacing & Radius:** 4/8/12/16/24/32px 스케일. Card Radius 16px, Button Radius 14px.
*   **Elevation:** 0(플랫), 1(미세한 그림자/보더), 2(바텀 시트).

## 1. 홈 / 라이브러리 (콘텐츠 리스트)
**정보구조 (레이아웃):** 상단에는 큼직한 타이틀("My Library")과 필터 칩(최근 학습, 다운로드됨)이 가로로 스크롤 됩니다. 중앙에는 리스트 형태의 `LibraryCard`가 배치되며, 하단에는 메인 플레이어로 즉시 돌아갈 수 있는 미니 플레이어(Mini-player)가 떠 있습니다.
**핵심 컴포넌트 & 상태:**
*   `LibraryCard`: 썸네일, 제목, 학습 진행률(Progress bar).
*   `EmptyStateCard`: 빈 상태 시 부드러운 아이콘과 함께 "아직 학습을 시작하지 않았어요." (KR) / "No lessons yet." (EN) 안내 및 [새 콘텐츠 찾아보기] CTA 버튼 제공.
*   [x] 반응형: 태블릿/데스크톱에서는 카드가 3단 그리드로 자동 확장.
*   [x] 접근성: 썸네일 위 텍스트 배치 시 블랙 그라데이션 필터를 넣어 대비율 4.5:1 준수.

## 2. 플레이어 화면 (메인: 오디오 + 스크립트)
**정보구조 (레이아웃):** 앱의 심장입니다. 상단은 [뒤로가기, 제목, 옵션]으로 최소화합니다. 중앙 70%는 스크롤 가능한 스크립트 영역, 하단 30%는 고정된 `PlayerControls` 바텀 패널입니다. 그 사이를 가르는 얇고 터치 영역이 넓은 시크바(Seekbar)가 존재합니다.
**핵심 컴포넌트 & 상태:**
*   `ScriptLine`: '학습 모드' 시 문장 단위로 분리. 현재 문장은 배경이 옅은 민트색(`accentPrimary` 10%)으로 칠해지며 텍스트는 `textPrimary`로 빛납니다. 탭(이동) / 롱프레스(단어 뜻 팝업) 지원.
*   `PlayerControls`: 중앙의 둥글고 큰 Play 버튼, 좌우 10초 스킵. 우측에 배속/반복을 관리하는 `SpeedChip` 배치.
*   [x] 반응형: 넓은 화면에서는 좌측 스크립트, 우측 단어장/해석 패널로 Split View 적용.
*   [x] 접근성: 현재 문장 강조 시 폰트 두께 변화로 인한 레이아웃 쉬프트(Layout Shift)를 막기 위해 배경색(Chip)으로만 강조.

## 3. 설정 화면
**정보구조 (레이아웃):** 카테고리별 Section 구조. [학습 설정(모드 기본값, 배속)], [자막 뷰어(글자 크기)], [데이터 관리(다운로드)] 순으로 배치.
**핵심 컴포넌트 & 상태:**
*   `SettingsTile`: 직관적인 좌측 아이콘과 우측 스위치.
*   마이크로카피: "오프라인 파일 지우기" (KR) / "Clear offline downloads" (EN). 부연 설명으로 "기기 용량을 확보합니다." 명시.
*   [x] 반응형: 데스크톱에서는 Master-Detail(좌측 메뉴, 우측 설정값) 구조.
*   [x] 접근성: 앱 자체 텍스트 크기 조절 슬라이더 제공.
