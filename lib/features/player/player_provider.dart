import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/models/study_item.dart';
import '../../core/models/sync_item.dart';
import '../../core/services/progress_service.dart';
import '../scanner/scanner_provider.dart';
import 'audio_engine.dart';

final currentStudyItemProvider = StateProvider<StudyItem?>((ref) => null);

final currentScriptContentProvider = FutureProvider<String>((ref) async {
  final item = ref.watch(currentStudyItemProvider);
  if (item == null || item.scriptPath == null) {
    return "대본 파일이 없습니다.";
  }
  
  final scriptPath = item.scriptPath!; // safe after null check
  final file = File(scriptPath);
  if (!await file.exists()) {
    return "대본 파일을 찾을 수 없습니다: ${item.scriptPath}";
  }
  return await file.readAsString();
});

final isPlayingProvider = StreamProvider<bool>((ref) {
  return ref.watch(audioEngineProvider).player.playingStream;
});

// 현재 배속 상태 스트림
final playbackSpeedProvider = StreamProvider<double>((ref) {
  return ref.watch(audioEngineProvider).player.speedStream;
});

// 현재 반복 모드 스트림
final loopModeProvider = StreamProvider<LoopMode>((ref) {
  return ref.watch(audioEngineProvider).player.loopModeStream;
});

// Current position stream
final positionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioEngineProvider).player.positionStream;
});

// Total duration stream
final durationProvider = StreamProvider<Duration?>((ref) {
  return ref.watch(audioEngineProvider).player.durationStream;
});

// SyncItems for the current study item (set externally after Auto-Sync)
final currentSyncItemsProvider = StateProvider<List<SyncItem>>((ref) => []);

// Preferred speed for the current study item (persisted)
final preferredSpeedProvider = FutureProvider<double>((ref) async {
  final item = ref.watch(currentStudyItemProvider);
  if (item == null) return 1.0;
  final service = ref.watch(progressServiceProvider);
  return await service.loadSpeed(item.audioPath);
});

// Suggests a speed upgrade when user has listened to >70% and speed is below 1.25x
final speedUpgradeSuggestionProvider = Provider<bool>((ref) {
  final position = ref.watch(positionProvider).value ?? Duration.zero;
  final duration = ref.watch(durationProvider).value;
  final speed = ref.watch(playbackSpeedProvider).value ?? 1.0;

  if (duration == null || duration.inSeconds == 0) return false;
  final progress = position.inMilliseconds / duration.inMilliseconds;
  // Suggest upgrade if: listened >70% of content AND speed is below 1.25x
  return progress > 0.7 && speed < 1.25;
});

// A-B 루프 상태 — start/end 포인트 (null 이면 비활성)
class AbLoopState {
  final Duration? start;
  final Duration? end;
  const AbLoopState({this.start, this.end});

  bool get isActive => start != null && end != null;
  bool get hasStart => start != null;

  AbLoopState withStart(Duration d) => AbLoopState(start: d, end: end);
  AbLoopState withEnd(Duration d) => AbLoopState(start: start, end: d);
  AbLoopState cleared() => const AbLoopState();
}

class AbLoopNotifier extends StateNotifier<AbLoopState> {
  AbLoopNotifier() : super(const AbLoopState());

  void setStart(Duration d) => state = state.withStart(d);
  void setEnd(Duration d) => state = state.withEnd(d);
  void clear() => state = state.cleared();
}

final abLoopProvider = StateNotifierProvider<AbLoopNotifier, AbLoopState>(
  (ref) => AbLoopNotifier(),
);

// Active sentence index based on current position and sync items
final activeSentenceIndexProvider = Provider<int>((ref) {
  final position = ref.watch(positionProvider).value ?? Duration.zero;
  final syncItems = ref.watch(currentSyncItemsProvider);
  if (syncItems.isEmpty) return 0;

  for (int i = syncItems.length - 1; i >= 0; i--) {
    if (position >= syncItems[i].startTime) return i;
  }
  return 0;
});
