import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/models/study_item.dart';

class SampleContentService {
  static List<Map<String, dynamic>> get sampleMetadata => [
    {
      'title': '[샘플] 영어 - Hello World',
      'language': 'en',
      'script':
          'Hello, world! This is a sample sentence for English practice.\n'
          'How are you today? I am doing very well, thank you!\n'
          'The quick brown fox jumps over the lazy dog.',
    },
    {
      'title': '[샘플] 中文 - 你好世界',
      'language': 'zh',
      'script':
          '你好，世界！这是一段普通话练习示例。\n'
          '今天天气怎么样？今天天气很好。\n'
          '我喜欢学习中文。',
    },
    {
      'title': '[샘플] 日本語 - こんにちは',
      'language': 'ja',
      'script':
          'こんにちは、世界！これは日本語練習のサンプルです。\n'
          '今日のお天気はいかがですか？とても良い天気ですね。\n'
          '日本語を勉強するのが好きです。',
    },
  ];

  /// Create sample StudyItems with script files but no audio.
  /// Users can use TTS or add audio later via auto-sync / recording.
  Future<List<StudyItem>> createSampleItems() async {
    final dir = await getApplicationDocumentsDirectory();
    final samplesDir = Directory(p.join(dir.path, 'samples'));
    await samplesDir.create(recursive: true);

    final items = <StudyItem>[];
    for (final meta in sampleMetadata) {
      final title = meta['title'] as String;
      final language = meta['language'] as String;
      final script = meta['script'] as String;

      final scriptPath = p.join(samplesDir.path, '${title.hashCode}.txt');
      await File(scriptPath).writeAsString(script);

      // audioPath is empty — script-only demo item
      items.add(StudyItem(
        title: title,
        audioPath: '',
        scriptPath: scriptPath,
        language: language,
        source: StudyItemSource.local,
      ));
    }
    return items;
  }
}
