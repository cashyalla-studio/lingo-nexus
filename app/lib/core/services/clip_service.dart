import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import '../models/study_item.dart';
import '../models/sync_item.dart';

class ClipService {
  Future<Directory> get _clipsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'clips'));
    await dir.create(recursive: true);
    return dir;
  }

  Future<List<StudyItem>> loadClips() async {
    final dir = await _clipsDir;
    final clips = <StudyItem>[];
    const audioExts = {'.mp3', '.m4a', '.wav'};
    await for (final entity in dir.list()) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (audioExts.contains(ext)) {
          final title = p.basenameWithoutExtension(entity.path);
          final scriptPath = '${p.withoutExtension(entity.path)}.txt';
          clips.add(StudyItem(
            title: title,
            audioPath: entity.path,
            scriptPath: File(scriptPath).existsSync() ? scriptPath : null,
            source: StudyItemSource.local,
          ));
        }
      }
    }
    return clips;
  }

  /// [start]~[end] 구간을 잘라 clips 디렉터리에 저장합니다.
  /// 성공하면 저장된 파일 경로를 반환합니다.
  Future<String?> trimAudio({
    required String sourcePath,
    required Duration start,
    required Duration end,
    required String title,
  }) async {
    final dir = await _clipsDir;
    final ext = p.extension(sourcePath).toLowerCase();
    final sanitized = title
        .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
        .trim()
        .replaceAll(RegExp(r'_+'), '_');
    final destPath = p.join(dir.path, '$sanitized$ext');

    final startSec = (start.inMilliseconds / 1000.0).toStringAsFixed(3);
    final durSec = ((end - start).inMilliseconds / 1000.0).toStringAsFixed(3);

    final cmd =
        '-ss $startSec -i "$sourcePath" -t $durSec -c copy -avoid_negative_ts make_zero "$destPath" -y';

    if (!kIsWeb && Platform.isWindows) {
      return null; // FFmpeg not supported on Windows
    }

    final session = await FFmpegKit.execute(cmd);
    final rc = await session.getReturnCode();
    if (ReturnCode.isSuccess(rc)) return destPath;

    // copy codec failed → re-encode (slower but safe)
    final encCmd =
        '-ss $startSec -i "$sourcePath" -t $durSec -avoid_negative_ts make_zero "$destPath" -y';
    final encSession = await FFmpegKit.execute(encCmd);
    final encRc = await encSession.getReturnCode();
    return ReturnCode.isSuccess(encRc) ? destPath : null;
  }

  /// 클립에 해당하는 스크립트 줄을 추출해 .txt로 저장합니다.
  Future<String?> saveClipScript({
    required String clipAudioPath,
    required List<SyncItem> syncItems,
    required Duration start,
    required Duration end,
  }) async {
    final lines = syncItems
        .where((s) => s.endTime > start && s.startTime < end)
        .map((s) => s.sentence)
        .join('\n');
    if (lines.isEmpty) return null;

    final scriptPath = '${p.withoutExtension(clipAudioPath)}.txt';
    await File(scriptPath).writeAsString(lines);
    return scriptPath;
  }

  /// 클립 오디오 + 스크립트를 zip으로 묶어 임시 디렉터리에 저장 후 경로를 반환합니다.
  Future<String?> exportClipAsZip(StudyItem clip) async {
    final encoder = ZipFileEncoder();
    final tmp = await getTemporaryDirectory();
    final zipPath = p.join(tmp.path, '${clip.title}.zip');
    encoder.create(zipPath);
    encoder.addFile(File(clip.audioPath));
    if (clip.scriptPath != null && File(clip.scriptPath!).existsSync()) {
      encoder.addFile(File(clip.scriptPath!));
    }
    encoder.close();
    return zipPath;
  }

  /// Extract real waveform data from audio file using ffmpeg.
  /// Returns list of 0.0–1.0 amplitude values (default 120 samples).
  Future<List<double>> extractWaveform(String audioPath, {int samples = 120}) async {
    if (!kIsWeb && Platform.isWindows) {
      return _fallbackWaveform(audioPath, samples);
    }
    try {
      final cmd =
          '-i "$audioPath" -af "asetnsamples=$samples,astats=metadata=1:reset=1" -f null -';
      final session = await FFmpegKit.execute(cmd);
      final output = await session.getAllLogsAsString() ?? '';

      final rmsValues = <double>[];
      final rmsRegex = RegExp(r'lavfi\.astats\.Overall\.RMS_level=(-?\d+\.?\d*)');
      for (final match in rmsRegex.allMatches(output)) {
        final db = double.tryParse(match.group(1) ?? '') ?? -60.0;
        // Convert dB to 0-1 range (typical range: -60 to 0 dB)
        final normalized = ((db + 60) / 60).clamp(0.0, 1.0);
        rmsValues.add(normalized);
      }

      if (rmsValues.length >= 10) return rmsValues;
      return _fallbackWaveform(audioPath, samples);
    } catch (_) {
      return _fallbackWaveform(audioPath, samples);
    }
  }

  List<double> _fallbackWaveform(String seed, int count) {
    final rng = math.Random(seed.hashCode);
    return List.generate(count, (i) {
      final base = 0.15 + rng.nextDouble() * 0.7;
      final envelope = math.sin(i / count * math.pi);
      return (base * (0.4 + 0.6 * envelope)).clamp(0.05, 1.0);
    });
  }

  /// Auto-split audio into multiple clips based on silence detection.
  /// Returns list of StudyItems saved to the clips directory.
  Future<List<StudyItem>> autoSplitAndSave({
    required String sourcePath,
    required String baseTitle,
    Duration minSilence = const Duration(milliseconds: 500),
    double silenceThresholdDb = -35.0,
  }) async {
    final segments = await detectSpeechSegments(
      sourcePath,
      minSilence: minSilence,
    );
    if (segments.isEmpty) return [];

    final results = <StudyItem>[];
    int index = 1;

    for (final (start, end) in segments) {
      final duration = end - start;
      if (duration < const Duration(seconds: 2)) continue; // skip too-short segments

      final title = '$baseTitle - $index';
      final audioPath = await trimAudio(
        sourcePath: sourcePath,
        start: start,
        end: end,
        title: title,
      );
      if (audioPath != null) {
        results.add(StudyItem(title: title, audioPath: audioPath, source: StudyItemSource.local));
        index++;
      }
    }
    return results;
  }

  /// 무음 구간을 검출해 말하는 구간의 (start, end) 목록을 반환합니다.
  Future<List<(Duration, Duration)>> detectSpeechSegments(
    String sourcePath, {
    Duration minSilence = const Duration(milliseconds: 500),
    Duration totalDuration = Duration.zero,
  }) async {
    if (!kIsWeb && Platform.isWindows) return [];
    final noiseDb = -40;
    final minSilenceSec =
        (minSilence.inMilliseconds / 1000.0).toStringAsFixed(2);
    final cmd =
        '-i "$sourcePath" -af "silencedetect=noise=${noiseDb}dB:d=$minSilenceSec" -f null -';
    final session = await FFmpegKit.execute(cmd);
    final logs = await session.getAllLogsAsString() ?? '';

    final silenceStarts = RegExp(r'silence_start:\s*([\d.]+)')
        .allMatches(logs)
        .map((m) => Duration(milliseconds: (double.parse(m.group(1)!) * 1000).round()))
        .toList();
    final silenceEnds = RegExp(r'silence_end:\s*([\d.]+)')
        .allMatches(logs)
        .map((m) => Duration(milliseconds: (double.parse(m.group(1)!) * 1000).round()))
        .toList();

    if (silenceStarts.isEmpty) {
      return totalDuration > Duration.zero
          ? [(Duration.zero, totalDuration)]
          : [];
    }

    final segments = <(Duration, Duration)>[];
    Duration cursor = Duration.zero;

    final count = math.min(silenceStarts.length, silenceEnds.length);
    for (int i = 0; i < count; i++) {
      if (silenceStarts[i] > cursor) {
        segments.add((cursor, silenceStarts[i]));
      }
      cursor = silenceEnds[i];
    }
    if (totalDuration > cursor) {
      segments.add((cursor, totalDuration));
    }
    return segments;
  }
}
