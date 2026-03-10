// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Scripta Sync';

  @override
  String get welcomeBack => 'おかえりなさい！';

  @override
  String get readyToMaster => '今日も新しい言語をマスターする準備はできていますか？';

  @override
  String get continueStudying => '学習を続ける';

  @override
  String get myRecentActivity => '最近の活動';

  @override
  String get seeAll => 'すべて見る';

  @override
  String get home => 'ホーム';

  @override
  String get library => 'ライブラリ';

  @override
  String get stats => '統計';

  @override
  String get settings => '設定';

  @override
  String get getStarted => '始める';

  @override
  String get importContent => 'コンテンツをインポート';

  @override
  String get aiSyncAnalyze => 'AI同期と分析';

  @override
  String get immersiveStudy => '没入型学習';

  @override
  String get importDescription => 'デバイスからオーディオファイルとテキストスクリプトを簡単にインポートできます。';

  @override
  String get aiSyncDescription => 'AIが文章を分析し、オーディオと完全に同期させます。';

  @override
  String get immersiveDescription => '集中できるプレイヤーで語学力を向上させましょう。';

  @override
  String get selectedSentence => '選択された文';

  @override
  String get aiGrammarAnalysis => 'AI文法分析';

  @override
  String get vocabularyHelper => 'ボキャブラリーヘルパー';

  @override
  String get shadowingStudio => 'シャドーイングスタジオ';

  @override
  String get aiAutoSync => 'AIオート同期';

  @override
  String get syncDescription => 'Scripta Sync AIを使用して、テキストとオーディオを簡単に整列させます。';

  @override
  String get startAutoSync => 'オート同期を開始 (1クレジット)';

  @override
  String get buyCredits => 'クレジットを購入';

  @override
  String get useOwnApiKey => 'または自身のAPIキーを使用 (BYOK)';

  @override
  String get shadowingNativeSpeaker => 'ネイティブスピーカー';

  @override
  String get shadowingYourTurn => 'あなたの番';

  @override
  String get listening => '聴取中...';

  @override
  String get accuracy => '正確さ';

  @override
  String get intonation => 'イントネーション';

  @override
  String get fluency => '流暢さ';

  @override
  String get syncCompleted => 'オート同期完了！';

  @override
  String get noContentFound => 'コンテンツが見つかりません。フォルダアイコンをタップしてインポートしてください。';

  @override
  String get selectFile => 'ファイルを選択してください';

  @override
  String get noScriptFile => 'スクリプトファイルが見つかりません。';

  @override
  String get noScriptHint => '音声と同じ名前の .txt ファイルを同じフォルダに追加してください。';

  @override
  String get settingsSectionLanguage => '言語';

  @override
  String get settingsSectionAiProvider => 'AIプロバイダー';

  @override
  String get settingsApiKeyManage => 'APIキー管理';

  @override
  String get settingsSectionSubscription => 'サブスクリプション';

  @override
  String get settingsProPlanActive => 'Proプラン 利用中';

  @override
  String get settingsFreePlan => 'Freeプラン 利用中';

  @override
  String get settingsProPlanSubtitle => 'すべての機能が無制限';

  @override
  String get settingsFreePlanSubtitle => 'AI月20回、発音練習月10回';

  @override
  String get settingsSectionData => 'データ';

  @override
  String get settingsRescanLibrary => 'ライブラリを再スキャン';

  @override
  String get settingsRescanSubtitle => 'ディレクトリから新しいファイルを検索します';

  @override
  String get settingsResetData => '学習記録をリセット';

  @override
  String get settingsResetSubtitle => 'すべての進捗と記録を削除します';

  @override
  String get settingsResetDialogTitle => '記録をリセット';

  @override
  String get settingsResetDialogContent => 'すべての学習記録と進捗が削除されます。続けますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get settingsResetSuccess => 'すべての記録がリセットされました。';

  @override
  String get settingsSectionCache => 'キャッシュ管理';

  @override
  String get settingsCacheDriveDownload => 'Google Driveダウンロード';

  @override
  String get settingsClearAllCache => 'キャッシュをすべて削除';

  @override
  String get settingsClearCacheSubtitle =>
      'ダウンロードされたGoogle Driveファイルと一時ファイルを削除';

  @override
  String get settingsCacheDeleteDialogTitle => 'キャッシュを削除';

  @override
  String settingsCacheDeleteDialogContent(String size) {
    return '$sizeのキャッシュが削除されます。';
  }

  @override
  String get settingsCacheDeleteSuccess => 'キャッシュが削除されました。';

  @override
  String get settingsAppLanguage => 'アプリの言語';

  @override
  String get settingsAppLanguageTitle => 'アプリの言語を選択';

  @override
  String get settingsSystemDefault => 'システムデフォルト';

  @override
  String get settingsSystemDefaultSubtitle => 'デバイスの言語に従います';

  @override
  String homeStreakActive(int days) {
    return '$days日連続学習中！';
  }

  @override
  String homeStreakStats(int longest, int total) {
    return '最長$longest日 · 合計$total日';
  }

  @override
  String get homeEmptyLibrary => 'ライブラリからファイルを追加して学習を始めましょう。';

  @override
  String get homeNoHistory => 'まだ学習記録がありません。';

  @override
  String get homeStatusDone => '完了';

  @override
  String get homeStatusStudying => '学習中';

  @override
  String homeDueReview(int count) {
    return '今日の復習: $count文';
  }

  @override
  String get homeNoDueReview => '復習する文なし';

  @override
  String get homeAiConversation => 'AI会話練習';

  @override
  String get homeAiConversationSubtitle => 'ネイティブAIと自由に会話する';

  @override
  String get homePhoneticsHub => '発音トレーニングセンター';

  @override
  String get homePhoneticsHubSubtitle => 'TTS + オンデバイス採点 · API不要';

  @override
  String get tutorialSkip => 'スキップ';

  @override
  String get tutorialStart => '始めましょう 🚀';

  @override
  String get tutorialNext => '次へ';

  @override
  String get playerClipEdit => 'クリップ編集';

  @override
  String get playerSpeedSuggestion => '70%以上聴きました！再生速度を上げてみますか？ 🚀';

  @override
  String get playerSpeedIncrease => '上げる';

  @override
  String get playerMenuDictation => 'ディクテーション練習';

  @override
  String get playerSelectFileFirst => 'まずオーディオファイルを選択してください。';

  @override
  String get playerMenuActiveRecall => '能動的想起トレーニング';

  @override
  String get playerMenuBookmark => 'ブックマーク保存';

  @override
  String get playerBookmarkSaved => 'ブックマークに保存しました！';

  @override
  String get playerBookmarkDuplicate => 'すでにブックマーク済みの文です。';

  @override
  String get playerBeginnerMode => '入門者モード (0.75x)';

  @override
  String get playerLoopOff => 'リピートなし';

  @override
  String get playerLoopOne => '1曲リピート';

  @override
  String get playerLoopAll => '全曲リピート';

  @override
  String get playerScriptReady => '台本準備完了';

  @override
  String get playerNoScript => '台本なし';

  @override
  String playerAbLoopASet(String time) {
    return 'A: $time — B 未設定';
  }

  @override
  String playerError(String error) {
    return 'エラー: $error';
  }

  @override
  String get conversationTopicSuggest => 'トピック提案';

  @override
  String conversationInputHint(String language) {
    return '$languageで話してみてください...';
  }

  @override
  String conversationPracticeTitle(String language) {
    return '$language会話練習';
  }

  @override
  String get conversationWelcomeMsg => 'ネイティブAIと自由に会話しましょう。\nミスを恐れないでください！';

  @override
  String get conversationStartBtn => '会話を始める';

  @override
  String get conversationTopicExamples => 'トピック例';

  @override
  String get statsStudiedContent => '学習済みコンテンツ';

  @override
  String statsItemCount(int count) {
    return '$count個';
  }

  @override
  String get statsTotalTime => '総学習時間';

  @override
  String statsMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String get statsNoHistory => 'まだ学習記録がありません。\nライブラリからコンテンツを追加してください。';

  @override
  String get statsProgressByItem => '項目別進捗';

  @override
  String get statsPronunciationProgress => '発音向上状況';

  @override
  String get statsPronunciationEmpty => 'シャドーイング練習を完了すると、発音向上記録がここに表示されます。';

  @override
  String statsPracticeCount(int count) {
    return '$count回練習';
  }

  @override
  String get statsStreakSection => '学習ストリーク';

  @override
  String get statsStreakCurrentLabel => '連続学習';

  @override
  String get statsStreakLongestLabel => '最長ストリーク';

  @override
  String get statsStreakTotalLabel => '総学習日数';

  @override
  String statsDays(int days) {
    return '$days日';
  }

  @override
  String get statsJournal => '学習日誌';

  @override
  String get statsJournalEmpty => '学習を始めると自動的に日誌が記録されます。';

  @override
  String get statsShareCard => '学習カードをシェア';

  @override
  String get statsShareSubtitle => '学習成果をSNSでシェアしましょう';

  @override
  String get statsMinimalPair => '最小対訓練';

  @override
  String get statsMinimalPairSubtitle => '似た音の聞き分け（英語/日本語/スペイン語）';

  @override
  String statsError(String error) {
    return 'エラー: $error';
  }

  @override
  String get phoneticsHubFreeTitle => 'AIなしで発音練習';

  @override
  String get phoneticsHubFreeSubtitle => 'デバイスTTS + オンデバイス音声認識\nAPIキー不要で無料使用可能';

  @override
  String get phoneticsHubTrainingTools => 'トレーニングツール';

  @override
  String get phoneticsComingSoon => '準備中';

  @override
  String get phoneticsSpanishIpa => 'スペイン語IPA';

  @override
  String get phoneticsSpanishIpaSubtitle => 'スペイン語発音記号 + 練習（準備中）';

  @override
  String get apiKeyRequired => '少なくとも1つのAPIキーを入力してください。';

  @override
  String get apiKeyInvalidFormat => 'OpenAI APIキーの形式が正しくありません。(sk-で始まる必要があります)';

  @override
  String get apiKeySaved => 'APIキーが安全に保存されました。';

  @override
  String get libraryNewPlaylist => '新しいプレイリスト';

  @override
  String get libraryImport => 'インポート';

  @override
  String get libraryAllTab => 'すべて';

  @override
  String get libraryLocalSource => 'ローカル';

  @override
  String get libraryNoScript => 'スクリプトなし';

  @override
  String get libraryUnsetLanguage => '未設定';

  @override
  String get libraryEmptyPlaylist => 'プレイリストがありません。';

  @override
  String get libraryCreatePlaylist => '新しいプレイリストを作成';

  @override
  String libraryTrackCount(int count) {
    return '$count曲';
  }

  @override
  String libraryMoreTracks(int count) {
    return '+ $count曲 もっと';
  }

  @override
  String get libraryEditNameEmoji => '名前/絵文字を編集';

  @override
  String get libraryDeletePlaylist => '削除';

  @override
  String get libraryEditPlaylist => 'プレイリストを編集';

  @override
  String get librarySetLanguage => '言語設定';

  @override
  String libraryChangeLanguage(String lang) {
    return '言語変更（現在: $lang）';
  }

  @override
  String get libraryAddToPlaylist => 'プレイリストに追加';

  @override
  String get libraryLanguageBadge => '言語バッジ';

  @override
  String get phoneticsQuizTitle => '発音クイズ';

  @override
  String get phoneticsQuizDesc => 'IPA記号 ↔ 単語マッチングクイズ\nストリークボーナス + 正確度統計';

  @override
  String get phoneticsTtsPracticeTitle => 'TTS発音練習';

  @override
  String get phoneticsTtsPracticeDesc => '単語を聞いてIPA記号とともに繰り返す\nAPIキー不要 · 完全無料';

  @override
  String get phoneticsMinimalPairDesc =>
      '似た音の聞き分け（ship vs sheep など）\nTTS聴取 + 発音採点';

  @override
  String get phoneticsPitchAccentTitle => '日本語ピッチアクセント';

  @override
  String get phoneticsPitchAccentDesc => '同音異義語のピッチパターン可視化訓練\n例: はし(箸/橋/端)の区別';

  @override
  String get phoneticsKanaDrillTitle => 'ひらがな・カタカナ ドリル';

  @override
  String get phoneticsKanaDrillDesc => 'かな文字をタップしてTTS発音を聴く\n五十音図全体収録';

  @override
  String get libraryPlaylistTab => 'プレイリスト';

  @override
  String get importTitle => 'インポート';

  @override
  String get importFromDevice => 'このデバイスからインポート';

  @override
  String get importFromDeviceSubtitle => 'ローカルフォルダからオーディオ+スクリプトを読み込む';

  @override
  String get importFromICloud => 'iCloud Driveからインポート';

  @override
  String get importFromICloudSubtitle => 'iCloud Driveフォルダをライブラリに連結';

  @override
  String get importFromGoogleDrive => 'Google Driveからインポート';

  @override
  String get importFromGoogleDriveSubtitle => 'Google Driveフォルダを参照してダウンロード';

  @override
  String get importAutoSync => 'Scripta Sync iCloudフォルダの自動同期';

  @override
  String get importAutoSyncSubtitle => 'iCloud Drive/Scripta Sync/フォルダを自動スキャン';

  @override
  String heatmapTitle(int weeks) {
    return '学習記録（最近$weeks週間）';
  }

  @override
  String heatmapTooltip(String date, int minutes) {
    return '$date: $minutes分';
  }

  @override
  String get heatmapNoActivity => '学習なし';

  @override
  String get heatmapLess => '少ない';

  @override
  String get heatmapMore => '多い';
}
