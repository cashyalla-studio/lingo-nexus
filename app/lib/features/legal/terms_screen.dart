import 'package:flutter/material.dart';
import 'package:lingo_nexus/generated/l10n/app_localizations.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.termsTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.termsTitle,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.termsLastUpdated,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            ..._sections(l10n).map((s) => _Section(title: s.$1, body: s.$2, theme: theme)),
          ],
        ),
      ),
    );
  }

  List<(String, String)> _sections(AppLocalizations l10n) => [
    (l10n.termsSec1Title, l10n.termsSec1Body),
    (l10n.termsSec2Title, l10n.termsSec2Body),
    (l10n.termsSec3Title, l10n.termsSec3Body),
    (l10n.termsSec4Title, l10n.termsSec4Body),
    (l10n.termsSec5Title, l10n.termsSec5Body),
    (l10n.termsSec6Title, l10n.termsSec6Body),
  ];
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  final ThemeData theme;
  const _Section({required this.title, required this.body, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            )),
        ],
      ),
    );
  }
}
