import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../core/models/study_item.dart';

class DirectoryScannerService {
  /// 사용자가 직접 폴더를 선택하여 스캔합니다.
  /// 선택된 경로를 반환하여 호출부에서 영속화할 수 있도록 합니다.
  Future<({List<StudyItem> items, String? selectedPath})> scanDirectory() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return (items: <StudyItem>[], selectedPath: null);

    final items = await scanFromPath(selectedDirectory);
    return (items: items, selectedPath: selectedDirectory);
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
