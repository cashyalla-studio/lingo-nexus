import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../../core/models/language_option.dart';
import '../../core/providers/locale_provider.dart';
import '../player/player_provider.dart';
import '../player/audio_engine.dart';
import '../scanner/scanner_provider.dart';
import 'auto_sync_service.dart';

/// `other`는 전사 언어를 특정할 수 없으므로 제외
final _syncLanguages = kStudyLanguages.where((l) => l.code != 'other').toList();

class AutoSyncSetupScreen extends ConsumerStatefulWidget {
  const AutoSyncSetupScreen({super.key});

  @override
  ConsumerState<AutoSyncSetupScreen> createState() => _AutoSyncSetupScreenState();
}

class _AutoSyncSetupScreenState extends ConsumerState<AutoSyncSetupScreen>
    with SingleTickerProviderStateMixin {
  String _selectedLanguageCode = 'en';
  String _targetLanguageCode = 'ko';
  bool _isSyncing = false;
  String _syncStatus = '';
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 오디오 언어 기본값: 현재 아이템 언어
      final item = ref.read(currentStudyItemProvider);
      if (item?.language != null) {
        final code = item!.language!;
        if (_syncLanguages.any((l) => l.code == code)) {
          setState(() => _selectedLanguageCode = code);
        }
      }
      // 번역 언어 기본값: 앱 UI 언어
      final appLocale = ref.read(localeProvider);
      if (appLocale != null) {
        final code = appLocale.languageCode;
        if (_syncLanguages.any((l) => l.code == code)) {
          setState(() => _targetLanguageCode = code);
        }
      }
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _startSync() async {
    if (_isSyncing) return;
    final l10n = AppLocalizations.of(context)!;
    final item = ref.read(currentStudyItemProvider);
    if (item == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.playerSelectFileFirst)),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncStatus = l10n.aiSyncDescription;
    });
    _loadingController.repeat();

    try {
      final engine = ref.read(audioEngineProvider);
      final duration = engine.player.duration ?? const Duration(minutes: 30);

      final syncService = ref.read(autoSyncServiceProvider);

      // Step 1: 전사 + 어노테이션
      final result = await syncService.transcribe(
        item.audioPath,
        _selectedLanguageCode,
        duration,
        targetLanguage: _targetLanguageCode,
      );

      if (!mounted) return;

      // Step 2: 스크립트 파일 저장 (발음기호 + 번역 포함)
      final scriptPath = item.audioPath.replaceAll(
        RegExp(r'\.(mp3|m4a|wav)$', caseSensitive: false),
        '.txt',
      );
      final scriptFile = File(scriptPath);
      final scriptContent = syncService.generateAnnotatedScript(result.syncItems);
      await scriptFile.writeAsString(scriptContent);

      ref.read(currentSyncItemsProvider.notifier).state = result.syncItems;
      item.syncItems = result.syncItems;
      await ref.read(progressServiceProvider).saveSyncItems(item.audioPath, result.syncItems);

      if (mounted) {
        setState(() => _isSyncing = false);
        _loadingController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.syncScriptSaved(result.syncItems.length)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSyncing = false);
        _loadingController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('싱크 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final selectedLang = _syncLanguages.firstWhere(
      (l) => l.code == _selectedLanguageCode,
      orElse: () => _syncLanguages.first,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.aiAutoSync,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 잡음 경고 카드 ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.amber, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.syncNoiseWarning,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade200,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.syncDescription,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              // ── 오디오 언어 선택 ──────────────────────────────────────────
              _LanguageDropdown(
                label: l10n.syncAudioLanguage,
                value: _selectedLanguageCode,
                languages: _syncLanguages,
                onChanged: (v) => setState(() => _selectedLanguageCode = v),
              ),
              const SizedBox(height: 16),

              // ── 번역 언어 선택 ────────────────────────────────────────────
              _LanguageDropdown(
                label: l10n.syncTranslationLanguage,
                value: _targetLanguageCode,
                languages: _syncLanguages,
                onChanged: (v) => setState(() => _targetLanguageCode = v),
              ),
              const SizedBox(height: 40),

              // ── 싱크 중 / 시작 버튼 ───────────────────────────────────────
              if (_isSyncing)
                Column(
                  children: [
                    AnimatedBuilder(
                      animation: _loadingController,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _loadingController.value * 2 * math.pi,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  width: 4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary),
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '${selectedLang.emoji}  ${selectedLang.name} $_syncStatus',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _startSync,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        l10n.startAutoSync,
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<({String code, String name, String emoji})> languages;
  final ValueChanged<String> onChanged;

  const _LanguageDropdown({
    required this.label,
    required this.value,
    required this.languages,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.primary),
              dropdownColor: theme.colorScheme.surfaceContainerHighest,
              items: languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang.code,
                  child: Text('${lang.emoji}  ${lang.name}',
                      style: theme.textTheme.titleMedium),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
