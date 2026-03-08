import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Marketplace content pack model
class ContentPack {
  final String id;
  final String title;
  final String description;
  final String creator;
  final int price; // KRW
  final int itemCount;
  final String language;
  final double rating;
  final int reviewCount;
  final bool isPurchased;

  const ContentPack({
    required this.id,
    required this.title,
    required this.description,
    required this.creator,
    required this.price,
    required this.itemCount,
    required this.language,
    this.rating = 0,
    this.reviewCount = 0,
    this.isPurchased = false,
  });
}

// Marketplace provider (stub - to be connected to backend)
final marketplacePacksProvider = FutureProvider<List<ContentPack>>((ref) async {
  // Stub data - will be replaced with real API when marketplace launches
  await Future.delayed(const Duration(milliseconds: 300));
  return [
    const ContentPack(
      id: 'pack_001',
      title: '원어민 일본어 드라마 대사 100선',
      description: '인기 일드 명장면 100개 문장 + SRS 덱 포함',
      creator: 'LingoNexus 공식',
      price: 9900,
      itemCount: 100,
      language: 'Japanese',
      rating: 4.8,
      reviewCount: 42,
    ),
    const ContentPack(
      id: 'pack_002',
      title: '영어 TED 강연 핵심 표현 50선',
      description: '최신 TED 강연에서 뽑은 고급 표현 + 발음 가이드',
      creator: 'LingoNexus 공식',
      price: 7900,
      itemCount: 50,
      language: 'English',
      rating: 4.6,
      reviewCount: 28,
    ),
  ];
});

/// 콘텐츠 마켓플레이스 화면 (현재 미노출 - 추후 런칭 예정)
class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final packsAsync = ref.watch(marketplacePacksProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('콘텐츠 마켓플레이스'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00FFD1), Color(0xFF0080FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('큐레이션 학습팩', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('전문가가 선별한 프리미엄 학습 콘텐츠',
                  style: TextStyle(color: Colors.black.withValues(alpha: 0.7), fontSize: 14)),
              ],
            ),
          ),

          // Pack list
          Expanded(
            child: packsAsync.when(
              data: (packs) => ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: packs.length,
                itemBuilder: (ctx, i) {
                  final pack = packs[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(pack.title,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '₩${pack.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(pack.description,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${pack.rating} (${pack.reviewCount})',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              const SizedBox(width: 12),
                              Text('${pack.itemCount}개 콘텐츠',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              const Spacer(),
                              Text(pack.creator,
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00FFD1),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _showPurchaseDialog(context, pack),
                              child: Text(pack.isPurchased ? '다운로드' : '구매하기',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, ContentPack pack) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(pack.title),
        content: const Text('마켓플레이스 결제 시스템이 준비 중입니다.\n런칭 시 알림을 받으시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('닫기')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('런칭 알림 신청이 완료되었습니다!')));
            },
            child: const Text('알림 신청'),
          ),
        ],
      ),
    );
  }
}
