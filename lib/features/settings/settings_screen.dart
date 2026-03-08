import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../../core/providers/ai_provider.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../scanner/scanner_provider.dart';
import 'api_key_settings_sheet.dart';
import '../subscription/subscription_screen.dart';
import '../subscription/subscription_provider.dart';
import '../../core/services/subscription_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int? _cacheSizeBytes;
  List<CacheEntry> _cacheEntries = [];
  bool _loadingCache = false;

  @override
  void initState() {
    super.initState();
    _loadCacheInfo();
  }

  Future<void> _loadCacheInfo() async {
    setState(() => _loadingCache = true);
    final service = ref.read(cacheServiceProvider);
    final size = await service.getTotalCacheSize();
    final entries = await service.getDriveCacheEntries();
    if (mounted) {
      setState(() {
        _cacheSizeBytes = size;
        _cacheEntries = entries;
        _loadingCache = false;
      });
    }
  }

  Future<void> _clearAllCache() async {
    final service = ref.read(cacheServiceProvider);
    await service.clearAllDriveCache();
    await service.clearOpenedFiles();
    await _loadCacheInfo();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('캐시가 삭제되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final activeAi = ref.watch(activeAiProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settings,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                // AI Provider Section
                _SectionTitle(title: 'AI 프로바이더', theme: theme),
                const SizedBox(height: 12),
                ...AiProviderType.values.map((type) {
                  final name = switch (type) {
                    AiProviderType.google => 'Google Gemini',
                    AiProviderType.openai => 'OpenAI GPT',
                    AiProviderType.claude => 'Claude (Anthropic)',
                  };
                  final icon = switch (type) {
                    AiProviderType.google => Icons.auto_awesome,
                    AiProviderType.openai => Icons.psychology,
                    AiProviderType.claude => Icons.memory,
                  };
                  final isSelected = activeAi == type;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => ref.read(activeAiProvider.notifier).switchProvider(type),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 16),
                            Expanded(child: Text(name, style: theme.textTheme.bodyLarge)),
                            if (isSelected) Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => const ApiKeySettingsSheet(),
                    ),
                    icon: const Icon(Icons.key_outlined),
                    label: const Text('API 키 관리'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _SectionTitle(title: '구독', theme: theme),
                const SizedBox(height: 12),
                Consumer(
                  builder: (ctx, ref, _) {
                    final tierAsync = ref.watch(subscriptionTierProvider);
                    return tierAsync.when(
                      data: (tier) => _SettingsTile(
                        icon: tier == SubscriptionTier.pro ? Icons.workspace_premium : Icons.person_outline,
                        title: tier == SubscriptionTier.pro ? 'Pro 플랜 구독 중' : 'Free 플랜 사용 중',
                        subtitle: tier == SubscriptionTier.pro
                            ? '모든 기능 무제한 사용 가능'
                            : 'AI 월 20회, 발음 연습 월 10회',
                        theme: theme,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Data Section
                _SectionTitle(title: '데이터', theme: theme),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.folder_open_outlined,
                  title: '라이브러리 다시 스캔',
                  subtitle: '디렉터리에서 새 파일을 검색합니다',
                  theme: theme,
                  onTap: () => ref.read(studyItemsProvider.notifier).pickAndScanDirectory(),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.delete_outline,
                  title: '학습 기록 초기화',
                  subtitle: '모든 진도 및 기록을 삭제합니다',
                  theme: theme,
                  isDestructive: true,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('기록 초기화'),
                        content: const Text('모든 학습 기록 및 진도가 삭제됩니다. 계속하시겠습니까?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('삭제', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      // Clear API keys
                      final storage = ref.read(secureStorageProvider);
                      await storage.clearAllKeys();
                      // Clear all SharedPreferences data (progress, speed, shadow deck, pronunciation history)
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('모든 기록이 초기화되었습니다.')));
                      }
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Cache Section
                _SectionTitle(title: '캐시 관리', theme: theme),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Icon(Icons.folder_zip_outlined, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Text('Google Drive 다운로드',
                                style: theme.textTheme.bodyLarge),
                          ]),
                          _loadingCache
                              ? const SizedBox(width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(
                                  _cacheSizeBytes != null
                                      ? CacheService.formatBytes(_cacheSizeBytes!)
                                      : '-',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.primary),
                                ),
                        ],
                      ),
                      if (_cacheEntries.isNotEmpty) ...[
                        const Divider(height: 20),
                        ..._cacheEntries.map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const SizedBox(width: 36),
                              Expanded(
                                child: Text(entry.folderName,
                                    style: theme.textTheme.labelMedium,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text(entry.sizeLabel,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant)),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  await ref.read(cacheServiceProvider)
                                      .clearDriveEntry(entry.folderName);
                                  await _loadCacheInfo();
                                },
                                child: Icon(Icons.close, size: 16,
                                    color: AppTheme.danger),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (_cacheSizeBytes != null && _cacheSizeBytes! > 0)
                  _SettingsTile(
                    icon: Icons.cleaning_services_outlined,
                    title: '캐시 전체 삭제',
                    subtitle: '다운로드된 Google Drive 파일 및 임시 파일 삭제',
                    theme: theme,
                    isDestructive: true,
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('캐시 삭제'),
                          content: Text(
                              '${CacheService.formatBytes(_cacheSizeBytes!)}의 캐시가 삭제됩니다.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('취소')),
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('삭제',
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirmed == true) await _clearAllCache();
                    },
                  ),
                const SizedBox(height: 32),

                // App info
                Center(
                  child: Text('Scripta Sync v1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;
  const _SectionTitle({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(title,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeData theme;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon, required this.title, required this.subtitle,
    required this.theme, required this.onTap, this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDestructive ? Colors.red : null)),
                  Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
