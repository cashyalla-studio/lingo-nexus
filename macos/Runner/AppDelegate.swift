import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // Finder / 다른 앱에서 "Scripta Sync으로 열기" 했을 때 호출됩니다.
  override func application(_ sender: NSApplication, open urls: [URL]) {
    guard let url = urls.first, url.isFileURL else { return }

    let fm = FileManager.default
    guard let docsURL = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      return
    }
    let destDir = docsURL.appendingPathComponent("opened_files")
    try? fm.createDirectory(at: destDir, withIntermediateDirectories: true)

    let destURL = destDir.appendingPathComponent(url.lastPathComponent)
    try? fm.removeItem(at: destURL)

    do {
      _ = url.startAccessingSecurityScopedResource()
      try fm.copyItem(at: url, to: destURL)
      url.stopAccessingSecurityScopedResource()
    } catch {
      return
    }

    // Flutter SharedPreferences = NSUserDefaults 공유 스위트
    UserDefaults.standard.set(destURL.path, forKey: "scripta_pending_open_file")
    UserDefaults.standard.synchronize()
  }
}
