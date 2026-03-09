import 'dart:io';
import 'dart:math';
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

  /// 무음 구간을 검출해 말하는 구간의 (start, end) 목록을 반환합니다.
  Future<List<(Duration, Duration)>> detectSpeechSegments(
    String sourcePath, {
    Duration minSilence = const Duration(milliseconds: 500),
    Duration totalDuration = Duration.zero,
  }) async {
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

    final count = min(silenceStarts.length, silenceEnds.length);
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
