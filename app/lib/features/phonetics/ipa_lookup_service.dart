import 'ipa_data.dart';

/// IPA 발음기호 조회 및 발음 카테고리 관리 서비스
class IpaLookupService {
  /// 단어의 IPA 발음기호를 반환합니다. 없으면 null.
  String? getIpa(String word) => IpaData.lookup(word);

  /// 카테고리 목록 반환
  List<String> getCategories() => IpaData.categories.keys.toList();

  /// 카테고리별 단어 목록 반환
  List<String> getWordsForCategory(String category) =>
      IpaData.categories[category] ?? [];

  /// 단어와 IPA가 함께 있는 항목만 반환
  List<({String word, String ipa})> getWordsWithIpa(String category) {
    return getWordsForCategory(category)
        .map((w) => (word: w, ipa: IpaData.lookup(w) ?? ''))
        .where((e) => e.ipa.isNotEmpty)
        .toList();
  }
}
