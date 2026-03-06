import 'dart:io';
import 'package:flutter/services.dart';

/// macOS Swift 메서드 채널을 통해 iCloud 컨테이너 및 보안 북마크를 관리합니다.
class ICloudService {
  static const _channel = MethodChannel('com.scriptasync/storage');

  /// iCloud 컨테이너의 Documents 디렉터리를 반환합니다.
  /// iCloud 미사용 환경에서는 null을 반환합니다.
  Future<Directory?> getContainerDirectory() async {
    try {
      final path = await _channel.invokeMethod<String>('getICloudContainerURL');
      if (path == null) return null;
      return Directory(path);
    } on PlatformException {
      return null;
    }
  }

  Future<bool> get isAvailable async {
    final dir = await getContainerDirectory();
    return dir != null;
  }

  /// 지정된 경로에 대한 보안 북마크를 생성합니다 (macOS sandbox 전용).
  /// 앱 재시작 후에도 해당 경로에 접근할 수 있도록 합니다.
  Future<String?> createBookmark(String path) async {
    try {
      return await _channel.invokeMethod<String>('createBookmark', {'path': path});
    } on PlatformException {
      return null;
    }
  }

  /// 저장된 북마크 데이터로부터 경로를 복원하고 접근을 시작합니다.
  /// 반환된 경로로 파일에 접근한 후 반드시 [stopAccessing]을 호출해야 합니다.
  Future<String?> resolveBookmark(String bookmarkBase64) async {
    try {
      return await _channel.invokeMethod<String>('resolveBookmark', {'bookmark': bookmarkBase64});
    } on PlatformException {
      return null;
    }
  }

  /// 보안 접근을 해제합니다. resolveBookmark 사용 후 반드시 호출.
  Future<void> stopAccessing(String path) async {
    try {
      await _channel.invokeMethod('stopAccessingBookmark', {'path': path});
    } on PlatformException {
      // ignore
    }
  }
}
