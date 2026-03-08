import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../core/providers/ai_provider.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/services/pronunciation_history_service.dart';
import '../../core/models/pronunciation_history_entry.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

final pronunciationHistoryServiceProvider = Provider((ref) => PronunciationHistoryService());

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

class ShadowingNotifier extends StateNotifier<ShadowingState> {
  ShadowingNotifier(this._ref) : super(ShadowingState.idle);
  final Ref _ref;

  bool _disposed = false;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _previewPlayer = AudioPlayer();
  String? _recordingPath;
  ShadowingScore? _score;
  List<PronunciationHistoryEntry> _sentenceHistory = [];

  ShadowingScore? get score => _score;
  String? get recordingPath => _recordingPath;
  List<PronunciationHistoryEntry> get sentenceHistory => _sentenceHistory;

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

  Future<void> scoreRecording(String originalText, String? openAiKey) async {
    state = ShadowingState.processing;

    if (_recordingPath == null || openAiKey == null || openAiKey.isEmpty) {
      // Fallback score when no API key or recording
      _score = const ShadowingScore(accuracy: 0, intonation: 0, fluency: 0);
      state = ShadowingState.done;
      return;
    }

    try {
      // Transcribe with Whisper
      final file = File(_recordingPath!);
      if (!await file.exists()) {
        _score = const ShadowingScore(accuracy: 0, intonation: 0, fluency: 0);
        state = ShadowingState.done;
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
      );
      request.headers['Authorization'] = 'Bearer $openAiKey';
      request.fields['model'] = 'whisper-1';
      request.fields['response_format'] = 'json';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _recordingPath!,
        contentType: MediaType.parse('audio/mp4'),
      ));

      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: 60));
      final body = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final transcription = jsonDecode(body)['text'] as String;
        _score = _calculateScore(originalText, transcription);
      } else {
        _score = const ShadowingScore(accuracy: 0, intonation: 0, fluency: 0);
      }
    } catch (e) {
      _score = const ShadowingScore(accuracy: 0, intonation: 0, fluency: 0);
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
      // Refresh in-memory history for the current sentence
      if (!_disposed) {
        _sentenceHistory = await historyService.getHistoryForSentence(sentenceId);
      }
    }
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
    // Intonation and fluency are approximated from word count ratio
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

  /// 내 녹음 재생
  Future<void> playRecording() async {
    if (_recordingPath == null) return;

    await _previewPlayer.stop();
    _ref.read(comparisonPlaybackProvider.notifier).state =
        ComparisonPlaybackMode.playingRecording;

    await _previewPlayer.setFilePath(_recordingPath!);
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

  /// 원본 오디오의 특정 구간 재생
  Future<void> playOriginalSegment(
      String audioPath, Duration start, Duration end) async {
    await _previewPlayer.stop();
    _ref.read(comparisonPlaybackProvider.notifier).state =
        ComparisonPlaybackMode.playingOriginal;

    await _previewPlayer.setFilePath(audioPath);
    await _previewPlayer.seek(start);
    await _previewPlayer.play();

    // Stop at end time
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

  void reset() {
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
