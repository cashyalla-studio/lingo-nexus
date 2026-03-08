import 'package:flutter_tts/flutter_tts.dart';

/// flutter_tts를 Riverpod-friendly하게 래핑한 TTS 서비스
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _tts.setSharedInstance(true);
    _initialized = true;
  }

  /// 영어 단어/문장 읽기
  Future<void> speak(String text, {String language = 'en-US', double rate = 0.5}) async {
    await _ensureInitialized();
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  /// 일본어 읽기
  Future<void> speakJapanese(String text, {double rate = 0.5}) async {
    await speak(text, language: 'ja-JP', rate: rate);
  }

  /// 스페인어 읽기
  Future<void> speakSpanish(String text, {double rate = 0.5}) async {
    await speak(text, language: 'es-ES', rate: rate);
  }

  /// 천천히 읽기 (0.3x)
  Future<void> speakSlow(String text, {String language = 'en-US'}) async {
    await speak(text, language: language, rate: 0.3);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}
