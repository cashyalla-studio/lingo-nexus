import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../credits/credits_screen.dart';
import '../legal/terms_screen.dart';
import '../legal/privacy_screen.dart';
import '../scanner/scanner_provider.dart';

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
        SnackBar(content: Text(AppLocalizations.of(context)!.settingsCacheDeleteSuccess)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authAsync = ref.watch(authUserProvider);
    final user = authAsync.valueOrNull;

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

                // ── Account Section ───────────────────────────────────────
                _SectionTitle(title: l10n.settingsSectionAccount, theme: theme),
                const SizedBox(height: 12),
                authAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (user) => user != null
                      ? _AccountTile(user: user, theme: theme)
                      : InkWell(
                          onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const LoginScreen())),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.person_add_outlined, color: AppTheme.accentPrimary),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.settingsLogin,
                                        style: theme.textTheme.bodyLarge),
                                      Text(l10n.settingsLoginSubtitle,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 32),

                // ── Credits / Subscription ────────────────────────────────
                _SectionTitle(title: l10n.settingsSectionCredits, theme: theme),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.bolt_outlined,
                  title: l10n.creditsTitle,
                  subtitle: l10n.settingsCreditsSubtitle,
                  theme: theme,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CreditsScreen())),
                ),
                const SizedBox(height: 32),

                // ── Language Section ──────────────────────────────────────
                _SectionTitle(title: l10n.settingsSectionLanguage, theme: theme),
                const SizedBox(height: 12),
                _LanguageTile(theme: theme),
                const SizedBox(height: 32),

                // ── Data Section ──────────────────────────────────────────
                _SectionTitle(title: l10n.settingsSectionData, theme: theme),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.folder_open_outlined,
                  title: l10n.settingsRescanLibrary,
                  subtitle: l10n.settingsRescanSubtitle,
                  theme: theme,
                  onTap: () => ref.read(studyItemsProvider.notifier).pickAndScanDirectory(),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.delete_outline,
                  title: l10n.settingsResetData,
                  subtitle: l10n.settingsResetSubtitle,
                  theme: theme,
                  isDestructive: true,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) {
                        final dl10n = AppLocalizations.of(ctx)!;
                        return AlertDialog(
                          title: Text(dl10n.settingsResetDialogTitle),
                          content: Text(dl10n.settingsResetDialogContent),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(dl10n.cancel)),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(dl10n.delete, style: const TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmed == true) {
                      final storage = ref.read(secureStorageProvider);
                      await storage.clearAllKeys();
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.settingsResetSuccess)));
                      }
                    }
                  },
                ),
                const SizedBox(height: 32),

                // ── Cache Section ─────────────────────────────────────────
                _SectionTitle(title: l10n.settingsSectionCache, theme: theme),
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
                          Flexible(child: Row(children: [
                            Icon(Icons.folder_zip_outlined, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Flexible(child: Text(l10n.settingsCacheDriveDownload,
                                style: theme.textTheme.bodyLarge)),
                          ])),
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
                                child: Icon(Icons.close, size: 16, color: AppTheme.danger),
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
                    title: l10n.settingsClearAllCache,
                    subtitle: l10n.settingsClearCacheSubtitle,
                    theme: theme,
                    isDestructive: true,
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) {
                          final dl10n = AppLocalizations.of(ctx)!;
                          return AlertDialog(
                            title: Text(dl10n.settingsCacheDeleteDialogTitle),
                            content: Text(dl10n.settingsCacheDeleteDialogContent(
                                CacheService.formatBytes(_cacheSizeBytes!))),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(dl10n.cancel)),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(dl10n.delete,
                                      style: const TextStyle(color: Colors.red))),
                            ],
                          );
                        },
                      );
                      if (confirmed == true) await _clearAllCache();
                    },
                  ),
                const SizedBox(height: 32),

                // ── Legal ─────────────────────────────────────────────────
                _SectionTitle(title: l10n.settingsSectionLegal, theme: theme),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: l10n.termsTitle,
                  subtitle: l10n.settingsTermsSubtitle,
                  theme: theme,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TermsScreen())),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.privacyTitle,
                  subtitle: l10n.settingsPrivacySubtitle,
                  theme: theme,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PrivacyScreen())),
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

class _AccountTile extends ConsumerWidget {
  final AuthUser user;
  final ThemeData theme;
  const _AccountTile({required this.user, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.accentPrimary.withValues(alpha: 0.2),
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl) : null,
                child: user.avatarUrl.isEmpty
                    ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(color: AppTheme.accentPrimary, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(user.email, style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) {
                    final dl10n = AppLocalizations.of(ctx)!;
                    return AlertDialog(
                      title: Text(dl10n.settingsLogoutDialogTitle),
                      content: Text(dl10n.settingsLogoutDialogContent),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false),
                          child: Text(dl10n.cancel)),
                        TextButton(onPressed: () => Navigator.pop(ctx, true),
                          child: Text(dl10n.settingsLogout,
                            style: const TextStyle(color: Colors.red))),
                      ],
                    );
                  },
                );
                if (confirmed == true) {
                  await ref.read(authUserProvider.notifier).signOut();
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: Text(l10n.settingsLogout),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
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

class _LanguageTile extends ConsumerWidget {
  final ThemeData theme;
  const _LanguageTile({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocale = ref.watch(localeProvider);
    final selectedInfo = selectedLocale == null
        ? null
        : supportedAppLocales.where((e) =>
            e.locale.languageCode == selectedLocale.languageCode &&
            (e.locale.countryCode == selectedLocale.countryCode ||
             (e.locale.countryCode == null && selectedLocale.countryCode == null))).firstOrNull;
    final l10n = AppLocalizations.of(context)!;
    final displayName = selectedInfo?.nativeName ?? l10n.settingsSystemDefault;

    return InkWell(
      onTap: () => _showPicker(context, ref, selectedLocale),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.language, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.settingsAppLanguage, style: theme.textTheme.bodyLarge),
                  Text(displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref, Locale? current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LocalePickerSheet(current: current),
    );
  }
}

class _LocalePickerSheet extends ConsumerWidget {
  final Locale? current;
  const _LocalePickerSheet({required this.current});

  bool _isSelected(Locale a, Locale b) =>
      a.languageCode == b.languageCode && a.countryCode == b.countryCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(l10n.settingsAppLanguageTitle,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            _LocaleOption(
              locale: null,
              name: l10n.settingsSystemDefault,
              nativeName: l10n.settingsSystemDefaultSubtitle,
              isSelected: current == null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(null);
                Navigator.pop(context);
              },
              theme: theme,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: supportedAppLocales.map((info) => _LocaleOption(
                  locale: info.locale,
                  name: info.name,
                  nativeName: info.nativeName,
                  isSelected: current != null && _isSelected(current!, info.locale),
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(info.locale);
                    Navigator.pop(context);
                  },
                  theme: theme,
                )).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _LocaleOption extends StatelessWidget {
  final Locale? locale;
  final String name;
  final String nativeName;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _LocaleOption({
    required this.locale, required this.name, required this.nativeName,
    required this.isSelected, required this.onTap, required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nativeName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : null,
                    )),
                  Text(name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 22),
          ],
        ),
      ),
    );
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
