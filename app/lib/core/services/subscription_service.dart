import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionTier { free, pro }

/// 구독 상태 및 Free 티어 AI 사용량 제한을 관리합니다.
class SubscriptionService {
  static const String _keyTier = 'subscription_tier';
  static const String _keyAiCallsUsed = 'ai_calls_used';
  static const String _keyAiCallsMonth = 'ai_calls_month';
  static const int freeAiCallsPerMonth = 20;
  static const int freeShadowingPerMonth = 10;
  static const String _keyShadowingUsed = 'shadowing_used';

  Future<SubscriptionTier> getCurrentTier() async {
    final prefs = await SharedPreferences.getInstance();
    final tierStr = prefs.getString(_keyTier) ?? 'free';
    return tierStr == 'pro' ? SubscriptionTier.pro : SubscriptionTier.free;
  }

  Future<void> setTier(SubscriptionTier tier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTier, tier.name);
  }

  Future<int> getAiCallsUsed() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMonth = prefs.getString(_keyAiCallsMonth) ?? '';
    final currentMonth = _monthKey();
    if (savedMonth != currentMonth) {
      await prefs.setInt(_keyAiCallsUsed, 0);
      await prefs.setString(_keyAiCallsMonth, currentMonth);
      return 0;
    }
    return prefs.getInt(_keyAiCallsUsed) ?? 0;
  }

  Future<bool> canUseAI() async {
    final tier = await getCurrentTier();
    if (tier == SubscriptionTier.pro) return true;
    final used = await getAiCallsUsed();
    return used < freeAiCallsPerMonth;
  }

  Future<void> recordAiCall() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = _monthKey();
    await prefs.setString(_keyAiCallsMonth, currentMonth);
    final used = prefs.getInt(_keyAiCallsUsed) ?? 0;
    await prefs.setInt(_keyAiCallsUsed, used + 1);
  }

  Future<int> getShadowingUsed() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMonth = prefs.getString('${_keyShadowingUsed}_month') ?? '';
    final currentMonth = _monthKey();
    if (savedMonth != currentMonth) {
      await prefs.setInt(_keyShadowingUsed, 0);
      await prefs.setString('${_keyShadowingUsed}_month', currentMonth);
      return 0;
    }
    return prefs.getInt(_keyShadowingUsed) ?? 0;
  }

  Future<bool> canUseShadowing() async {
    final tier = await getCurrentTier();
    if (tier == SubscriptionTier.pro) return true;
    final used = await getShadowingUsed();
    return used < freeShadowingPerMonth;
  }

  Future<void> recordShadowing() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = _monthKey();
    await prefs.setString('${_keyShadowingUsed}_month', currentMonth);
    final used = prefs.getInt(_keyShadowingUsed) ?? 0;
    await prefs.setInt(_keyShadowingUsed, used + 1);
  }

  String _monthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}';
  }
}
