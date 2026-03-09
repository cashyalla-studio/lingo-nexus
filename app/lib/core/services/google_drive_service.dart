import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Google Drive에서 표시·다운로드하는 파일/폴더 단위
class DriveItem {
  final String id;
  final String name;
  final String mimeType;
  final int? size; // bytes

  const DriveItem({
    required this.id,
    required this.name,
    required this.mimeType,
    this.size,
  });

  bool get isFolder => mimeType == 'application/vnd.google-apps.folder';

  bool get isAudio {
    final lower = name.toLowerCase();
    return mimeType.startsWith('audio/') ||
        lower.endsWith('.mp3') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.wav');
  }

  bool get isScript {
    return mimeType == 'text/plain' || name.toLowerCase().endsWith('.txt');
  }

  String get sizeLabel {
    if (size == null) return '';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(0)} KB';
    return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory DriveItem.fromJson(Map<String, dynamic> json) {
    return DriveItem(
      id: json['id'] as String,
      name: json['name'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] != null ? int.tryParse(json['size'].toString()) : null,
    );
  }
}

/// Google Drive 연동 서비스.
/// 로그인, 폴더 탐색, 파일 다운로드를 담당합니다.
class GoogleDriveService {
  static const _driveScope = 'https://www.googleapis.com/auth/drive.readonly';
  static const _filesEndpoint = 'https://www.googleapis.com/drive/v3/files';

  final _signIn = GoogleSignIn(scopes: [_driveScope]);

  bool get isSignedIn => _signIn.currentUser != null;
  GoogleSignInAccount? get currentUser => _signIn.currentUser;

  /// 구글 로그인 후 액세스 토큰 반환
  Future<String?> signIn() async {
    try {
      GoogleSignInAccount? account = await _signIn.signInSilently();
      account ??= await _signIn.signIn();
      if (account == null) return null;
      final auth = await account.authentication;
      return auth.accessToken;
    } catch (e) {
      debugPrint('GoogleDriveService.signIn error: $e');
      return null;
    }
  }

  Future<void> signOut() => _signIn.signOut();

  /// 현재 세션의 액세스 토큰 반환 (재로그인 없이)
  Future<String?> getAccessToken() async {
    try {
      final account = _signIn.currentUser ?? await _signIn.signInSilently();
      if (account == null) return null;
      final auth = await account.authentication;
      return auth.accessToken;
    } catch (_) {
      return null;
    }
  }

  /// 폴더 내 파일/서브폴더 목록 반환
  /// [folderId] = 'root' 이면 내 드라이브 루트
  Future<List<DriveItem>> listFolder(String folderId, String accessToken) async {
    final query = Uri.encodeQueryComponent("'$folderId' in parents and trashed=false");
    final uri = Uri.parse(
      '$_filesEndpoint?q=$query&fields=files(id,name,mimeType,size)&pageSize=200&orderBy=name',
    );
    final res = await http.get(uri, headers: {'Authorization': 'Bearer $accessToken'});

    if (res.statusCode != 200) throw Exception('Drive API error: ${res.body}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final files = (data['files'] as List<dynamic>? ?? []);
    return files
        .map((f) => DriveItem.fromJson(f as Map<String, dynamic>))
        .where((item) => item.isFolder || item.isAudio || item.isScript)
        .toList();
  }

  /// 파일 다운로드 (진행률 콜백 포함)
  Future<File> downloadFile(
    DriveItem item,
    String destDir,
    String accessToken, {
    void Function(double progress)? onProgress,
  }) async {
    final uri = Uri.parse('$_filesEndpoint/${item.id}?alt=media');
    final destFile = File(p.join(destDir, item.name));

    final req = http.Request('GET', uri)
      ..headers['Authorization'] = 'Bearer $accessToken';
    final streamedRes = await req.send();

    if (streamedRes.statusCode != 200) {
      throw Exception('Download failed (${streamedRes.statusCode}): ${item.name}');
    }

    final total = streamedRes.contentLength ?? item.size ?? 0;
    int received = 0;
    final sink = destFile.openWrite();

    await for (final chunk in streamedRes.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (total > 0) onProgress?.call(received / total);
    }
    await sink.close();
    return destFile;
  }

  /// 폴더 내 오디오+스크립트 파일을 모두 다운로드하고 로컬 경로 쌍을 반환.
  /// [folderName]은 로컬 캐시 하위 폴더명으로 사용됩니다.
  Future<List<({String audioPath, String? scriptPath, String title})>> importFolder({
    required String folderId,
    required String folderName,
    required String accessToken,
    void Function(String fileName, double progress)? onProgress,
  }) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final destDir = Directory(p.join(docsDir.path, 'google_drive_imports', folderName));
    await destDir.create(recursive: true);

    final items = await listFolder(folderId, accessToken);
    final audioItems = items.where((f) => !f.isFolder && f.isAudio).toList();
    final scriptItems = items.where((f) => !f.isFolder && f.isScript).toList();

    final results = <({String audioPath, String? scriptPath, String title})>[];

    for (final audio in audioItems) {
      final audioFile = await downloadFile(audio, destDir.path, accessToken,
          onProgress: (p) => onProgress?.call(audio.name, p));

      final baseName = p.basenameWithoutExtension(audio.name);
      File? scriptFile;
      final matching = scriptItems.where(
        (s) => p.basenameWithoutExtension(s.name) == baseName,
      );
      if (matching.isNotEmpty) {
        scriptFile = await downloadFile(matching.first, destDir.path, accessToken,
            onProgress: (p) => onProgress?.call(matching.first.name, p));
      }

      results.add((
        audioPath: audioFile.path,
        scriptPath: scriptFile?.path,
        title: baseName,
      ));
    }

    return results;
  }
}
