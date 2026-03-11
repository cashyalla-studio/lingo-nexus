// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Scripta Sync';

  @override
  String get welcomeBack => '다시 오신 것을 환영합니다!';

  @override
  String get readyToMaster => '오늘도 새로운 언어를 마스터할 준비가 되셨나요?';

  @override
  String get continueStudying => '계속 학습하기';

  @override
  String get myRecentActivity => '최근 활동';

  @override
  String get seeAll => '모두 보기';

  @override
  String get home => '홈';

  @override
  String get library => '라이브러리';

  @override
  String get stats => '통계';

  @override
  String get settings => '설정';

  @override
  String get getStarted => '시작하기';

  @override
  String get importContent => '콘텐츠 불러오기';

  @override
  String get aiSyncAnalyze => 'AI 싱크 및 분석';

  @override
  String get immersiveStudy => '몰입형 학습';

  @override
  String get importDescription => '기기에 있는 오디오와 텍스트 대본을 간편하게 불러오세요.';

  @override
  String get aiSyncDescription => 'AI가 문장을 분석하고 오디오와 완벽하게 동기화합니다.';

  @override
  String get immersiveDescription => '방해 요소 없는 몰입형 플레이어에서 어학 능력을 키워보세요.';

  @override
  String get selectedSentence => '선택된 문장';

  @override
  String get aiGrammarAnalysis => 'AI 문법 분석';

  @override
  String get vocabularyHelper => '단어 도움말';

  @override
  String get shadowingStudio => '쉐도잉 스튜디오';

  @override
  String get aiAutoSync => 'AI 오토 싱크';

  @override
  String get syncDescription => 'Scripta Sync AI를 사용하여 텍스트와 오디오를 손쉽게 정렬하세요.';

  @override
  String get startAutoSync => '오토 싱크 시작 (1 크레딧)';

  @override
  String get buyCredits => '크레딧 구매';

  @override
  String get useOwnApiKey => '또는 본인의 API 키 사용 (BYOK)';

  @override
  String get shadowingNativeSpeaker => '원어민 발음';

  @override
  String get shadowingYourTurn => '내 차례';

  @override
  String get listening => '듣는 중...';

  @override
  String get accuracy => '정확도';

  @override
  String get intonation => '억양';

  @override
  String get fluency => '유창성';

  @override
  String get syncCompleted => '오토 싱크 완료!';

  @override
  String get noContentFound => '콘텐츠가 없습니다. 폴더 아이콘을 눌러 추가하세요.';

  @override
  String get selectFile => '파일을 선택하세요';

  @override
  String get noScriptFile => '대본 파일이 없습니다.';

  @override
  String get noScriptHint => '오디오와 같은 이름의 .txt 파일을 같은 폴더에 넣어주세요.';

  @override
  String get settingsSectionLanguage => '언어';

  @override
  String get settingsSectionAiProvider => 'AI 프로바이더';

  @override
  String get settingsApiKeyManage => 'API 키 관리';

  @override
  String get settingsSectionSubscription => '구독';

  @override
  String get settingsProPlanActive => 'Pro 플랜 구독 중';

  @override
  String get settingsFreePlan => 'Free 플랜 사용 중';

  @override
  String get settingsProPlanSubtitle => '모든 기능 무제한 사용 가능';

  @override
  String get settingsFreePlanSubtitle => 'AI 월 20회, 발음 연습 월 10회';

  @override
  String get settingsSectionData => '데이터';

  @override
  String get settingsRescanLibrary => '라이브러리 다시 스캔';

  @override
  String get settingsRescanSubtitle => '디렉터리에서 새 파일을 검색합니다';

  @override
  String get settingsResetData => '학습 기록 초기화';

  @override
  String get settingsResetSubtitle => '모든 진도 및 기록을 삭제합니다';

  @override
  String get settingsResetDialogTitle => '기록 초기화';

  @override
  String get settingsResetDialogContent => '모든 학습 기록 및 진도가 삭제됩니다. 계속하시겠습니까?';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get settingsResetSuccess => '모든 기록이 초기화되었습니다.';

  @override
  String get settingsSectionCache => '캐시 관리';

  @override
  String get settingsCacheDriveDownload => 'Google Drive 다운로드';

  @override
  String get settingsClearAllCache => '캐시 전체 삭제';

  @override
  String get settingsClearCacheSubtitle => '다운로드된 Google Drive 파일 및 임시 파일 삭제';

  @override
  String get settingsCacheDeleteDialogTitle => '캐시 삭제';

  @override
  String settingsCacheDeleteDialogContent(String size) {
    return '$size의 캐시가 삭제됩니다.';
  }

  @override
  String get settingsCacheDeleteSuccess => '캐시가 삭제되었습니다.';

  @override
  String get settingsAppLanguage => '앱 언어';

  @override
  String get settingsAppLanguageTitle => '앱 언어 선택';

  @override
  String get settingsSystemDefault => '시스템 기본값';

  @override
  String get settingsSystemDefaultSubtitle => '기기 언어를 따릅니다';

  @override
  String homeStreakActive(int days) {
    return '$days일 연속 학습 중!';
  }

  @override
  String homeStreakStats(int longest, int total) {
    return '최장 $longest일 · 총 $total일 학습';
  }

  @override
  String get homeEmptyLibrary => '라이브러리에서 파일을 추가하여 학습을 시작하세요.';

  @override
  String get homeNoHistory => '아직 학습 기록이 없습니다.';

  @override
  String get homeStatusDone => '완료';

  @override
  String get homeStatusStudying => '학습 중';

  @override
  String homeDueReview(int count) {
    return '오늘 복습할 문장 $count개';
  }

  @override
  String get homeNoDueReview => '복습할 문장 없음';

  @override
  String get homeAiConversation => 'AI 대화 연습';

  @override
  String get homeAiConversationSubtitle => '원어민 AI와 자유롭게 대화하기';

  @override
  String get homePhoneticsHub => '발음 훈련 센터';

  @override
  String get homePhoneticsHubSubtitle => 'TTS + 온디바이스 채점 · API 불필요';

  @override
  String get tutorialSkip => '건너뛰기';

  @override
  String get tutorialStart => '시작하기 🚀';

  @override
  String get tutorialNext => '다음';

  @override
  String get playerClipEdit => '클립 편집';

  @override
  String get playerSpeedSuggestion => '70% 이상 들었습니다! 배속을 높여볼까요? 🚀';

  @override
  String get playerSpeedIncrease => '높이기';

  @override
  String get playerMenuDictation => '받아쓰기 연습';

  @override
  String get playerSelectFileFirst => '먼저 오디오 파일을 선택해주세요.';

  @override
  String get playerMenuActiveRecall => '능동 회상 훈련';

  @override
  String get playerMenuBookmark => '북마크 저장';

  @override
  String get playerBookmarkSaved => '북마크에 저장되었습니다!';

  @override
  String get playerBookmarkDuplicate => '이미 북마크된 문장입니다.';

  @override
  String get playerBeginnerMode => '입문자 모드 (0.75x)';

  @override
  String get playerLoopOff => '반복 끔';

  @override
  String get playerLoopOne => '1곡 반복';

  @override
  String get playerLoopAll => '전체 반복';

  @override
  String get playerScriptReady => '대본 준비됨';

  @override
  String get playerNoScript => '대본 없음';

  @override
  String playerAbLoopASet(String time) {
    return 'A: $time — B 미설정';
  }

  @override
  String playerError(String error) {
    return '오류 발생: $error';
  }

  @override
  String get conversationTopicSuggest => '주제 제안';

  @override
  String conversationInputHint(String language) {
    return '$language로 말해보세요...';
  }

  @override
  String conversationPracticeTitle(String language) {
    return '$language 대화 연습';
  }

  @override
  String get conversationWelcomeMsg => 'AI 원어민과 자유롭게 대화하세요.\n실수를 두려워하지 마세요!';

  @override
  String get conversationStartBtn => '대화 시작';

  @override
  String get conversationTopicExamples => '주제 예시';

  @override
  String get statsStudiedContent => '학습한 콘텐츠';

  @override
  String statsItemCount(int count) {
    return '$count개';
  }

  @override
  String get statsTotalTime => '총 학습시간';

  @override
  String statsMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String get statsNoHistory => '아직 학습 기록이 없습니다.\n라이브러리에서 콘텐츠를 추가해보세요.';

  @override
  String get statsProgressByItem => '학습 항목별 진도';

  @override
  String get statsPronunciationProgress => '발음 향상 현황';

  @override
  String get statsPronunciationEmpty => '쉐도잉 연습을 완료하면 발음 향상 기록이 여기에 표시됩니다.';

  @override
  String statsPracticeCount(int count) {
    return '$count회 연습';
  }

  @override
  String get statsStreakSection => '학습 스트릭';

  @override
  String get statsStreakCurrentLabel => '연속 학습';

  @override
  String get statsStreakLongestLabel => '최장 스트릭';

  @override
  String get statsStreakTotalLabel => '총 학습일';

  @override
  String statsDays(int days) {
    return '$days일';
  }

  @override
  String get statsJournal => '학습 일지';

  @override
  String get statsJournalEmpty => '학습을 시작하면 자동으로 일지가 기록됩니다.';

  @override
  String get statsShareCard => '학습 카드 공유';

  @override
  String get statsShareSubtitle => '내 학습 성과를 SNS에 공유해보세요';

  @override
  String get statsMinimalPair => '최소쌍 훈련';

  @override
  String get statsMinimalPairSubtitle => '비슷한 소리 구별하기 (영어/일본어/스페인어)';

  @override
  String statsError(String error) {
    return '오류: $error';
  }

  @override
  String get phoneticsHubFreeTitle => 'AI 없이 발음 훈련';

  @override
  String get phoneticsHubFreeSubtitle =>
      '기기 TTS + 온디바이스 음성인식\nAPI 키 없이 무료로 사용 가능';

  @override
  String get phoneticsHubTrainingTools => '훈련 도구';

  @override
  String get phoneticsComingSoon => '준비 중';

  @override
  String get phoneticsSpanishIpa => '스페인어 IPA';

  @override
  String get phoneticsSpanishIpaSubtitle => '스페인어 발음기호 + 연습 (준비 중)';

  @override
  String get apiKeyRequired => '최소 하나의 API 키를 입력해 주세요.';

  @override
  String get apiKeyInvalidFormat =>
      'OpenAI API 키 형식이 올바르지 않습니다. (sk- 로 시작해야 합니다)';

  @override
  String get apiKeySaved => 'API 키가 안전하게 저장되었습니다.';

  @override
  String get libraryNewPlaylist => '새 플레이리스트';

  @override
  String get libraryImport => '가져오기';

  @override
  String get libraryAllTab => '전체';

  @override
  String get libraryLocalSource => '로컬';

  @override
  String get libraryNoScript => '스크립트없음';

  @override
  String get libraryUnsetLanguage => '미설정';

  @override
  String get libraryEmptyPlaylist => '플레이리스트가 없습니다.';

  @override
  String get libraryCreatePlaylist => '새 플레이리스트 만들기';

  @override
  String libraryTrackCount(int count) {
    return '$count곡';
  }

  @override
  String libraryMoreTracks(int count) {
    return '+ $count곡 더';
  }

  @override
  String get libraryEditNameEmoji => '이름/이모지 수정';

  @override
  String get libraryDeletePlaylist => '삭제';

  @override
  String get libraryEditPlaylist => '플레이리스트 수정';

  @override
  String get librarySetLanguage => '언어 설정';

  @override
  String libraryChangeLanguage(String lang) {
    return '언어 변경 (현재: $lang)';
  }

  @override
  String get libraryAddToPlaylist => '플레이리스트에 추가';

  @override
  String get libraryLanguageBadge => '언어 배지';

  @override
  String get phoneticsQuizTitle => '발음 퀴즈';

  @override
  String get phoneticsQuizDesc => 'IPA 발음기호 ↔ 단어 매칭 퀴즈\n스트릭 보너스 + 정확도 통계';

  @override
  String get phoneticsTtsPracticeTitle => 'TTS 발음 연습';

  @override
  String get phoneticsTtsPracticeDesc =>
      '단어를 듣고 IPA 발음기호와 함께 따라 말하기\nAPI 키 불필요 · 완전 무료';

  @override
  String get phoneticsMinimalPairDesc =>
      '비슷한 소리 구별하기 (ship vs sheep 등)\nTTS 듣기 + 발음 채점 포함';

  @override
  String get phoneticsPitchAccentTitle => '일본어 피치 악센트';

  @override
  String get phoneticsPitchAccentDesc =>
      '同音異義語의 높낮이 패턴 시각화 훈련\n예: はし(箸/橋/端) 구별하기';

  @override
  String get phoneticsKanaDrillTitle => '히라가나 · 가타카나 드릴';

  @override
  String get phoneticsKanaDrillDesc => '모든 가나 문자를 탭하여 TTS 발음 청취\n50음도 전체 수록';

  @override
  String get libraryPlaylistTab => '플레이리스트';

  @override
  String get importTitle => '가져오기';

  @override
  String get importFromDevice => '이 기기에서 가져오기';

  @override
  String get importFromDeviceSubtitle => '로컬 폴더에서 오디오+스크립트 불러오기';

  @override
  String get importFromICloud => 'iCloud Drive에서 가져오기';

  @override
  String get importFromICloudSubtitle => 'iCloud Drive 폴더를 라이브러리에 연결';

  @override
  String get importFromGoogleDrive => 'Google Drive에서 가져오기';

  @override
  String get importFromGoogleDriveSubtitle => 'Google Drive 폴더를 탐색하고 다운로드';

  @override
  String get importAutoSync => 'Scripta Sync iCloud 폴더 자동 동기화';

  @override
  String get importAutoSyncSubtitle => 'iCloud Drive/Scripta Sync/ 폴더를 자동 스캔';

  @override
  String heatmapTitle(int weeks) {
    return '학습 기록 (최근 $weeks주)';
  }

  @override
  String heatmapTooltip(String date, int minutes) {
    return '$date: $minutes분';
  }

  @override
  String get heatmapNoActivity => '학습 없음';

  @override
  String get heatmapLess => '적음';

  @override
  String get heatmapMore => '많음';

  @override
  String get loginSubtitle => 'AI 언어 튜터로 더 빠르게 실력을 키우세요';

  @override
  String get loginWithGoogle => 'Google로 계속하기';

  @override
  String get loginFeatureAi => 'AI 문법·어휘·대화 튜터 (무료)';

  @override
  String get loginFeaturePronunciation => '발음 평가 및 성조 훈련';

  @override
  String get loginFeatureSync => 'AI 오토싱크 — 오디오에서 대본 자동 생성';

  @override
  String get loginFeatureFree => '매일 3분 무료 AI 오디오 처리';

  @override
  String get loginLegalPrefix => '계속하면 ';

  @override
  String get loginTermsLink => '서비스 이용약관';

  @override
  String get loginLegalAnd => '및';

  @override
  String get loginPrivacyLink => '개인정보처리방침';

  @override
  String get loginLegalSuffix => '에 동의하는 것으로 간주됩니다.';

  @override
  String get settingsSectionAccount => '계정';

  @override
  String get settingsLogin => '로그인';

  @override
  String get settingsLoginSubtitle => 'AI 기능을 사용하려면 로그인이 필요합니다';

  @override
  String get settingsSectionCredits => '크레딧 & 구독';

  @override
  String get settingsCreditsSubtitle => 'AI 오디오 크레딧 및 구독 관리';

  @override
  String get settingsLogout => '로그아웃';

  @override
  String get settingsLogoutDialogTitle => '로그아웃';

  @override
  String get settingsLogoutDialogContent => '로그아웃 하시겠습니까?';

  @override
  String get settingsSectionLegal => '법적 고지';

  @override
  String get settingsTermsSubtitle => '서비스 이용 조건을 확인하세요';

  @override
  String get settingsPrivacySubtitle => '개인정보 수집 및 처리 방침';

  @override
  String get creditsTitle => '크레딧';

  @override
  String get creditsDailyFree => '오늘의 무료 사용량';

  @override
  String get creditsMinRemaining => '분 남음';

  @override
  String get creditsDailyResets => '매일 자정에 초기화';

  @override
  String get creditsPurchasedCredits => '구매한 크레딧';

  @override
  String get creditsMinutes => '분';

  @override
  String get creditsSubscriptionActive => '구독 활성';

  @override
  String get creditsSubscriptionsTitle => '구독 플랜';

  @override
  String get creditsMostPopular => '인기';

  @override
  String get creditsPerMonth => '/ 월';

  @override
  String get creditPacksTitle => '크레딧 패키지';

  @override
  String get creditPacksSubtitle => '한 번 결제, 기간 없이 사용';

  @override
  String get creditsLoadError => '크레딧 정보를 불러올 수 없습니다.';

  @override
  String get creditsPaymentComingSoon => '결제 시스템 준비 중입니다';

  @override
  String get termsTitle => '서비스 이용약관';

  @override
  String get termsLastUpdated => '최종 수정: 2025년 3월';

  @override
  String get termsSec1Title => '1. 서비스 개요';

  @override
  String get termsSec1Body =>
      'LingoNexus(이하 \'서비스\')는 AI 기반 언어 학습 플랫폼입니다. 본 약관은 서비스 이용에 관한 조건을 규정합니다.';

  @override
  String get termsSec2Title => '2. 계정 및 인증';

  @override
  String get termsSec2Body =>
      'AI 기능을 이용하려면 Google 계정으로 로그인해야 합니다. 계정 정보의 보안은 본인이 책임집니다. 타인의 계정을 무단으로 사용하는 것은 금지됩니다.';

  @override
  String get termsSec3Title => '3. 크레딧 및 결제';

  @override
  String get termsSec3Body =>
      'AI 오디오 처리(음성 전사, 발음 평가 등)는 크레딧을 소모합니다. 매일 3분(180초)의 무료 사용량이 제공됩니다. 구매한 크레딧은 환불되지 않습니다. 결제는 앱 내 구매를 통해 이루어집니다.';

  @override
  String get termsSec4Title => '4. 이용 제한';

  @override
  String get termsSec4Body =>
      '서비스를 악용하거나 자동화된 방법으로 과도하게 사용하는 행위는 금지됩니다. 1회 업로드 최대 10분 제한이 있습니다. 위반 시 계정이 제한될 수 있습니다.';

  @override
  String get termsSec5Title => '5. 지적 재산권';

  @override
  String get termsSec5Body =>
      '사용자가 업로드한 콘텐츠의 저작권은 사용자에게 있습니다. 서비스의 AI 결과물은 참고용이며, 상업적 용도로 무단 사용할 수 없습니다.';

  @override
  String get termsSec6Title => '6. 면책 조항';

  @override
  String get termsSec6Body =>
      '서비스는 AI 결과물의 정확성을 보장하지 않습니다. 서비스 장애, 데이터 손실 등에 대한 책임은 제한됩니다. 이용약관은 사전 고지 없이 변경될 수 있습니다.';

  @override
  String get privacyTitle => '개인정보처리방침';

  @override
  String get privacyLastUpdated => '최종 수정: 2025년 3월';

  @override
  String get privacySec1Title => '1. 수집하는 정보';

  @override
  String get privacySec1Body =>
      'Google 로그인 시 이메일, 이름, 프로필 사진을 수집합니다. AI 기능 이용 시 오디오 데이터를 처리하며 서버에 저장하지 않습니다. 크레딧 사용 내역 및 구독 정보를 저장합니다.';

  @override
  String get privacySec2Title => '2. 정보 이용 목적';

  @override
  String get privacySec2Body =>
      '수집된 정보는 서비스 제공, 크레딧 관리, 고객 지원에만 사용됩니다. 제3자에게 개인정보를 판매하거나 공유하지 않습니다.';

  @override
  String get privacySec3Title => '3. 정보 보관 및 보안';

  @override
  String get privacySec3Body =>
      '인증 토큰은 기기의 암호화된 저장소(Keychain/Keystore)에 안전하게 보관됩니다. 서버의 민감 정보는 암호화하여 저장합니다.';

  @override
  String get privacySec4Title => '4. 제3자 서비스';

  @override
  String get privacySec4Body =>
      'Google Sign-In, Google Gemini API, Alibaba Qwen API를 사용합니다. 각 서비스의 개인정보처리방침이 적용됩니다.';

  @override
  String get privacySec5Title => '5. 사용자 권리';

  @override
  String get privacySec5Body =>
      '언제든지 계정 삭제 및 개인정보 삭제를 요청할 수 있습니다. 문의: support@lingonexus.app';

  @override
  String get syncNoiseWarning =>
      '주변 잡음이 많으면 전사 정확도가 낮아질 수 있습니다. 조용한 환경에서 녹음된 오디오를 사용하세요.';

  @override
  String get syncTranslationLanguage => '번역 언어';

  @override
  String get syncAudioLanguage => '오디오 언어';

  @override
  String get syncAnnotating => '발음기호 및 번역 생성 중…';

  @override
  String syncScriptSaved(Object count) {
    return '$count개 문장 싱크 완료! 스크립트가 저장되었습니다.';
  }
}
