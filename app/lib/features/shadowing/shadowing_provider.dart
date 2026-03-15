import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../core/services/pronunciation_history_service.dart';
import '../../core/models/pronunciation_history_entry.dart';
import '../../core/services/native_stt_service.dart';
import '../../core/config/server_config.dart';
import 'package:http/http.dart' as http;

final pronunciationHistoryServiceProvider = Provider((ref) => PronunciationHistoryService());

final nativeSttServiceProvider = Provider((ref) => NativeSttService());

enum ShadowingState { idle, recording, processing, done }

enum ComparisonPlaybackMode { none, playingOriginal, playingRecording }

class ShadowingScore {
  final int accuracy;
  final int intonation;
  final int fluency;
  final String? recordedTranscription;
  final List<String> incorrectWords;

  const ShadowingScore({
    required this.accuracy,
    required this.intonation,
    required this.fluency,
    this.recordedTranscription,
    this.incorrectWords = const [],
  });
}

class RecordingAttempt {
  final String path;
  final ShadowingScore score;
  final int attemptNumber;

  RecordingAttempt({
    required this.path,
    required this.score,
    required this.attemptNumber,
  });
}

class ShadowingNotifier extends StateNotifier<ShadowingState> {
  ShadowingNotifier(this._ref) : super(ShadowingState.idle);
  final Ref _ref;

  bool _disposed = false;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _previewPlayer = AudioPlayer();
  String? _recordingPath;
  ShadowingScore? _score;
  List<PronunciationHistoryEntry> _sentenceHistory = [];

  final List<RecordingAttempt> _attempts = [];
  static const int maxAttempts = 5;

  ShadowingScore? get score => _score;
  String? get recordingPath => _recordingPath;
  List<PronunciationHistoryEntry> get sentenceHistory => _sentenceHistory;
  List<RecordingAttempt> get attempts => List.unmodifiable(_attempts);
  ShadowingScore? get bestScore => _attempts.isEmpty
      ? null
      : _attempts.reduce((a, b) => a.score.accuracy >= b.score.accuracy ? a : b).score;
  bool get canRecordMore => _attempts.length < maxAttempts;

  Future<void> loadHistoryForSentence(String sentence) async {
    if (_disposed) return;
    final service = _ref.read(pronunciationHistoryServiceProvider);
    final id = PronunciationHistoryEntry.computeId(sentence);
    _sentenceHistory = await service.getHistoryForSentence(id);
  }

