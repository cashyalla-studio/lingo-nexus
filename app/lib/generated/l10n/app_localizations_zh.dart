// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Scripta Sync';

  @override
  String get welcomeBack => '欢迎回来！';

  @override
  String get readyToMaster => '准备好今天掌握另一种语言了吗？';

  @override
  String get continueStudying => '继续学习';

  @override
  String get myRecentActivity => '最近活动';

  @override
  String get seeAll => '查看全部';

  @override
  String get home => '首页';

  @override
  String get library => '库';

  @override
  String get stats => '统计';

  @override
  String get settings => '设置';

  @override
  String get getStarted => '开始';

  @override
  String get importContent => '导入内容';

  @override
  String get aiSyncAnalyze => 'AI同步与分析';

  @override
  String get immersiveStudy => '沉浸式学习';

  @override
  String get importDescription => '轻松从您的设备导入音频文件和文本脚本。';

  @override
  String get aiSyncDescription => 'AI分析句子并将其与音频完美同步。';

  @override
  String get immersiveDescription => '在无干扰的沉浸式播放器中提高您的语言技能。';

  @override
  String get selectedSentence => '选定的句子';

  @override
  String get aiGrammarAnalysis => 'AI语法分析';

  @override
  String get vocabularyHelper => '词汇助手';

  @override
  String get shadowingStudio => '影子练习室';

  @override
  String get aiAutoSync => 'AI自动同步';

  @override
  String get syncDescription => '使用 Scripta Sync AI 轻松将文本脚本与音频对齐。';

  @override
  String get startAutoSync => '开始自动同步 (1 积分)';

  @override
  String get buyCredits => '购买积分';

  @override
  String get useOwnApiKey => '或使用您自己的 API 密钥 (BYOK)';

  @override
  String get shadowingNativeSpeaker => '母语者';

  @override
  String get shadowingYourTurn => '到你了';

  @override
  String get listening => '正在倾听...';

  @override
  String get accuracy => '准确度';

  @override
  String get intonation => '语调';

  @override
  String get fluency => '流利度';

  @override
  String get syncCompleted => '自动同步完成！';

  @override
  String get noContentFound => '未找到内容。点击文件夹图标进行导入。';

  @override
  String get selectFile => '请选择文件';

  @override
  String get noScriptFile => '未找到脚本文件。';

  @override
  String get noScriptHint => '请在同一文件夹中添加与音频同名的 .txt 文件。';

  @override
  String get settingsSectionLanguage => '语言';

  @override
  String get settingsSectionAiProvider => 'AI 提供商';

  @override
  String get settingsApiKeyManage => '管理 API 密钥';

  @override
  String get settingsSectionSubscription => '订阅';

  @override
  String get settingsProPlanActive => 'Pro 计划订阅中';

  @override
  String get settingsFreePlan => '免费计划使用中';

  @override
  String get settingsProPlanSubtitle => '所有功能无限使用';

  @override
  String get settingsFreePlanSubtitle => 'AI 每月 20 次，发音练习每月 10 次';

  @override
  String get settingsSectionData => '数据';

  @override
  String get settingsRescanLibrary => '重新扫描媒体库';

  @override
  String get settingsRescanSubtitle => '在目录中搜索新文件';

  @override
  String get settingsResetData => '重置学习记录';

  @override
  String get settingsResetSubtitle => '删除所有进度和记录';

  @override
  String get settingsResetDialogTitle => '重置记录';

  @override
  String get settingsResetDialogContent => '所有学习记录和进度将被删除。是否继续？';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get settingsResetSuccess => '所有记录已重置。';

  @override
  String get settingsSectionCache => '缓存管理';

  @override
  String get settingsCacheDriveDownload => 'Google Drive 下载';

  @override
  String get settingsClearAllCache => '清除所有缓存';

  @override
  String get settingsClearCacheSubtitle => '删除已下载的 Google Drive 文件和临时文件';

  @override
  String get settingsCacheDeleteDialogTitle => '删除缓存';

  @override
  String settingsCacheDeleteDialogContent(String size) {
    return '将删除 $size 的缓存。';
  }

  @override
  String get settingsCacheDeleteSuccess => '缓存已删除。';

  @override
  String get settingsAppLanguage => '应用语言';

  @override
  String get settingsAppLanguageTitle => '选择应用语言';

  @override
  String get settingsSystemDefault => '系统默认';

  @override
  String get settingsSystemDefaultSubtitle => '跟随设备语言';

  @override
  String homeStreakActive(int days) {
    return '连续学习$days天！';
  }

  @override
  String homeStreakStats(int longest, int total) {
    return '最长$longest天 · 共$total天';
  }

  @override
  String get homeEmptyLibrary => '从媒体库添加文件以开始学习。';

  @override
  String get homeNoHistory => '还没有学习记录。';

  @override
  String get homeStatusDone => '已完成';

  @override
  String get homeStatusStudying => '学习中';

  @override
  String homeDueReview(int count) {
    return '今日待复习$count句';
  }

  @override
  String get homeNoDueReview => '暂无待复习句子';

  @override
  String get homeAiConversation => 'AI对话练习';

  @override
  String get homeAiConversationSubtitle => '与母语级AI自由对话';

  @override
  String get homePhoneticsHub => '发音训练中心';

  @override
  String get homePhoneticsHubSubtitle => 'TTS + 设备本地评分 · 无需API';

  @override
  String get tutorialSkip => '跳过';

  @override
  String get tutorialStart => '开始 🚀';

  @override
  String get tutorialNext => '下一步';

  @override
  String get playerClipEdit => '编辑片段';

  @override
  String get playerSpeedSuggestion => '您已听完70%以上！尝试提高播放速度？ 🚀';

  @override
  String get playerSpeedIncrease => '提高';

  @override
  String get playerMenuDictation => '听写练习';

  @override
  String get playerSelectFileFirst => '请先选择音频文件。';

  @override
  String get playerMenuActiveRecall => '主动回忆训练';

  @override
  String get playerMenuBookmark => '保存书签';

  @override
  String get playerBookmarkSaved => '已保存书签！';

  @override
  String get playerBookmarkDuplicate => '该句已收藏。';

  @override
  String get playerBeginnerMode => '入门模式 (0.75x)';

  @override
  String get playerLoopOff => '不重复';

  @override
  String get playerLoopOne => '单曲循环';

  @override
  String get playerLoopAll => '全部循环';

  @override
  String get playerScriptReady => '字幕已就绪';

  @override
  String get playerNoScript => '无字幕';

  @override
  String playerAbLoopASet(String time) {
    return 'A: $time — B 未设置';
  }

  @override
  String playerError(String error) {
    return '错误: $error';
  }

  @override
  String get conversationTopicSuggest => '话题建议';

  @override
  String conversationInputHint(String language) {
    return '请用$language说话...';
  }

  @override
  String conversationPracticeTitle(String language) {
    return '$language对话练习';
  }

  @override
  String get conversationWelcomeMsg => '与母语级AI自由对话。\n不要害怕犯错！';

  @override
  String get conversationStartBtn => '开始对话';

  @override
  String get conversationTopicExamples => '话题示例';

  @override
  String get statsStudiedContent => '已学习内容';

  @override
  String statsItemCount(int count) {
    return '$count个';
  }

  @override
  String get statsTotalTime => '总学习时间';

  @override
  String statsMinutes(int minutes) {
    return '$minutes分钟';
  }

  @override
  String get statsNoHistory => '还没有学习记录。\n请从媒体库添加内容开始学习。';

  @override
  String get statsProgressByItem => '按项目查看进度';

  @override
  String get statsPronunciationProgress => '发音提升情况';

  @override
  String get statsPronunciationEmpty => '完成跟读练习后，发音提升记录将在此显示。';

  @override
  String statsPracticeCount(int count) {
    return '练习$count次';
  }

  @override
  String get statsStreakSection => '学习连续天数';

  @override
  String get statsStreakCurrentLabel => '当前连续';

  @override
  String get statsStreakLongestLabel => '最长连续';

  @override
  String get statsStreakTotalLabel => '总学习天数';

  @override
  String statsDays(int days) {
    return '$days天';
  }

  @override
  String get statsJournal => '学习日记';

  @override
  String get statsJournalEmpty => '开始学习后，日记将自动记录。';

  @override
  String get statsShareCard => '分享学习卡片';

  @override
  String get statsShareSubtitle => '在社交媒体上分享您的学习成就';

  @override
  String get statsMinimalPair => '最小对训练';

  @override
  String get statsMinimalPairSubtitle => '区分相似音（英语/日语/西班牙语）';

  @override
  String statsError(String error) {
    return '错误: $error';
  }

  @override
  String get phoneticsHubFreeTitle => '无需AI的发音训练';

  @override
  String get phoneticsHubFreeSubtitle => '设备TTS + 本地语音识别\n无需API密钥，免费使用';

  @override
  String get phoneticsHubTrainingTools => '训练工具';

  @override
  String get phoneticsComingSoon => '即将推出';

  @override
  String get phoneticsSpanishIpa => '西班牙语IPA';

  @override
  String get phoneticsSpanishIpaSubtitle => '西班牙语音标 + 练习（即将推出）';

  @override
  String get apiKeyRequired => '请至少输入一个API密钥。';

  @override
  String get apiKeyInvalidFormat => 'OpenAI API密钥格式不正确。(必须以sk-开头)';

  @override
  String get apiKeySaved => 'API密钥已安全保存。';

  @override
  String get libraryNewPlaylist => '新建播放列表';

  @override
  String get libraryImport => '导入';

  @override
  String get libraryAllTab => '全部';

  @override
  String get libraryLocalSource => '本地';

  @override
  String get libraryNoScript => '无脚本';

  @override
  String get libraryUnsetLanguage => '未设置';

  @override
  String get libraryEmptyPlaylist => '暂无播放列表。';

  @override
  String get libraryCreatePlaylist => '创建新播放列表';

  @override
  String libraryTrackCount(int count) {
    return '$count首';
  }

  @override
  String libraryMoreTracks(int count) {
    return '+$count首更多';
  }

  @override
  String get libraryEditNameEmoji => '编辑名称/表情';

  @override
  String get libraryDeletePlaylist => '删除';

  @override
  String get libraryEditPlaylist => '编辑播放列表';

  @override
  String get librarySetLanguage => '设置语言';

  @override
  String libraryChangeLanguage(String lang) {
    return '更改语言（当前: $lang）';
  }

  @override
  String get libraryAddToPlaylist => '添加到播放列表';

  @override
  String get libraryLanguageBadge => '语言标签';

  @override
  String get phoneticsQuizTitle => '发音测验';

  @override
  String get phoneticsQuizDesc => 'IPA符号 ↔ 单词匹配测验\n连续奖励 + 准确率统计';

  @override
  String get phoneticsTtsPracticeTitle => 'TTS发音练习';

  @override
  String get phoneticsTtsPracticeDesc => '听单词并配合IPA符号跟读\n无需API密钥 · 完全免费';

  @override
  String get phoneticsMinimalPairDesc => '区分相似音（ship vs sheep等）\nTTS听力 + 发音评分';

  @override
  String get phoneticsPitchAccentTitle => '日语音调重音';

  @override
  String get phoneticsPitchAccentDesc => '同音异义词音调模式可视化训练\n例：はし(箸/橋/端)的区分';

  @override
  String get phoneticsKanaDrillTitle => '平假名·片假名练习';

  @override
  String get phoneticsKanaDrillDesc => '点击任何假名字符听TTS发音\n收录完整五十音图';

  @override
  String get libraryPlaylistTab => '播放列表';

  @override
  String get importTitle => '导入';

  @override
  String get importFromDevice => '从本设备导入';

  @override
  String get importFromDeviceSubtitle => '从本地文件夹加载音频和脚本';

  @override
  String get importFromICloud => '从iCloud Drive导入';

  @override
  String get importFromICloudSubtitle => '将iCloud Drive文件夹链接到媒体库';

  @override
  String get importFromGoogleDrive => '从Google Drive导入';

  @override
  String get importFromGoogleDriveSubtitle => '浏览并下载Google Drive文件夹';

  @override
  String get importAutoSync => '自动同步Scripta Sync iCloud文件夹';

  @override
  String get importAutoSyncSubtitle => '自动扫描iCloud Drive/Scripta Sync/文件夹';

  @override
  String heatmapTitle(int weeks) {
    return '学习记录（最近$weeks周）';
  }

  @override
  String heatmapTooltip(String date, int minutes) {
    return '$date: $minutes分钟';
  }

  @override
  String get heatmapNoActivity => '无学习';

  @override
  String get heatmapLess => '少';

  @override
  String get heatmapMore => '多';
}
