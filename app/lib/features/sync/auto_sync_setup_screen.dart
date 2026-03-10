import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../../core/models/language_option.dart';
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
  bool _isSyncing = false;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    // 현재 선택된 아이템의 언어 코드로 기본값 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final item = ref.read(currentStudyItemProvider);
      if (item?.language != null) {
        final code = item!.language!;
        final valid = _syncLanguages.any((l) => l.code == code);
        if (valid) setState(() => _selectedLanguageCode = code);
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
    final item = ref.read(currentStudyItemProvider);
    if (item == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.playerSelectFileFirst)),
        );
      }
      return;
    }

    setState(() => _isSyncing = true);
    _loadingController.repeat();

    try {
      final engine = ref.read(audioEngineProvider);
      final duration = engine.player.duration ?? const Duration(minutes: 30);

      final syncService = ref.read(autoSyncServiceProvider);
      final result = await syncService.transcribe(
        item.audioPath,
        _selectedLanguageCode,
        duration,
      );

      // 스크립트 파일이 없으면 전사 결과를 저장
      if (item.scriptPath == null && result.script.isNotEmpty) {
        final scriptFile = File(
          item.audioPath.replaceAll(RegExp(r'\.(mp3|m4a|wav)$', caseSensitive: false), '.txt'),
        );
        await scriptFile.writeAsString(result.script);
      }

      ref.read(currentSyncItemsProvider.notifier).state = result.syncItems;
      item.syncItems = result.syncItems;
      await ref.read(progressServiceProvider).saveSyncItems(item.audioPath, result.syncItems);

      if (mounted) {
        setState(() => _isSyncing = false);
        _loadingController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${result.syncItems.length}개 문장 싱크 완료!')),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.syncDescription,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // 언어 선택 드롭다운
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguageCode,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: theme.colorScheme.primary),
                    dropdownColor: theme.colorScheme.surfaceContainerHighest,
                    items: _syncLanguages.map((lang) {
                      return DropdownMenuItem<String>(
                        value: lang.code,
                        child: Text('${lang.emoji}  ${lang.name}',
                            style: theme.textTheme.titleMedium),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedLanguageCode = newValue);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // 싱크 중 / 시작 버튼
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
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.2),
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
                      '${selectedLang.emoji}  ${selectedLang.name} ${l10n.aiSyncDescription}',
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
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.1),
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

              const Spacer(),

              // 크레딧 섹션
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.surfaceContainerHighest,
                      theme.colorScheme.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Credit Balance: 0',
                            style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.3)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Column(
                              children: [
                                Text('12 Credits',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                Text('\$1.00',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                        color: theme
                                            .colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.15),
                              foregroundColor: theme.colorScheme.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Column(
                              children: [
                                Text('150 Credits',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                Text('\$10.00',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                        color: theme.colorScheme.primary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          l10n.useOwnApiKey,
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.underline),
                        ),
                      ),
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
