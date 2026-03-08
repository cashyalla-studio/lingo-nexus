import 'package:speech_to_text/speech_to_text.dart';

/// 온디바이스 STT를 이용한 발음 평가 서비스 (API 키 불필요)
class PhonemeEvalService {
  final SpeechToText _stt = SpeechToText();
  bool _available = false;
  bool _initialized = false;

  Future<bool> initialize() async {
    if (_initialized) return _available;
    _available = await _stt.initialize(
      onError: (error) {},
      onStatus: (status) {},
    );
    _initialized = true;
    return _available;
  }

  bool get isAvailable => _available;
  bool get isListening => _stt.isListening;

  /// 지정된 언어로 음성 인식 시작, 인식된 텍스트를 콜백으로 전달
  Future<void> startListening({
    required void Function(String text) onResult,
    String localeId = 'en-US',
    Duration listenFor = const Duration(seconds: 5),
  }) async {
    if (!_available) await initialize();
    if (!_available) return;

    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: localeId,
      listenFor: listenFor,
      pauseFor: const Duration(seconds: 3),
      cancelOnError: false,
      partialResults: false,
    );
  }

  Future<void> stopListening() async {
    if (_stt.isListening) await _stt.stop();
  }

  /// 인식된 텍스트와 목표 텍스트를 비교해 점수를 반환 (0~100)
  PronunciationResult evaluate({
    required String recognized,
    required String target,
  }) {
    if (recognized.trim().isEmpty) {
      return const PronunciationResult(score: 0, feedback: '발음이 인식되지 않았습니다. 다시 시도해보세요.');
    }

    final recognizedClean = recognized.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
    final targetClean = target.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();

    final targetWords = targetClean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final recognizedWords = recognizedClean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    if (targetWords.isEmpty) return const PronunciationResult(score: 0, feedback: '오류');

    // 단어 매칭 (순서 무관)
    int matched = 0;
    for (final word in targetWords) {
      if (recognizedWords.contains(word)) matched++;
    }

    final score = ((matched / targetWords.length) * 100).round().clamp(0, 100);

    String feedback;
    if (score >= 90) {
      feedback = '완벽합니다! 원어민 수준의 발음이에요. 🎉';
    } else if (score >= 70) {
      feedback = '잘 하셨어요! 조금 더 연습하면 완벽해질 거예요.';
    } else if (score >= 50) {
      feedback = '좋은 시도입니다. TTS를 다시 듣고 따라해보세요.';
    } else if (score > 0) {
      feedback = '더 연습이 필요해요. 천천히 따라해보세요.';
    } else {
      feedback = '발음 인식이 어렵습니다. 더 크게, 명확히 발음해보세요.';
    }

    return PronunciationResult(
      score: score,
      feedback: feedback,
      recognized: recognized,
    );
  }

  void dispose() {
    if (_stt.isListening) _stt.stop();
  }
}

class PronunciationResult {
  final int score;
  final String feedback;
  final String? recognized;

  const PronunciationResult({
    required this.score,
    required this.feedback,
    this.recognized,
  });
}
