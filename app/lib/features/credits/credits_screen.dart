import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../../core/config/server_config.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/theme/app_theme.dart';

// Credit status provider
final creditStatusProvider = FutureProvider<_CreditStatus>((ref) async {
  final token = await ref.read(secureStorageProvider).getAccessToken();
  if (token == null) return const _CreditStatus();

  final resp = await http.get(
    Uri.parse('${ServerConfig.baseUrl}/api/v1/credits'),
    headers: {'Authorization': 'Bearer $token'},
  ).timeout(const Duration(seconds: 10));

  if (resp.statusCode != 200) return const _CreditStatus();

  final json = jsonDecode(resp.body) as Map<String, dynamic>;
  return _CreditStatus(
    balanceMinutes: json['balance_minutes'] as int? ?? 0,
    dailyFreeUsed: json['daily_free_used'] as int? ?? 0,
    dailyFreeTotal: json['daily_free_total'] as int? ?? 180,
    hasSubscription: json['has_subscription'] as bool? ?? false,
    plan: json['subscription_plan'] as String?,
    expiresAt: json['expires_at'] as String?,
  );
});

class _CreditStatus {
  final int balanceMinutes;
  final int dailyFreeUsed;
  final int dailyFreeTotal;
  final bool hasSubscription;
  final String? plan;
  final String? expiresAt;
  const _CreditStatus({
    this.balanceMinutes = 0,
    this.dailyFreeUsed = 0,
    this.dailyFreeTotal = 180,
    this.hasSubscription = false,
    this.plan,
    this.expiresAt,
  });
}

class CreditsScreen extends ConsumerWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statusAsync = ref.watch(creditStatusProvider);
    final user = ref.watch(authUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.creditsTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(creditStatusProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account info
              if (user != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.accentPrimary.withValues(alpha: 0.2),
                        backgroundImage: user.avatarUrl.isNotEmpty
                            ? NetworkImage(user.avatarUrl)
                            : null,
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
                            Text(user.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text(user.email, style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Credit balance
              statusAsync.when(
                data: (status) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily free quota card
                    _StatusCard(
                      gradient: [const Color(0xFF0080FF), const Color(0xFF00FFD1)],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.wb_sunny, color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.creditsDailyFree,
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ]),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${(status.dailyFreeTotal - status.dailyFreeUsed) ~/ 60}',
                                style: const TextStyle(color: Colors.white, fontSize: 36,
                                  fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(l10n.creditsMinRemaining,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 1 - (status.dailyFreeUsed / status.dailyFreeTotal).clamp(0, 1),
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(l10n.creditsDailyResets,
                            style: const TextStyle(color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Credit balance card
                    _StatusCard(
                      gradient: [const Color(0xFF1a1a2e), const Color(0xFF16213e)],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.bolt, color: Color(0xFF00FFD1), size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.creditsPurchasedCredits,
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ]),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${status.balanceMinutes}',
                                style: const TextStyle(color: Color(0xFF00FFD1), fontSize: 36,
                                  fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(l10n.creditsMinutes,
                                  style: const TextStyle(color: Colors.white54, fontSize: 14)),
                              ),
                            ],
                          ),
                          if (status.hasSubscription && status.plan != null)
                            Text(
                              '${_planName(status.plan!, l10n)} ${l10n.creditsSubscriptionActive}',
                              style: const TextStyle(color: Color(0xFF00FFD1), fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(l10n.creditsLoadError),
              ),

              const SizedBox(height: 32),

              // Plans section
              Text(l10n.creditsSubscriptionsTitle,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _PlanCard(
                name: 'Basic',
                price: '₩5,900',
                period: l10n.creditsPerMonth,
                minutes: 300,
                theme: theme,
                isHighlighted: false,
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              _PlanCard(
                name: 'Pro',
                price: '₩11,900',
                period: l10n.creditsPerMonth,
                minutes: 1000,
                theme: theme,
                isHighlighted: true,
                badge: l10n.creditsMostPopular,
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              _PlanCard(
                name: 'Premium',
                price: '₩22,900',
                period: l10n.creditsPerMonth,
                minutes: 3000,
                theme: theme,
                isHighlighted: false,
                onTap: () => _showComingSoon(context),
              ),

              const SizedBox(height: 32),

              // Credit packs section
              Text(l10n.creditPacksTitle,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.creditPacksSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),

              _CreditPackCard(minutes: 10, price: '₩1,500', theme: theme, onTap: () => _showComingSoon(context)),
              const SizedBox(height: 8),
              _CreditPackCard(minutes: 130, price: '₩15,000',
                bonus: '+30%', theme: theme, onTap: () => _showComingSoon(context)),
              const SizedBox(height: 8),
              _CreditPackCard(minutes: 1500, price: '₩150,000',
                bonus: '+50%', theme: theme, onTap: () => _showComingSoon(context)),

              const SizedBox(height: 24),
              Center(
                child: Text(l10n.creditsPaymentComingSoon,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _planName(String plan, AppLocalizations l10n) {
    return switch (plan) {
      'basic' => 'Basic',
      'pro' => 'Pro',
      'premium' => 'Premium',
      _ => plan,
    };
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.creditsPaymentComingSoon)),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final List<Color> gradient;
  final Widget child;
  const _StatusCard({required this.gradient, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final int minutes;
  final ThemeData theme;
  final bool isHighlighted;
  final String? badge;
  final VoidCallback onTap;

  const _PlanCard({
    required this.name, required this.price, required this.period,
    required this.minutes, required this.theme, required this.isHighlighted,
    required this.onTap, this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppTheme.accentPrimary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted ? AppTheme.accentPrimary.withValues(alpha: 0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(badge!, style: const TextStyle(color: Colors.black, fontSize: 10,
                          fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text('$minutes min / month',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: isHighlighted ? AppTheme.accentPrimary : null)),
                Text(period, style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditPackCard extends StatelessWidget {
  final int minutes;
  final String price;
  final String? bonus;
  final ThemeData theme;
  final VoidCallback onTap;

  const _CreditPackCard({
    required this.minutes, required this.price, required this.theme,
    required this.onTap, this.bonus,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.bolt, color: Color(0xFF00FFD1), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text('$minutes min',
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            ),
            if (bonus != null)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFD1).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(bonus!,
                  style: const TextStyle(color: Color(0xFF00FFD1), fontSize: 11,
                    fontWeight: FontWeight.bold)),
              ),
            Text(price, style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
