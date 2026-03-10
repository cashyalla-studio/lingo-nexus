import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

/// 앱에서 지원하는 언어 목록 (languageCode, countryCode, 표시 이름)
const List<({Locale locale, String name, String nativeName})> supportedAppLocales = [
  (locale: Locale('ko'), name: '한국어', nativeName: '한국어'),
  (locale: Locale('en', 'US'), name: 'English (US)', nativeName: 'English'),
  (locale: Locale('en', 'GB'), name: 'English (UK)', nativeName: 'English (UK)'),
  (locale: Locale('ja'), name: '일본어', nativeName: '日本語'),
  (locale: Locale('zh', 'CN'), name: '중국어 간체', nativeName: '中文(简体)'),
  (locale: Locale('zh', 'TW'), name: '중국어 번체', nativeName: '中文(繁體)'),
  (locale: Locale('de'), name: '독일어', nativeName: 'Deutsch'),
  (locale: Locale('es'), name: '스페인어', nativeName: 'Español'),
  (locale: Locale('pt'), name: '포르투갈어', nativeName: 'Português'),
  (locale: Locale('fr', 'FR'), name: '프랑스어', nativeName: 'Français'),
  (locale: Locale('ar'), name: '아랍어', nativeName: 'العربية'),
  (locale: Locale('he'), name: '히브리어', nativeName: 'עברית'),
];

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLocaleKey);
    if (saved != null) {
      final parts = saved.split('_');
      state = parts.length == 2
          ? Locale(parts[0], parts[1])
          : Locale(parts[0]);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_kLocaleKey);
    } else {
      final key = locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      await prefs.setString(_kLocaleKey, key);
    }
    state = locale;
  }
}
