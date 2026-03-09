/// 앱에서 지원하는 학습 언어 목록
const List<({String code, String name, String emoji})> kStudyLanguages = [
  (code: 'ko', name: '한국어', emoji: '🇰🇷'),
  (code: 'en', name: 'English', emoji: '🇺🇸'),
  (code: 'ja', name: '日本語', emoji: '🇯🇵'),
  (code: 'zh', name: '中文', emoji: '🇨🇳'),
  (code: 'es', name: 'Español', emoji: '🇪🇸'),
  (code: 'de', name: 'Deutsch', emoji: '🇩🇪'),
  (code: 'fr', name: 'Français', emoji: '🇫🇷'),
  (code: 'pt', name: 'Português', emoji: '🇵🇹'),
  (code: 'ar', name: 'العربية', emoji: '🇸🇦'),
  (code: 'other', name: '기타', emoji: '🌐'),
];

/// code → name
String langName(String? code) {
  if (code == null) return '미설정';
  return kStudyLanguages.firstWhere(
    (l) => l.code == code,
    orElse: () => (code: code, name: code, emoji: '🌐'),
  ).name;
}

/// code → emoji
String langEmoji(String? code) {
  if (code == null) return '🌐';
  return kStudyLanguages.firstWhere(
    (l) => l.code == code,
    orElse: () => (code: code, name: code, emoji: '🌐'),
  ).emoji;
}
