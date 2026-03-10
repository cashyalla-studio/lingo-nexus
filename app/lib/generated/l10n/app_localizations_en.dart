// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Scripta Sync';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get readyToMaster => 'Ready to master another language today?';

  @override
  String get continueStudying => 'Continue Studying';

  @override
  String get myRecentActivity => 'My Recent Activity';

  @override
  String get seeAll => 'See All';

  @override
  String get home => 'Home';

  @override
  String get library => 'Library';

  @override
  String get stats => 'Stats';

  @override
  String get settings => 'Settings';

  @override
  String get getStarted => 'Get Started';

  @override
  String get importContent => 'Import Content';

  @override
  String get aiSyncAnalyze => 'AI Sync & Analyze';

  @override
  String get immersiveStudy => 'Immersive Study';

  @override
  String get importDescription =>
      'Easily import your audio files and text scripts from your device.';

  @override
  String get aiSyncDescription =>
      'AI analyzes sentences and syncs them perfectly with audio.';

  @override
  String get immersiveDescription =>
      'Improve your language skills in an immersive player without distractions.';

  @override
  String get selectedSentence => 'Selected Sentence';

  @override
  String get aiGrammarAnalysis => 'AI Grammar Analysis';

  @override
  String get vocabularyHelper => 'Vocabulary Helper';

  @override
  String get shadowingStudio => 'Shadowing Studio';

  @override
  String get aiAutoSync => 'AI Auto-Sync';

  @override
  String get syncDescription =>
      'Align your text script with audio effortlessly using Scripta Sync AI.';

  @override
  String get startAutoSync => 'Start Auto-Sync (1 Credit)';

  @override
  String get buyCredits => 'Buy Credits';

  @override
  String get useOwnApiKey => 'Or use your own API Key (BYOK)';

  @override
  String get shadowingNativeSpeaker => 'Native Speaker';

  @override
  String get shadowingYourTurn => 'Your Turn';

  @override
  String get listening => 'Listening...';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get intonation => 'Intonation';

  @override
  String get fluency => 'Fluency';

  @override
  String get syncCompleted => 'Auto-Sync Completed!';

  @override
  String get noContentFound =>
      'No content found. Tap the folder icon to import.';

  @override
  String get selectFile => 'Select a file';

  @override
  String get noScriptFile => 'No script file found.';

  @override
  String get noScriptHint =>
      'Add a .txt file with the same name as the audio in the same folder.';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsSectionAiProvider => 'AI Provider';

  @override
  String get settingsApiKeyManage => 'Manage API Keys';

  @override
  String get settingsSectionSubscription => 'Subscription';

  @override
  String get settingsProPlanActive => 'Pro Plan Active';

  @override
  String get settingsFreePlan => 'Free Plan';

  @override
  String get settingsProPlanSubtitle => 'All features unlimited';

  @override
  String get settingsFreePlanSubtitle =>
      '20 AI uses/month, 10 pronunciation sessions/month';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsRescanLibrary => 'Rescan Library';

  @override
  String get settingsRescanSubtitle =>
      'Searches for new files in the directory';

  @override
  String get settingsResetData => 'Reset Learning Data';

  @override
  String get settingsResetSubtitle => 'Deletes all progress and records';

  @override
  String get settingsResetDialogTitle => 'Reset Records';

  @override
  String get settingsResetDialogContent =>
      'All learning records and progress will be deleted. Do you want to continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get settingsResetSuccess => 'All records have been reset.';

  @override
  String get settingsSectionCache => 'Cache Management';

  @override
  String get settingsCacheDriveDownload => 'Google Drive Downloads';

  @override
  String get settingsClearAllCache => 'Clear All Cache';

  @override
  String get settingsClearCacheSubtitle =>
      'Delete downloaded Google Drive files and temporary files';

  @override
  String get settingsCacheDeleteDialogTitle => 'Delete Cache';

  @override
  String settingsCacheDeleteDialogContent(String size) {
    return '$size of cache will be deleted.';
  }

  @override
  String get settingsCacheDeleteSuccess => 'Cache deleted.';

  @override
  String get settingsAppLanguage => 'App Language';

  @override
  String get settingsAppLanguageTitle => 'Select App Language';

  @override
  String get settingsSystemDefault => 'System Default';

  @override
  String get settingsSystemDefaultSubtitle => 'Follows device language';

  @override
  String homeStreakActive(int days) {
    return '$days-day streak!';
  }

  @override
  String homeStreakStats(int longest, int total) {
    return 'Best: $longest days · Total: $total days';
  }

  @override
  String get homeEmptyLibrary =>
      'Add files from the library to start learning.';

  @override
  String get homeNoHistory => 'No study history yet.';

  @override
  String get homeStatusDone => 'Done';

  @override
  String get homeStatusStudying => 'Studying';

  @override
  String homeDueReview(int count) {
    return '$count sentences to review today';
  }

  @override
  String get homeNoDueReview => 'No sentences to review';

  @override
  String get homeAiConversation => 'AI Conversation Practice';

  @override
  String get homeAiConversationSubtitle => 'Chat freely with a native-level AI';

  @override
  String get homePhoneticsHub => 'Phonetics Training Center';

  @override
  String get homePhoneticsHubSubtitle =>
      'TTS + on-device scoring · No API needed';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialStart => 'Get Started 🚀';

  @override
  String get tutorialNext => 'Next';

  @override
  String get playerClipEdit => 'Edit Clip';

  @override
  String get playerSpeedSuggestion =>
      'You\'ve listened 70%+! Try increasing the speed? 🚀';

  @override
  String get playerSpeedIncrease => 'Increase';

  @override
  String get playerMenuDictation => 'Dictation Practice';

  @override
  String get playerSelectFileFirst => 'Please select an audio file first.';

  @override
  String get playerMenuActiveRecall => 'Active Recall Training';

  @override
  String get playerMenuBookmark => 'Save Bookmark';

  @override
  String get playerBookmarkSaved => 'Bookmark saved!';

  @override
  String get playerBookmarkDuplicate => 'This sentence is already bookmarked.';

  @override
  String get playerBeginnerMode => 'Beginner Mode (0.75x)';

  @override
  String get playerLoopOff => 'No Repeat';

  @override
  String get playerLoopOne => 'Repeat One';

  @override
  String get playerLoopAll => 'Repeat All';

  @override
  String get playerScriptReady => 'Script Ready';

  @override
  String get playerNoScript => 'No Script';

  @override
  String playerAbLoopASet(String time) {
    return 'A: $time — B not set';
  }

  @override
  String playerError(String error) {
    return 'Error: $error';
  }

  @override
  String get conversationTopicSuggest => 'Suggest Topic';

  @override
  String conversationInputHint(String language) {
    return 'Speak in $language...';
  }

  @override
  String conversationPracticeTitle(String language) {
    return '$language Conversation Practice';
  }

  @override
  String get conversationWelcomeMsg =>
      'Chat freely with a native-level AI.\nDon\'t be afraid to make mistakes!';

  @override
  String get conversationStartBtn => 'Start Conversation';

  @override
  String get conversationTopicExamples => 'Example Topics';

  @override
  String get statsStudiedContent => 'Studied Content';

  @override
  String statsItemCount(int count) {
    return '$count items';
  }

  @override
  String get statsTotalTime => 'Total Study Time';

  @override
  String statsMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get statsNoHistory =>
      'No study history yet.\nAdd content from the library to get started.';

  @override
  String get statsProgressByItem => 'Progress by Item';

  @override
  String get statsPronunciationProgress => 'Pronunciation Improvement';

  @override
  String get statsPronunciationEmpty =>
      'Complete shadowing sessions to see your pronunciation improvement here.';

  @override
  String statsPracticeCount(int count) {
    return '$count sessions';
  }

  @override
  String get statsStreakSection => 'Study Streak';

  @override
  String get statsStreakCurrentLabel => 'Current Streak';

  @override
  String get statsStreakLongestLabel => 'Longest Streak';

  @override
  String get statsStreakTotalLabel => 'Total Days';

  @override
  String statsDays(int days) {
    return '$days days';
  }

  @override
  String get statsJournal => 'Study Journal';

  @override
  String get statsJournalEmpty =>
      'Your journal will be recorded automatically once you start studying.';

  @override
  String get statsShareCard => 'Share Study Card';

  @override
  String get statsShareSubtitle =>
      'Share your learning achievement on social media';

  @override
  String get statsMinimalPair => 'Minimal Pair Training';

  @override
  String get statsMinimalPairSubtitle =>
      'Distinguish similar sounds (EN / JA / ES)';

  @override
  String statsError(String error) {
    return 'Error: $error';
  }

  @override
  String get phoneticsHubFreeTitle => 'Pronunciation Training Without AI';

  @override
  String get phoneticsHubFreeSubtitle =>
      'Device TTS + on-device speech recognition\nFree to use without an API key';

  @override
  String get phoneticsHubTrainingTools => 'Training Tools';

  @override
  String get phoneticsComingSoon => 'Coming Soon';

  @override
  String get phoneticsSpanishIpa => 'Spanish IPA';

  @override
  String get phoneticsSpanishIpaSubtitle =>
      'Spanish phonetic symbols + practice (coming soon)';

  @override
  String get apiKeyRequired => 'Please enter at least one API key.';

  @override
  String get apiKeyInvalidFormat =>
      'Invalid OpenAI API key format. (must start with sk-)';

  @override
  String get apiKeySaved => 'API key securely saved.';

  @override
  String get libraryNewPlaylist => 'New Playlist';

  @override
  String get libraryImport => 'Import';

  @override
  String get libraryAllTab => 'All';

  @override
  String get libraryLocalSource => 'Local';

  @override
  String get libraryNoScript => 'No Script';

  @override
  String get libraryUnsetLanguage => 'Unset';

  @override
  String get libraryEmptyPlaylist => 'No playlists yet.';

  @override
  String get libraryCreatePlaylist => 'Create New Playlist';

  @override
  String libraryTrackCount(int count) {
    return '$count tracks';
  }

  @override
  String libraryMoreTracks(int count) {
    return '+ $count more';
  }

  @override
  String get libraryEditNameEmoji => 'Edit Name/Emoji';

  @override
  String get libraryDeletePlaylist => 'Delete';

  @override
  String get libraryEditPlaylist => 'Edit Playlist';

  @override
  String get librarySetLanguage => 'Set Language';

  @override
  String libraryChangeLanguage(String lang) {
    return 'Change Language (current: $lang)';
  }

  @override
  String get libraryAddToPlaylist => 'Add to Playlist';

  @override
  String get libraryLanguageBadge => 'Language Badge';

  @override
  String get phoneticsQuizTitle => 'Phonetics Quiz';

  @override
  String get phoneticsQuizDesc =>
      'IPA symbol ↔ word matching quiz\nStreak bonus + accuracy stats';

  @override
  String get phoneticsTtsPracticeTitle => 'TTS Pronunciation Practice';

  @override
  String get phoneticsTtsPracticeDesc =>
      'Listen to words and repeat with IPA symbols\nNo API key needed · Completely free';

  @override
  String get phoneticsMinimalPairDesc =>
      'Distinguish similar sounds (ship vs sheep etc.)\nTTS listening + pronunciation scoring';

  @override
  String get phoneticsPitchAccentTitle => 'Japanese Pitch Accent';

  @override
  String get phoneticsPitchAccentDesc =>
      'Visualize pitch patterns for homophones\ne.g. はし (chopsticks/bridge/edge)';

  @override
  String get phoneticsKanaDrillTitle => 'Hiragana · Katakana Drill';

  @override
  String get phoneticsKanaDrillDesc =>
      'Tap any kana character to hear TTS pronunciation\nFull 50-on chart included';

  @override
  String get libraryPlaylistTab => 'Playlists';

  @override
  String get importTitle => 'Import';

  @override
  String get importFromDevice => 'Import from this device';

  @override
  String get importFromDeviceSubtitle =>
      'Load audio + scripts from a local folder';

  @override
  String get importFromICloud => 'Import from iCloud Drive';

  @override
  String get importFromICloudSubtitle =>
      'Link an iCloud Drive folder to the library';

  @override
  String get importFromGoogleDrive => 'Import from Google Drive';

  @override
  String get importFromGoogleDriveSubtitle =>
      'Browse and download a Google Drive folder';

  @override
  String get importAutoSync => 'Auto-sync Scripta Sync iCloud folder';

  @override
  String get importAutoSyncSubtitle =>
      'Auto-scan iCloud Drive/Scripta Sync/ folder';

  @override
  String heatmapTitle(int weeks) {
    return 'Study Record (last $weeks weeks)';
  }

  @override
  String heatmapTooltip(String date, int minutes) {
    return '$date: $minutes min';
  }

  @override
  String get heatmapNoActivity => 'No activity';

  @override
  String get heatmapLess => 'Less';

  @override
  String get heatmapMore => 'More';
}
