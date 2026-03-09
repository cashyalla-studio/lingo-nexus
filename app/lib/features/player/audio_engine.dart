import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioEngineProvider = Provider<AudioEngine>((ref) {
  final engine = AudioEngine();
  ref.onDispose(() => engine.dispose());
  return engine;
});

class AudioEngine {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  // A-B 루프 상태
  Duration? _abStart;
  Duration? _abEnd;
  StreamSubscription<Duration>? _abSub;

  Duration? get abStart => _abStart;
  Duration? get abEnd => _abEnd;
  bool get isAbLoopActive => _abStart != null && _abEnd != null;

  void setAbLoop(Duration start, Duration end) {
    _abStart = start;
    _abEnd = end;
    _abSub?.cancel();
    _abSub = _player.positionStream.listen((pos) {
      if (_abEnd != null && pos >= _abEnd!) {
        _player.seek(_abStart!);
      }
    });
  }

  void clearAbLoop() {
    _abSub?.cancel();
    _abSub = null;
    _abStart = null;
    _abEnd = null;
  }

  Future<void> loadFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('오디오 파일을 찾을 수 없습니다: $filePath');
    }
    await _player.setFilePath(filePath);
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// 루프 모드 토글 (Off -> One -> All -> Off)
  Future<void> toggleLoopMode() async {
    final current = _player.loopMode;
    if (current == LoopMode.off) {
      await _player.setLoopMode(LoopMode.one); // 한 곡 반복
    } else if (current == LoopMode.one) {
      await _player.setLoopMode(LoopMode.all); // 전체 반복
    } else {
      await _player.setLoopMode(LoopMode.off); // 반복 끄기
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> skipForward() async {
    final current = _player.position;
    await _player.seek(current + const Duration(seconds: 10));
  }

  Future<void> skipBackward() async {
    final current = _player.position;
    final target = current - const Duration(seconds: 10);
    await _player.seek(target < Duration.zero ? Duration.zero : target);
  }

  void dispose() {
    _abSub?.cancel();
    _player.dispose();
  }
}
