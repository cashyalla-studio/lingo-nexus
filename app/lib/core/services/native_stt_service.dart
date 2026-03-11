import 'package:flutter/services.dart';

/// 기기 내장 STT를 통해 오디오 파일을 텍스트로 변환합니다.
///
/// iOS: SFSpeechRecognizer (SFSpeechURLRecognitionRequest)
/// Android: 지원 안 함 → isAvailable() == false → 서버 API로 폴백
class NativeSttService {
  static const _channel = MethodChannel('xyz.cashyalla.scrypta.sync/stt');

  /// 해당 언어에 대해 기기 내장 STT 사용 가능 여부를 반환합니다.
  Future<bool> isAvailable(String languageCode) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isAvailable',
        {'languageCode': languageCode},
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// 오디오 파일을 기기 내장 STT로 텍스트 변환합니다.
  ///
  /// 반환값: 전사된 텍스트 (단일 문자열, 타임스탬프 없음)
  /// 실패 시 [PlatformException] 발생 → 호출자가 처리해야 함
  Future<String> transcribeFile(String filePath, String languageCode) async {
    final result = await _channel.invokeMethod<String>(
      'transcribeFile',
      {'filePath': filePath, 'languageCode': languageCode},
    );
    return result ?? '';
  }
}
