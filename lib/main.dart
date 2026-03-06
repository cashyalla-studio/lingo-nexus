import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/services/file_open_service.dart';
import 'features/intro/intro_screen.dart';
import 'features/scanner/scanner_provider.dart';

void main() {
  runApp(const ProviderScope(child: ScriptaSyncApp()));
}

class ScriptaSyncApp extends StatelessWidget {
  const ScriptaSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scripta Sync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('ja'),
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('en', 'US'),
        Locale('en', 'GB'),
        Locale('en', 'AU'),
        Locale('de'),
        Locale('es'),
        Locale('pt'),
        Locale('ar'),
        Locale('he'),
        Locale('fr', 'FR'),
        Locale('fr', 'CA'),
      ],
      home: const _AppInit(),
    );
  }
}

/// 앱 시작 시 라이브러리 복원 + 파일 열기 감지
class _AppInit extends ConsumerStatefulWidget {
  const _AppInit();

  @override
  ConsumerState<_AppInit> createState() => _AppInitState();
}

class _AppInitState extends ConsumerState<_AppInit> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(studyItemsProvider.notifier).initLibrary();
      await _checkPendingFile();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 포그라운드 복귀 시 보류 파일 재확인
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPendingFile();
  }

  Future<void> _checkPendingFile() async {
    final fileOpenService = FileOpenService();
    final path = await fileOpenService.consumePendingFile();
    if (path != null && mounted) {
      await ref.read(studyItemsProvider.notifier).addSingleFile(path);
    }
  }

  @override
  Widget build(BuildContext context) => const IntroScreen();
}