  Future<void> startRecording() async {
    if (!await _recorder.hasPermission()) {
      state = ShadowingState.idle;
      return;
    }

    final dir = await getTemporaryDirectory();
    _recordingPath =
        '${dir.path}/shadowing_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
          encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100),
      path: _recordingPath!,
    );
    state = ShadowingState.recording;
  }

  Future<void> stopRecording() async {
    await _recorder.stop();
    state = ShadowingState.processing;
  }

  Future<void> scoreRecording(String originalText, String? language) async {
    state = ShadowingState.processing;

    if (_recordingPath == null) {
      _score = const ShadowingScore(accuracy: 0, intonation: 0, fluency: 0);
      state = ShadowingState.done;
      return;
    }

    final sttService = _ref.read(nativeSttServiceProvider);
    String? transcription;
    final langCode = language ?? 'en';

    if (await sttService.isAvailable(langCode)) {
      try {
        final result = await sttService.transcribeFile(_recordingPath!, langCode);
        // NativeSttService.transcribeFile returns raw text (not JSON) for shadowing
        // but per memory, iOS returns JSON with {"text":..., "segments":[...]}
        // Try JSON first, fall back to raw string
        try {
          final decoded = jsonDecode(result);
          if (decoded is Map) {
            transcription = decoded['text'] as String?;
          } else {
            transcription = result.isNotEmpty ? result : null;
          }
        } catch (_) {
          transcription = result.isNotEmpty ? result : null;
        }
      } catch (_) {
        transcription = null;
      }
    }

    if (transcription != null && transcription.isNotEmpty) {
      _score = _calculateScore(originalText, transcription);
    } else {
      _score = await _serverScore(originalText, langCode);
    }

    // Add to attempts list
    if (_score != null) {
      _attempts.add(RecordingAttempt(
        path: _recordingPath!,
        score: _score!,
        attemptNumber: _attempts.length + 1,
      ));
    }

    state = ShadowingState.done;

    // Record to history if we have a valid score
    if (_score != null && _score!.accuracy > 0) {
      final historyService = _ref.read(pronunciationHistoryServiceProvider);
      final sentenceId = PronunciationHistoryEntry.computeId(originalText);
      await historyService.addEntry(PronunciationHistoryEntry(
        sentenceId: sentenceId,
        sentence: originalText,
        score: _score!.accuracy,
        recordedAt: DateTime.now(),
      ));
      if (!_disposed) {
        _sentenceHistory = await historyService.getHistoryForSentence(sentenceId);
      }
    }
  }

  Future<ShadowingScore> _serverScore(String originalText, String language) async {
    try {
      final bytes = await File(_recordingPath!).readAsBytes();
      final audioBase64 = base64Encode(bytes);
      final url = '${ServerConfig.baseUrl}/api/v1/shadowing/score';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'audio_base64': audioBase64,
          'original_text': originalText,
          'language': language,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShadowingScore(
          accuracy: (data['accuracy'] as num).toInt(),
          intonation: (data['intonation'] as num).toInt(),
          fluency: (data['fluency'] as num).toInt(),
          recordedTranscription: data['transcription'] as String?,
          incorrectWords: List<String>.from(data['incorrect_words'] ?? []),
        );
      }
    } catch (_) {}
    // Last fallback
    return const ShadowingScore(accuracy: 0, intonation: 0, fluency: 0);
  }

  ShadowingScore _calculateScore(String original, String transcription) {
    final origWords = original
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final transWords = transcription
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    // Word-level accuracy
    int matched = 0;
    final List<String> incorrect = [];
    for (final word in origWords) {
      final clean = word.replaceAll(RegExp(r'[^\w]'), '');
      if (transWords
          .any((tw) => tw.replaceAll(RegExp(r'[^\w]'), '') == clean)) {
        matched++;
      } else {
        incorrect.add(clean);
      }
    }

    final accuracy = origWords.isEmpty
        ? 0
        : ((matched / origWords.length) * 100).round().clamp(0, 100);
    final lengthRatio = origWords.isEmpty
        ? 0.0
        : (transWords.length / origWords.length).clamp(0.0, 2.0);
    final fluency =
        (100 - ((1.0 - lengthRatio).abs() * 50)).round().clamp(0, 100);
    final intonation = ((accuracy + fluency) / 2).round().clamp(0, 100);

    return ShadowingScore(
      accuracy: accuracy,
      intonation: intonation,
      fluency: fluency,
      recordedTranscription: transcription,
      incorrectWords: incorrect,
    );
  }

  /// Play a specific attempt's recording
  Future<void> playAttemptRecording(String path) async {
    await _previewPlayer.stop();
    _ref.read(comparisonPlaybackProvider.notifier).state =
        ComparisonPlaybackMode.playingRecording;

    await _previewPlayer.setFilePath(path);
    await _previewPlayer.play();
    await _previewPlayer.playerStateStream.firstWhere(
      (s) =>
          s.processingState == ProcessingState.completed ||
          s.playing == false,
    );

    if (!_disposed) {
      _ref.read(comparisonPlaybackProvider.notifier).state =
          ComparisonPlaybackMode.none;
    }
  }

  /// 내 녹음 재생
  Future<void> playRecording() async {
    if (_recordingPath == null) return;
    await playAttemptRecording(_recordingPath!);
  }

  /// 원본 오디오의 특정 구간 재생
  Future<void> playOriginalSegment(
      String audioPath, Duration start, Duration end) async {
    await _previewPlayer.stop();
    _ref.read(comparisonPlaybackProvider.notifier).state =
        ComparisonPlaybackMode.playingOriginal;

    await _previewPlayer.setFilePath(audioPath);
    await _previewPlayer.seek(start);
    await _previewPlayer.play();

    final segmentDuration = end - start;
    await Future.delayed(segmentDuration);
    await _previewPlayer.stop();

    if (!_disposed) {
      _ref.read(comparisonPlaybackProvider.notifier).state =
          ComparisonPlaybackMode.none;
    }
  }

  /// 순차 비교: 원본 → 짧은 쉬임 → 내 녹음
  Future<void> playComparison(
      String audioPath, Duration start, Duration end) async {
    await playOriginalSegment(audioPath, start, end);
    await Future.delayed(const Duration(milliseconds: 600));
    await playRecording();
  }

  Future<void> stopPlayback() async {
    await _previewPlayer.stop();
    if (!_disposed) {
      _ref.read(comparisonPlaybackProvider.notifier).state =
          ComparisonPlaybackMode.none;
    }
  }

  /// Reset for a new attempt (keeps attempts list visible until newSession)
  void reset() {
    _score = null;
    _recordingPath = null;
    state = ShadowingState.idle;
  }

  /// Start a completely new session — clears all attempts
  void newSession() {
    _attempts.clear();
    _score = null;
    _recordingPath = null;
    state = ShadowingState.idle;
  }

  @override
  void dispose() {
    _disposed = true;
    _recorder.dispose();
    _previewPlayer.dispose();
    super.dispose();
  }
}

final comparisonPlaybackProvider =
    StateProvider.autoDispose<ComparisonPlaybackMode>((ref) {
  return ComparisonPlaybackMode.none;
});

final shadowingProvider =
    StateNotifierProvider.autoDispose<ShadowingNotifier, ShadowingState>((ref) {
  return ShadowingNotifier(ref);
});
