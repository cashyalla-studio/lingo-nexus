import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // 다른 앱 / Files 앱에서 "Scripta Sync으로 열기" 했을 때 호출됩니다.
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    guard url.isFileURL else { return false }

    // 앱 샌드박스 Documents 안으로 복사
    let fm = FileManager.default
    guard let docsURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
      return false
    }
    let destDir = docsURL.appendingPathComponent("opened_files")
    try? fm.createDirectory(at: destDir, withIntermediateDirectories: true)

    let destURL = destDir.appendingPathComponent(url.lastPathComponent)
    try? fm.removeItem(at: destURL)

    do {
      // security-scoped resource 접근
      _ = url.startAccessingSecurityScopedResource()
      try fm.copyItem(at: url, to: destURL)
      url.stopAccessingSecurityScopedResource()
    } catch {
      return false
    }

    // Flutter (SharedPreferences = NSUserDefaults)가 읽을 수 있도록 저장
    UserDefaults.standard.set(destURL.path, forKey: "scripta_pending_open_file")
    UserDefaults.standard.synchronize()
    return true
  }
}
