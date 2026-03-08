import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/subscription_service.dart';

final subscriptionServiceProvider = Provider((ref) => SubscriptionService());

final subscriptionTierProvider = FutureProvider<SubscriptionTier>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getCurrentTier();
});

final aiCallsUsedProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getAiCallsUsed();
});

final canUseAIProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.canUseAI();
});
