/// Go 서버 URL 설정.
/// 빌드 시 --dart-define=SERVER_URL=https://your-server.com 으로 오버라이드 가능.
class ServerConfig {
  static const String baseUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: 'http://localhost:8080',
  );
}
