import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingo_nexus/core/providers/locale_provider.dart';
import '../../helpers/test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocaleNotifier', () {
    test("initial state is null when no saved preference", () async {
      final container = makeContainer();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(localeProvider), isNull);
    });

    test("loads saved locale ko", () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'ko'});
      final container = makeContainer();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(localeProvider), const Locale('ko'));
    });

    test("loads saved locale zh_CN", () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'zh_CN'});
      final container = makeContainer();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(localeProvider), const Locale('zh', 'CN'));
    });

    test("loads saved locale en_US", () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en_US'});
      final container = makeContainer();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(localeProvider), const Locale('en', 'US'));
    });

    test("setLocale persists languageCode to SharedPreferences", () async {
      final container = makeContainer();
      await container.read(localeProvider.notifier).setLocale(const Locale('ja'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'ja');
    });

    test("setLocale persists languageCode_countryCode to SharedPreferences", () async {
      final container = makeContainer();
      await container.read(localeProvider.notifier).setLocale(const Locale('zh', 'TW'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'zh_TW');
    });

    test("setLocale null removes preference", () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'ko'});
      final container = makeContainer();
      await container.read(localeProvider.notifier).setLocale(null);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), isNull);
    });

    test("setLocale updates provider state immediately", () async {
      final container = makeContainer();
      await container.read(localeProvider.notifier).setLocale(const Locale('de'));
      expect(container.read(localeProvider), const Locale('de'));
    });

    test("setLocale null sets state to null", () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'ko'});
      final container = makeContainer();
      await Future<void>.delayed(Duration.zero);
      await container.read(localeProvider.notifier).setLocale(null);
      expect(container.read(localeProvider), isNull);
    });
  });
}
