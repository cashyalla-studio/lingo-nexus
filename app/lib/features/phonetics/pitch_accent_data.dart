/// 일본어 피치 악센트 데이터 (JMDict 기반 주요 단어)
/// 피치 패턴: H=高(high), L=低(low), 각 문자/모라별 패턴
class PitchAccentData {
  /// 단어 -> (독음, 피치패턴, 의미)
  static const Map<String, PitchEntry> words = {
    // 명사
    'あめ': PitchEntry(reading: 'あめ', pattern: [PitchType.low, PitchType.high], meaning: '雨(비)'),
    // あめ 雨 vs 飴 - same kana, different pitch
    'あめ飴': PitchEntry(reading: 'あめ', pattern: [PitchType.high, PitchType.low], meaning: '飴(사탕)'),
    'はし箸': PitchEntry(reading: 'はし', pattern: [PitchType.low, PitchType.high], meaning: '箸(젓가락)'),
    'はし橋': PitchEntry(reading: 'はし', pattern: [PitchType.high, PitchType.low], meaning: '橋(다리)'),
    'はし端': PitchEntry(reading: 'はし', pattern: [PitchType.high, PitchType.high], meaning: '端(끝, 가장자리)'),
    'かき柿': PitchEntry(reading: 'かき', pattern: [PitchType.low, PitchType.high], meaning: '柿(감)'),
    'かき牡蠣': PitchEntry(reading: 'かき', pattern: [PitchType.high, PitchType.low], meaning: '牡蠣(굴)'),
    'さくら': PitchEntry(reading: 'さくら', pattern: [PitchType.low, PitchType.high, PitchType.high], meaning: '桜(벚꽃)'),
    'やま': PitchEntry(reading: 'やま', pattern: [PitchType.low, PitchType.high], meaning: '山(산)'),
    'かわ': PitchEntry(reading: 'かわ', pattern: [PitchType.low, PitchType.high], meaning: '川(강)'),
    'きく': PitchEntry(reading: 'きく', pattern: [PitchType.high, PitchType.low], meaning: '聞く(듣다)'),
    'みる': PitchEntry(reading: 'みる', pattern: [PitchType.high, PitchType.low], meaning: '見る(보다)'),
    'たべる': PitchEntry(reading: 'たべる', pattern: [PitchType.low, PitchType.high, PitchType.high], meaning: '食べる(먹다)'),
    'のむ': PitchEntry(reading: 'のむ', pattern: [PitchType.high, PitchType.low], meaning: '飲む(마시다)'),
    'いく': PitchEntry(reading: 'いく', pattern: [PitchType.high, PitchType.low], meaning: '行く(가다)'),
    'くる': PitchEntry(reading: 'くる', pattern: [PitchType.high, PitchType.low], meaning: '来る(오다)'),
    'おばさん': PitchEntry(reading: 'おばさん', pattern: [PitchType.low, PitchType.high, PitchType.high, PitchType.low], meaning: '叔母さん(아주머니)'),
    'おばあさん': PitchEntry(reading: 'おばあさん', pattern: [PitchType.low, PitchType.high, PitchType.high, PitchType.high, PitchType.low], meaning: 'お祖母さん(할머니)'),
    'にほん': PitchEntry(reading: 'にほん', pattern: [PitchType.low, PitchType.high, PitchType.high], meaning: '日本(일본)'),
    'とうきょう': PitchEntry(reading: 'とうきょう', pattern: [PitchType.low, PitchType.high, PitchType.high, PitchType.high], meaning: '東京(도쿄)'),
    'きれい': PitchEntry(reading: 'きれい', pattern: [PitchType.low, PitchType.high, PitchType.high], meaning: '綺麗(예쁘다)'),
    'おいしい': PitchEntry(reading: 'おいしい', pattern: [PitchType.low, PitchType.high, PitchType.high, PitchType.high], meaning: '美味しい(맛있다)'),
    'たのしい': PitchEntry(reading: 'たのしい', pattern: [PitchType.low, PitchType.high, PitchType.high, PitchType.high], meaning: '楽しい(즐겁다)'),
    'むずかしい': PitchEntry(reading: 'むずかしい', pattern: [PitchType.low, PitchType.high, PitchType.high, PitchType.high, PitchType.high], meaning: '難しい(어렵다)'),
    'わたし': PitchEntry(reading: 'わたし', pattern: [PitchType.low, PitchType.high, PitchType.low], meaning: '私(나)'),
    'あなた': PitchEntry(reading: 'あなた', pattern: [PitchType.low, PitchType.high, PitchType.low], meaning: 'あなた(당신)'),
    'ありがとう': PitchEntry(reading: 'ありがとう', pattern: [PitchType.low, PitchType.high, PitchType.high, PitchType.high, PitchType.low], meaning: 'ありがとう(감사합니다)'),
  };

  static List<String> get allKeys => words.keys.toList();
}

enum PitchType { high, low }

class PitchEntry {
  final String reading;
  final List<PitchType> pattern;
  final String meaning;

  const PitchEntry({
    required this.reading,
    required this.pattern,
    required this.meaning,
  });
}
