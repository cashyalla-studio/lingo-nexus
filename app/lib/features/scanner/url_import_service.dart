import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/config/server_config.dart';

class UrlImportService {
  /// Ask the server to fetch and process the given URL.
  /// Returns metadata (title, audioUrl, fileId) on success, null on failure.
  Future<({String title, String audioUrl, String fileId})?> importFromUrl(
      String url) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ServerConfig.baseUrl}/api/v1/content/import'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'url': url}),
          )
          .timeout(const Duration(minutes: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (
          title: data['title'] as String,
          audioUrl: '${ServerConfig.baseUrl}${data['audio_url']}',
          fileId: data['file_id'] as String,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Download the audio file from the server URL to local storage.
  /// Returns the local file path on success, null on failure.
  Future<String?> downloadToLocal(String audioUrl, String title) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ext = audioUrl.toLowerCase().endsWith('.mp3') ? 'mp3' : 'm4a';
      final safeName =
          title.replaceAll(RegExp(r'[^\w\s]'), '_').replaceAll(RegExp(r'\s+'), '_');
      final fileName = '${safeName}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final importsDir = Directory(p.join(dir.path, 'imports'));
      await importsDir.create(recursive: true);
      final localPath = p.join(importsDir.path, fileName);

      final response = await http
          .get(Uri.parse(audioUrl))
          .timeout(const Duration(minutes: 5));
      if (response.statusCode == 200) {
        await File(localPath).writeAsBytes(response.bodyBytes);
        return localPath;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
