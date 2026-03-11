import Flutter
import Speech
import Foundation

/// MethodChannel: xyz.cashyalla.scrypta.sync/stt
/// Methods:
///   isAvailable(languageCode: String) → Bool
///   transcribeFile(filePath: String, languageCode: String) → String (JSON)
///     JSON: {"text": "...", "segments": [{"word": "...", "start_sec": 0.1, "end_sec": 0.5}, ...]}
class NativeSttPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "xyz.cashyalla.scrypta.sync/stt",
      binaryMessenger: registrar.messenger()
    )
    let instance = NativeSttPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAvailable":
      guard let args = call.arguments as? [String: Any],
            let langCode = args["languageCode"] as? String else {
        result(false)
        return
      }
      isAvailable(languageCode: langCode, result: result)

    case "transcribeFile":
      guard let args = call.arguments as? [String: Any],
            let filePath = args["filePath"] as? String,
            let langCode = args["languageCode"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "filePath and languageCode required", details: nil))
        return
      }
      transcribeFile(filePath: filePath, languageCode: langCode, result: result)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - isAvailable

  private func isAvailable(languageCode: String, result: @escaping FlutterResult) {
    let locale = sttLocale(for: languageCode)
    let recognizer = SFSpeechRecognizer(locale: locale)
    let available = recognizer?.isAvailable ?? false
    result(available)
  }

  // MARK: - transcribeFile

  private func transcribeFile(filePath: String, languageCode: String, result: @escaping FlutterResult) {
    let authStatus = SFSpeechRecognizer.authorizationStatus()

    switch authStatus {
    case .authorized:
      doTranscribe(filePath: filePath, languageCode: languageCode, result: result)
    case .notDetermined:
      SFSpeechRecognizer.requestAuthorization { status in
        DispatchQueue.main.async {
          if status == .authorized {
            self.doTranscribe(filePath: filePath, languageCode: languageCode, result: result)
          } else {
            result(FlutterError(code: "PERMISSION_DENIED", message: "Speech recognition permission denied", details: nil))
          }
        }
      }
    default:
      result(FlutterError(code: "PERMISSION_DENIED", message: "Speech recognition not authorized", details: nil))
    }
  }

  private func doTranscribe(filePath: String, languageCode: String, result: @escaping FlutterResult) {
    let locale = sttLocale(for: languageCode)
    guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
      result(FlutterError(code: "NOT_AVAILABLE", message: "Speech recognizer not available for \(languageCode)", details: nil))
      return
    }

    let audioURL = URL(fileURLWithPath: filePath)
    let request = SFSpeechURLRecognitionRequest(url: audioURL)
    request.shouldReportPartialResults = false
    request.taskHint = .dictation

    recognizer.recognitionTask(with: request) { recognitionResult, error in
      if let error = error {
        result(FlutterError(code: "RECOGNITION_ERROR", message: error.localizedDescription, details: nil))
        return
      }
      guard let recognitionResult = recognitionResult, recognitionResult.isFinal else { return }

      let transcription = recognitionResult.bestTranscription
      let segments: [[String: Any]] = transcription.segments.map { seg in
        [
          "word": seg.substring,
          "start_sec": seg.timestamp,
          "end_sec": seg.timestamp + seg.duration,
        ]
      }

      let payload: [String: Any] = [
        "text": transcription.formattedString,
        "segments": segments,
      ]

      do {
        let jsonData = try JSONSerialization.data(withJSONObject: payload)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
        result(jsonString)
      } catch {
        result(FlutterError(code: "JSON_ERROR", message: error.localizedDescription, details: nil))
      }
    }
  }

  // MARK: - Locale mapping

  private func sttLocale(for languageCode: String) -> Locale {
    let localeMap: [String: String] = [
      "zh": "zh-CN",
      "zh-CN": "zh-CN",
      "zh-TW": "zh-TW",
      "zh-HK": "zh-HK",
      "ja": "ja-JP",
      "en": "en-US",
      "ko": "ko-KR",
      "es": "es-ES",
      "de": "de-DE",
      "fr": "fr-FR",
      "pt": "pt-BR",
      "ar": "ar-SA",
      "he": "he-IL",
    ]
    let identifier = localeMap[languageCode] ?? languageCode
    return Locale(identifier: identifier)
  }
}
