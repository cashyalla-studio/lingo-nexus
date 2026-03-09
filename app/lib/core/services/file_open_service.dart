import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// iOS/macOS에서 "다음으로 열기(Open With)"로 Scripta Sync가 실행될 때
/// 전달된 파일 경로를 수신합니다.
///
/// 네이티브(AppDelegate)는 파일 경로를 UserDefaults에 기록하고,
/// 이 서비스가 앱 초기화 시 또는 포그라운드 복귀 시 해당 값을 읽습니다.
class FileOpenService {
  static const _key = 'scripta_pending_open_file';
  static const _channel = MethodChannel('com.scriptasync/storage');

  /// UserDefaults에 저장된 보류 파일 경로를 읽고 즉시 삭제합니다.
  /// 없으면 null 반환.
  Future<String?> consumePendingFile() async {
    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences는 Apple 플랫폼에서 NSUserDefaults를 사용하므로
    // 네이티브에서 쓴 키를 여기서 바로 읽을 수 있습니다.
    final path = prefs.getString(_key);
    if (path != null) await prefs.remove(_key);
    return path;
  }

  /// 앱 내에서 직접 파일 경로를 등록할 때 사용 (테스트/내부 용도)
  Future<void> setPendingFile(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, path);
  }
}
