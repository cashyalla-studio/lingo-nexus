import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    let channel = FlutterMethodChannel(
      name: "com.scriptasync/storage",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {

      // iCloud 컨테이너 Documents 경로 반환
      case "getICloudContainerURL":
        let fm = FileManager.default
        guard let containerURL = fm.url(forUbiquityContainerIdentifier: "iCloud.xyz.cashyalla.scrypta.sync") else {
          result(nil)
          return
        }
        let docsURL = containerURL.appendingPathComponent("Documents")
        try? fm.createDirectory(at: docsURL, withIntermediateDirectories: true)
        result(docsURL.path)

      // 디렉터리에 대한 보안 북마크 생성 (앱 재시작 후에도 접근 유지)
      case "createBookmark":
        guard let args = call.arguments as? [String: Any],
              let pathStr = args["path"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "path required", details: nil))
          return
        }
        let url = URL(fileURLWithPath: pathStr)
        do {
          let data = try url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
          )
          result(data.base64EncodedString())
        } catch {
          result(FlutterError(code: "BOOKMARK_FAILED", message: error.localizedDescription, details: nil))
        }

      // 저장된 북마크에서 경로 복원 + 접근 시작
      case "resolveBookmark":
        guard let args = call.arguments as? [String: Any],
              let base64 = args["bookmark"] as? String,
              let data = Data(base64Encoded: base64) else {
          result(FlutterError(code: "INVALID_ARGS", message: "bookmark required", details: nil))
          return
        }
        do {
          var isStale = false
          let url = try URL(
            resolvingBookmarkData: data,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
          )
          let accessed = url.startAccessingSecurityScopedResource()
          if accessed {
            result(url.path)
          } else {
            result(FlutterError(code: "ACCESS_DENIED", message: "Cannot access security scoped resource", details: nil))
          }
        } catch {
          result(FlutterError(code: "RESOLVE_FAILED", message: error.localizedDescription, details: nil))
        }

      // 접근 해제 (사용 완료 후 호출)
      case "stopAccessingBookmark":
        guard let args = call.arguments as? [String: Any],
              let pathStr = args["path"] as? String else {
          result(nil)
          return
        }
        let url = URL(fileURLWithPath: pathStr)
        url.stopAccessingSecurityScopedResource()
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }
}
