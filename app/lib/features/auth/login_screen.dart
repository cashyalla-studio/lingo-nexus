import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../legal/terms_screen.dart';
import '../legal/privacy_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authUserProvider.notifier).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        setState(() { _error = e.toString().replaceFirst('Exception: ', ''); });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo / App Icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00FFD1), Color(0xFF0080FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.headphones, color: Colors.black, size: 48),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.appTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const Spacer(flex: 2),

              // AI 서비스 하이라이트
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _FeatureRow(icon: Icons.auto_awesome, label: l10n.loginFeatureAi, theme: theme),
                    const SizedBox(height: 12),
                    _FeatureRow(icon: Icons.mic, label: l10n.loginFeaturePronunciation, theme: theme),
                    const SizedBox(height: 12),
                    _FeatureRow(icon: Icons.sync, label: l10n.loginFeatureSync, theme: theme),
                    const SizedBox(height: 12),
                    _FeatureRow(icon: Icons.card_giftcard, label: l10n.loginFeatureFree, theme: theme),
                  ],
                ),
              ),

              const Spacer(),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.danger),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _signInWithGoogle,
                  icon: _loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const _GoogleLogo(),
                  label: Text(l10n.loginWithGoogle,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Legal links
              Text.rich(
                TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(text: l10n.loginLegalPrefix),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const TermsScreen())),
                        child: Text(l10n.loginTermsLink,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.accentPrimary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.accentPrimary,
                          )),
                      ),
                    ),
                    TextSpan(text: ' ${l10n.loginLegalAnd} '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PrivacyScreen())),
                        child: Text(l10n.loginPrivacyLink,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.accentPrimary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.accentPrimary,
                          )),
                      ),
                    ),
                    TextSpan(text: l10n.loginLegalSuffix),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;
  const _FeatureRow({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppTheme.accentPrimary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.accentPrimary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22, height: 22,
      child: _GoogleLogoSvg(),
    );
  }
}

class _GoogleLogoSvg extends StatelessWidget {
  const _GoogleLogoSvg();

  @override
  Widget build(BuildContext context) {
    // Simple colored G icon as a substitute for the Google logo SVG
    return Container(
      width: 22, height: 22,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: const Icon(Icons.g_mobiledata, color: Color(0xFF4285F4), size: 22),
    );
  }
}
