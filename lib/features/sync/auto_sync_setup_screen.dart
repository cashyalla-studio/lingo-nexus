import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../player/player_provider.dart';
import '../player/audio_engine.dart';
import 'auto_sync_service.dart';

class AutoSyncSetupScreen extends ConsumerStatefulWidget {
  const AutoSyncSetupScreen({super.key});

  @override
  ConsumerState<AutoSyncSetupScreen> createState() => _AutoSyncSetupScreenState();
}

class _AutoSyncSetupScreenState extends ConsumerState<AutoSyncSetupScreen> with SingleTickerProviderStateMixin {
  String _selectedLanguage = 'English';
  bool _isSyncing = false;
  late AnimationController _loadingController;

  final List<String> _languages = ['English', 'Chinese', 'Japanese', 'Korean', 'Spanish', 'French'];

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _startSync(AppLocalizations l10n) async {
    if (_isSyncing) return;
    final item = ref.read(currentStudyItemProvider);
    if (item == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 라이브러리에서 파일을 선택하세요.')),
      );
      return;
    }

    // Check if script is available
    if (item.scriptPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('대본 파일(.txt)이 없습니다. 같은 이름의 txt 파일을 추가하세요.')),
      );
      return;
    }

    setState(() { _isSyncing = true; });
    _loadingController.repeat();

    try {
      // Read the script file
      final scriptFile = File(item.scriptPath!);
      final scriptText = await scriptFile.readAsString();

      // Get audio duration (use the player's duration, or estimate)
      final engine = ref.read(audioEngineProvider);
      final duration = engine.player.duration ?? const Duration(minutes: 30);

      // Call the real sync service
      final syncService = ref.read(autoSyncServiceProvider);
      final syncItems = await syncService.generateSync(item.audioPath, scriptText, duration);

      // Store sync items in player provider
      ref.read(currentSyncItemsProvider.notifier).state = syncItems;

      // Also persist on the StudyItem
      item.syncItems = syncItems;

      if (mounted) {
        setState(() { _isSyncing = false; });
        _loadingController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${syncItems.length}개 문장 싱크 완료!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isSyncing = false; });
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.aiAutoSync, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),

              // Language Selector (Neo-glass style)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.primary),
                    dropdownColor: theme.colorScheme.surfaceContainerHighest,
                    items: _languages.map((String lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(lang, style: theme.textTheme.titleMedium),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedLanguage = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Syncing State / Button
              if (_isSyncing)
                Column(
                  children: [
                    AnimatedBuilder(
                      animation: _loadingController,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _loadingController.value * 2 * math.pi,
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.aiSyncDescription, // Use a generic "syncing" string if available, reusing here
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _isSyncing ? null : () => _startSync(l10n),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    foregroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diamond_outlined, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n.startAutoSync, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

              const Spacer(),

              // Credits Section (Premium Upsell)
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
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text("Credit Balance: 0", style: theme.textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Column(
                              children: [
                                Text("12 Credits", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                Text("\$1.00", style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Column(
                              children: [
                                Text("150 Credits", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                Text("\$10.00", style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
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
                        child: Text(l10n.useOwnApiKey, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, decoration: TextDecoration.underline)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
