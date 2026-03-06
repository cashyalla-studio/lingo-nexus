import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../core/models/study_item.dart';

class DirectoryScannerService {
  /// 사용자가 직접 파일들을 선택하여 라이브러리에 추가합니다. (Android Scoped Storage 호환)
  Future<({List<StudyItem> items, String? selectedPath})> scanDirectory() async {
    // 폴더 선택 대신 파일 다중 선택으로 변경하여 권한 문제를 우회합니다.
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'txt', 'srt'],
    );

    if (result == null || result.files.isEmpty) {
      return (items: <StudyItem>[], selectedPath: null);
    }

    final audioFiles = <PlatformFile>[];
    final textFiles = <PlatformFile>[];

    for (final file in result.files) {
      if (file.path == null) continue;
      final ext = file.extension?.toLowerCase() ?? '';
      if (ext == 'mp3' || ext == 'm4a' || ext == 'wav') {
        audioFiles.add(file);
      } else if (ext == 'txt' || ext == 'srt') {
        textFiles.add(file);
      }
    }

    final studyItems = <StudyItem>[];
    for (final audio in audioFiles) {
      final baseName = path.basenameWithoutExtension(audio.name);
      PlatformFile? matchingText;
      for (final txt in textFiles) {
        if (path.basenameWithoutExtension(txt.name) == baseName) {
          matchingText = txt;
          break;
        }
      }
      studyItems.add(StudyItem(
        title: baseName,
        audioPath: audio.path!,
        scriptPath: matchingText?.path,
        source: StudyItemSource.local,
      ));
    }

    // 파일들의 공통 상위 디렉터리를 selectedPath로 간주
    String? commonDir;
    if (audioFiles.isNotEmpty && audioFiles.first.path != null) {
      commonDir = path.dirname(audioFiles.first.path!);
    }

    return (items: studyItems, selectedPath: commonDir);
  }

  /// 지정된 경로를 스캔하여 StudyItem 목록을 반환합니다.
  /// iCloud 경로, 북마크 복원 경로, 자동 재스캔 등에서 재사용됩니다.
  Future<List<StudyItem>> scanFromPath(
    String directoryPath, {
    StudyItemSource source = StudyItemSource.local,
  }) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return [];

    final entities = dir.listSync(recursive: false);

    final audioFiles = <File>[];
    final textFiles = <File>[];

    for (final entity in entities) {
      if (entity is File) {
        final ext = path.extension(entity.path).toLowerCase();
        if (ext == '.mp3' || ext == '.m4a' || ext == '.wav') {
          audioFiles.add(entity);
        } else if (ext == '.txt' || ext == '.srt') {
          textFiles.add(entity);
        }
      }
    }

    final studyItems = <StudyItem>[];
    for (final audio in audioFiles) {
      final baseName = path.basenameWithoutExtension(audio.path);
      File? matchingText;
      for (final txt in textFiles) {
        if (path.basenameWithoutExtension(txt.path) == baseName) {
          matchingText = txt;
          break;
        }
      }
      studyItems.add(StudyItem(
        title: baseName,
        audioPath: audio.path,
        scriptPath: matchingText?.path,
        source: source,
      ));
    }

    return studyItems;
  }
}
