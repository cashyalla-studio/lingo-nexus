import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('he'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Scripta Sync'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @readyToMaster.
  ///
  /// In en, this message translates to:
  /// **'Ready to master another language today?'**
  String get readyToMaster;

  /// No description provided for @continueStudying.
  ///
  /// In en, this message translates to:
  /// **'Continue Studying'**
  String get continueStudying;

  /// No description provided for @myRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'My Recent Activity'**
  String get myRecentActivity;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @importContent.
  ///
  /// In en, this message translates to:
  /// **'Import Content'**
  String get importContent;

  /// No description provided for @aiSyncAnalyze.
  ///
  /// In en, this message translates to:
  /// **'AI Sync & Analyze'**
  String get aiSyncAnalyze;

  /// No description provided for @immersiveStudy.
  ///
  /// In en, this message translates to:
  /// **'Immersive Study'**
  String get immersiveStudy;

  /// No description provided for @importDescription.
  ///
  /// In en, this message translates to:
  /// **'Easily import your audio files and text scripts from your device.'**
  String get importDescription;

  /// No description provided for @aiSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'AI analyzes sentences and syncs them perfectly with audio.'**
  String get aiSyncDescription;

  /// No description provided for @immersiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Improve your language skills in an immersive player without distractions.'**
  String get immersiveDescription;

  /// No description provided for @selectedSentence.
  ///
  /// In en, this message translates to:
  /// **'Selected Sentence'**
  String get selectedSentence;

  /// No description provided for @aiGrammarAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Grammar Analysis'**
  String get aiGrammarAnalysis;

  /// No description provided for @vocabularyHelper.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Helper'**
  String get vocabularyHelper;

  /// No description provided for @shadowingStudio.
  ///
  /// In en, this message translates to:
  /// **'Shadowing Studio'**
  String get shadowingStudio;

  /// No description provided for @aiAutoSync.
  ///
  /// In en, this message translates to:
  /// **'AI Auto-Sync'**
  String get aiAutoSync;

  /// No description provided for @syncDescription.
  ///
  /// In en, this message translates to:
  /// **'Align your text script with audio effortlessly using Scripta Sync AI.'**
  String get syncDescription;

  /// No description provided for @startAutoSync.
  ///
  /// In en, this message translates to:
  /// **'Start Auto-Sync (1 Credit)'**
  String get startAutoSync;

  /// No description provided for @buyCredits.
  ///
  /// In en, this message translates to:
  /// **'Buy Credits'**
  String get buyCredits;

  /// No description provided for @useOwnApiKey.
  ///
  /// In en, this message translates to:
  /// **'Or use your own API Key (BYOK)'**
  String get useOwnApiKey;

  /// No description provided for @shadowingNativeSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Native Speaker'**
  String get shadowingNativeSpeaker;

  /// No description provided for @shadowingYourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your Turn'**
  String get shadowingYourTurn;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @intonation.
  ///
  /// In en, this message translates to:
  /// **'Intonation'**
  String get intonation;

  /// No description provided for @fluency.
  ///
  /// In en, this message translates to:
  /// **'Fluency'**
  String get fluency;

  /// No description provided for @syncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Auto-Sync Completed!'**
  String get syncCompleted;

  /// No description provided for @noContentFound.
  ///
  /// In en, this message translates to:
  /// **'No content found. Tap the folder icon to import.'**
  String get noContentFound;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select a file'**
  String get selectFile;

  /// No description provided for @noScriptFile.
  ///
  /// In en, this message translates to:
  /// **'No script file found.'**
  String get noScriptFile;

  /// No description provided for @noScriptHint.
  ///
  /// In en, this message translates to:
  /// **'Add a .txt file with the same name as the audio in the same folder.'**
  String get noScriptHint;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsSectionAiProvider.
  ///
  /// In en, this message translates to:
  /// **'AI Provider'**
  String get settingsSectionAiProvider;

  /// No description provided for @settingsApiKeyManage.
  ///
  /// In en, this message translates to:
  /// **'Manage API Keys'**
  String get settingsApiKeyManage;

  /// No description provided for @settingsSectionSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSectionSubscription;

  /// No description provided for @settingsProPlanActive.
  ///
  /// In en, this message translates to:
  /// **'Pro Plan Active'**
  String get settingsProPlanActive;

  /// No description provided for @settingsFreePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get settingsFreePlan;

  /// No description provided for @settingsProPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All features unlimited'**
  String get settingsProPlanSubtitle;

  /// No description provided for @settingsFreePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'20 AI uses/month, 10 pronunciation sessions/month'**
  String get settingsFreePlanSubtitle;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  /// No description provided for @settingsRescanLibrary.
  ///
  /// In en, this message translates to:
  /// **'Rescan Library'**
  String get settingsRescanLibrary;

  /// No description provided for @settingsRescanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Searches for new files in the directory'**
  String get settingsRescanSubtitle;

  /// No description provided for @settingsResetData.
  ///
  /// In en, this message translates to:
  /// **'Reset Learning Data'**
  String get settingsResetData;

  /// No description provided for @settingsResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deletes all progress and records'**
  String get settingsResetSubtitle;

  /// No description provided for @settingsResetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Records'**
  String get settingsResetDialogTitle;

  /// No description provided for @settingsResetDialogContent.
  ///
  /// In en, this message translates to:
  /// **'All learning records and progress will be deleted. Do you want to continue?'**
  String get settingsResetDialogContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'All records have been reset.'**
  String get settingsResetSuccess;

  /// No description provided for @settingsSectionCache.
  ///
  /// In en, this message translates to:
  /// **'Cache Management'**
  String get settingsSectionCache;

  /// No description provided for @settingsCacheDriveDownload.
  ///
  /// In en, this message translates to:
  /// **'Google Drive Downloads'**
  String get settingsCacheDriveDownload;

  /// No description provided for @settingsClearAllCache.
  ///
  /// In en, this message translates to:
  /// **'Clear All Cache'**
  String get settingsClearAllCache;

  /// No description provided for @settingsClearCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete downloaded Google Drive files and temporary files'**
  String get settingsClearCacheSubtitle;

  /// No description provided for @settingsCacheDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Cache'**
  String get settingsCacheDeleteDialogTitle;

  /// No description provided for @settingsCacheDeleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'{size} of cache will be deleted.'**
  String settingsCacheDeleteDialogContent(String size);

  /// No description provided for @settingsCacheDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cache deleted.'**
  String get settingsCacheDeleteSuccess;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get settingsAppLanguage;

  /// No description provided for @settingsAppLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select App Language'**
  String get settingsAppLanguageTitle;

  /// No description provided for @settingsSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsSystemDefault;

  /// No description provided for @settingsSystemDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follows device language'**
  String get settingsSystemDefaultSubtitle;

  /// No description provided for @homeStreakActive.
  ///
  /// In en, this message translates to:
  /// **'{days}-day streak!'**
  String homeStreakActive(int days);

  /// No description provided for @homeStreakStats.
  ///
  /// In en, this message translates to:
  /// **'Best: {longest} days · Total: {total} days'**
  String homeStreakStats(int longest, int total);

  /// No description provided for @homeEmptyLibrary.
  ///
  /// In en, this message translates to:
  /// **'Add files from the library to start learning.'**
  String get homeEmptyLibrary;

  /// No description provided for @homeNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No study history yet.'**
  String get homeNoHistory;

  /// No description provided for @homeStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get homeStatusDone;

  /// No description provided for @homeStatusStudying.
  ///
  /// In en, this message translates to:
  /// **'Studying'**
  String get homeStatusStudying;

  /// No description provided for @homeDueReview.
  ///
  /// In en, this message translates to:
  /// **'{count} sentences to review today'**
  String homeDueReview(int count);

  /// No description provided for @homeNoDueReview.
  ///
  /// In en, this message translates to:
  /// **'No sentences to review'**
  String get homeNoDueReview;

  /// No description provided for @homeAiConversation.
  ///
  /// In en, this message translates to:
  /// **'AI Conversation Practice'**
  String get homeAiConversation;

  /// No description provided for @homeAiConversationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat freely with a native-level AI'**
  String get homeAiConversationSubtitle;

  /// No description provided for @homePhoneticsHub.
  ///
  /// In en, this message translates to:
  /// **'Phonetics Training Center'**
  String get homePhoneticsHub;

  /// No description provided for @homePhoneticsHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'TTS + on-device scoring · No API needed'**
  String get homePhoneticsHubSubtitle;

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tutorialSkip;

  /// No description provided for @tutorialStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started 🚀'**
  String get tutorialStart;

  /// No description provided for @tutorialNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tutorialNext;

  /// No description provided for @playerClipEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Clip'**
  String get playerClipEdit;

  /// No description provided for @playerSpeedSuggestion.
  ///
  /// In en, this message translates to:
  /// **'You\'ve listened 70%+! Try increasing the speed? 🚀'**
  String get playerSpeedSuggestion;

  /// No description provided for @playerSpeedIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get playerSpeedIncrease;

  /// No description provided for @playerMenuDictation.
  ///
  /// In en, this message translates to:
  /// **'Dictation Practice'**
  String get playerMenuDictation;

  /// No description provided for @playerSelectFileFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select an audio file first.'**
  String get playerSelectFileFirst;

  /// No description provided for @playerMenuActiveRecall.
  ///
  /// In en, this message translates to:
  /// **'Active Recall Training'**
  String get playerMenuActiveRecall;

  /// No description provided for @playerMenuBookmark.
  ///
  /// In en, this message translates to:
  /// **'Save Bookmark'**
  String get playerMenuBookmark;

  /// No description provided for @playerBookmarkSaved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark saved!'**
  String get playerBookmarkSaved;

  /// No description provided for @playerBookmarkDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This sentence is already bookmarked.'**
  String get playerBookmarkDuplicate;

  /// No description provided for @playerBeginnerMode.
  ///
  /// In en, this message translates to:
  /// **'Beginner Mode (0.75x)'**
  String get playerBeginnerMode;

  /// No description provided for @playerLoopOff.
  ///
  /// In en, this message translates to:
  /// **'No Repeat'**
  String get playerLoopOff;

  /// No description provided for @playerLoopOne.
  ///
  /// In en, this message translates to:
  /// **'Repeat One'**
  String get playerLoopOne;

  /// No description provided for @playerLoopAll.
  ///
  /// In en, this message translates to:
  /// **'Repeat All'**
  String get playerLoopAll;

  /// No description provided for @playerScriptReady.
  ///
  /// In en, this message translates to:
  /// **'Script Ready'**
  String get playerScriptReady;

  /// No description provided for @playerNoScript.
  ///
  /// In en, this message translates to:
  /// **'No Script'**
  String get playerNoScript;

  /// No description provided for @playerAbLoopASet.
  ///
  /// In en, this message translates to:
  /// **'A: {time} — B not set'**
  String playerAbLoopASet(String time);

  /// No description provided for @playerError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String playerError(String error);

  /// No description provided for @conversationTopicSuggest.
  ///
  /// In en, this message translates to:
  /// **'Suggest Topic'**
  String get conversationTopicSuggest;

  /// No description provided for @conversationInputHint.
  ///
  /// In en, this message translates to:
  /// **'Speak in {language}...'**
  String conversationInputHint(String language);

  /// No description provided for @conversationPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'{language} Conversation Practice'**
  String conversationPracticeTitle(String language);

  /// No description provided for @conversationWelcomeMsg.
  ///
  /// In en, this message translates to:
  /// **'Chat freely with a native-level AI.\nDon\'t be afraid to make mistakes!'**
  String get conversationWelcomeMsg;

  /// No description provided for @conversationStartBtn.
  ///
  /// In en, this message translates to:
  /// **'Start Conversation'**
  String get conversationStartBtn;

  /// No description provided for @conversationTopicExamples.
  ///
  /// In en, this message translates to:
  /// **'Example Topics'**
  String get conversationTopicExamples;

  /// No description provided for @statsStudiedContent.
  ///
  /// In en, this message translates to:
  /// **'Studied Content'**
  String get statsStudiedContent;

  /// No description provided for @statsItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String statsItemCount(int count);

  /// No description provided for @statsTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Study Time'**
  String get statsTotalTime;

  /// No description provided for @statsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String statsMinutes(int minutes);

  /// No description provided for @statsNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No study history yet.\nAdd content from the library to get started.'**
  String get statsNoHistory;

  /// No description provided for @statsProgressByItem.
  ///
  /// In en, this message translates to:
  /// **'Progress by Item'**
  String get statsProgressByItem;

  /// No description provided for @statsPronunciationProgress.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation Improvement'**
  String get statsPronunciationProgress;

  /// No description provided for @statsPronunciationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Complete shadowing sessions to see your pronunciation improvement here.'**
  String get statsPronunciationEmpty;

  /// No description provided for @statsPracticeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
  String statsPracticeCount(int count);

  /// No description provided for @statsStreakSection.
  ///
  /// In en, this message translates to:
  /// **'Study Streak'**
  String get statsStreakSection;

  /// No description provided for @statsStreakCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get statsStreakCurrentLabel;

  /// No description provided for @statsStreakLongestLabel.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get statsStreakLongestLabel;

  /// No description provided for @statsStreakTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get statsStreakTotalLabel;

  /// No description provided for @statsDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String statsDays(int days);

  /// No description provided for @statsJournal.
  ///
  /// In en, this message translates to:
  /// **'Study Journal'**
  String get statsJournal;

  /// No description provided for @statsJournalEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your journal will be recorded automatically once you start studying.'**
  String get statsJournalEmpty;

  /// No description provided for @statsShareCard.
  ///
  /// In en, this message translates to:
  /// **'Share Study Card'**
  String get statsShareCard;

  /// No description provided for @statsShareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your learning achievement on social media'**
  String get statsShareSubtitle;

  /// No description provided for @statsMinimalPair.
  ///
  /// In en, this message translates to:
  /// **'Minimal Pair Training'**
  String get statsMinimalPair;

  /// No description provided for @statsMinimalPairSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Distinguish similar sounds (EN / JA / ES)'**
  String get statsMinimalPairSubtitle;

  /// No description provided for @statsError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String statsError(String error);

  /// No description provided for @phoneticsHubFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation Training Without AI'**
  String get phoneticsHubFreeTitle;

  /// No description provided for @phoneticsHubFreeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Device TTS + on-device speech recognition\nFree to use without an API key'**
  String get phoneticsHubFreeSubtitle;

  /// No description provided for @phoneticsHubTrainingTools.
  ///
  /// In en, this message translates to:
  /// **'Training Tools'**
  String get phoneticsHubTrainingTools;

  /// No description provided for @phoneticsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get phoneticsComingSoon;

  /// No description provided for @phoneticsSpanishIpa.
  ///
  /// In en, this message translates to:
  /// **'Spanish IPA'**
  String get phoneticsSpanishIpa;

  /// No description provided for @phoneticsSpanishIpaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spanish phonetic symbols + practice (coming soon)'**
  String get phoneticsSpanishIpaSubtitle;

  /// No description provided for @apiKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least one API key.'**
  String get apiKeyRequired;

  /// No description provided for @apiKeyInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid OpenAI API key format. (must start with sk-)'**
  String get apiKeyInvalidFormat;

  /// No description provided for @apiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API key securely saved.'**
  String get apiKeySaved;

  /// No description provided for @libraryNewPlaylist.
  ///
  /// In en, this message translates to:
  /// **'New Playlist'**
  String get libraryNewPlaylist;

  /// No description provided for @libraryImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get libraryImport;

  /// No description provided for @libraryAllTab.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get libraryAllTab;

  /// No description provided for @libraryLocalSource.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get libraryLocalSource;

  /// No description provided for @libraryNoScript.
  ///
  /// In en, this message translates to:
  /// **'No Script'**
  String get libraryNoScript;

  /// No description provided for @libraryUnsetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Unset'**
  String get libraryUnsetLanguage;

  /// No description provided for @libraryEmptyPlaylist.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet.'**
  String get libraryEmptyPlaylist;

  /// No description provided for @libraryCreatePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create New Playlist'**
  String get libraryCreatePlaylist;

  /// No description provided for @libraryTrackCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tracks'**
  String libraryTrackCount(int count);

  /// No description provided for @libraryMoreTracks.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more'**
  String libraryMoreTracks(int count);

  /// No description provided for @libraryEditNameEmoji.
  ///
  /// In en, this message translates to:
  /// **'Edit Name/Emoji'**
  String get libraryEditNameEmoji;

  /// No description provided for @libraryDeletePlaylist.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get libraryDeletePlaylist;

  /// No description provided for @libraryEditPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Edit Playlist'**
  String get libraryEditPlaylist;

  /// No description provided for @librarySetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Set Language'**
  String get librarySetLanguage;

  /// No description provided for @libraryChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language (current: {lang})'**
  String libraryChangeLanguage(String lang);

  /// No description provided for @libraryAddToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get libraryAddToPlaylist;

  /// No description provided for @libraryLanguageBadge.
  ///
  /// In en, this message translates to:
  /// **'Language Badge'**
  String get libraryLanguageBadge;

  /// No description provided for @phoneticsQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Phonetics Quiz'**
  String get phoneticsQuizTitle;

  /// No description provided for @phoneticsQuizDesc.
  ///
  /// In en, this message translates to:
  /// **'IPA symbol ↔ word matching quiz\nStreak bonus + accuracy stats'**
  String get phoneticsQuizDesc;

  /// No description provided for @phoneticsTtsPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'TTS Pronunciation Practice'**
  String get phoneticsTtsPracticeTitle;

  /// No description provided for @phoneticsTtsPracticeDesc.
  ///
  /// In en, this message translates to:
  /// **'Listen to words and repeat with IPA symbols\nNo API key needed · Completely free'**
  String get phoneticsTtsPracticeDesc;

  /// No description provided for @phoneticsMinimalPairDesc.
  ///
  /// In en, this message translates to:
  /// **'Distinguish similar sounds (ship vs sheep etc.)\nTTS listening + pronunciation scoring'**
  String get phoneticsMinimalPairDesc;

  /// No description provided for @phoneticsPitchAccentTitle.
  ///
  /// In en, this message translates to:
  /// **'Japanese Pitch Accent'**
  String get phoneticsPitchAccentTitle;

  /// No description provided for @phoneticsPitchAccentDesc.
  ///
  /// In en, this message translates to:
  /// **'Visualize pitch patterns for homophones\ne.g. はし (chopsticks/bridge/edge)'**
  String get phoneticsPitchAccentDesc;

  /// No description provided for @phoneticsKanaDrillTitle.
  ///
  /// In en, this message translates to:
  /// **'Hiragana · Katakana Drill'**
  String get phoneticsKanaDrillTitle;

  /// No description provided for @phoneticsKanaDrillDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap any kana character to hear TTS pronunciation\nFull 50-on chart included'**
  String get phoneticsKanaDrillDesc;

  /// No description provided for @libraryPlaylistTab.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get libraryPlaylistTab;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importTitle;

  /// No description provided for @importFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Import from this device'**
  String get importFromDevice;

  /// No description provided for @importFromDeviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Load audio + scripts from a local folder'**
  String get importFromDeviceSubtitle;

  /// No description provided for @importFromICloud.
  ///
  /// In en, this message translates to:
  /// **'Import from iCloud Drive'**
  String get importFromICloud;

  /// No description provided for @importFromICloudSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link an iCloud Drive folder to the library'**
  String get importFromICloudSubtitle;

  /// No description provided for @importFromGoogleDrive.
  ///
  /// In en, this message translates to:
  /// **'Import from Google Drive'**
  String get importFromGoogleDrive;

  /// No description provided for @importFromGoogleDriveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse and download a Google Drive folder'**
  String get importFromGoogleDriveSubtitle;

  /// No description provided for @importAutoSync.
  ///
  /// In en, this message translates to:
  /// **'Auto-sync Scripta Sync iCloud folder'**
  String get importAutoSync;

  /// No description provided for @importAutoSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-scan iCloud Drive/Scripta Sync/ folder'**
  String get importAutoSyncSubtitle;

  /// No description provided for @heatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Study Record (last {weeks} weeks)'**
  String heatmapTitle(int weeks);

  /// No description provided for @heatmapTooltip.
  ///
  /// In en, this message translates to:
  /// **'{date}: {minutes} min'**
  String heatmapTooltip(String date, int minutes);

  /// No description provided for @heatmapNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity'**
  String get heatmapNoActivity;

  /// No description provided for @heatmapLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get heatmapLess;

  /// No description provided for @heatmapMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get heatmapMore;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Level up your language skills with AI'**
  String get loginSubtitle;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginWithGoogle;

  /// No description provided for @loginFeatureAi.
  ///
  /// In en, this message translates to:
  /// **'AI grammar, vocabulary & conversation tutor (free)'**
  String get loginFeatureAi;

  /// No description provided for @loginFeaturePronunciation.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation & tone evaluation'**
  String get loginFeaturePronunciation;

  /// No description provided for @loginFeatureSync.
  ///
  /// In en, this message translates to:
  /// **'AI auto-sync — generate scripts from audio'**
  String get loginFeatureSync;

  /// No description provided for @loginFeatureFree.
  ///
  /// In en, this message translates to:
  /// **'3 minutes of free AI audio processing daily'**
  String get loginFeatureFree;

  /// No description provided for @loginLegalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get loginLegalPrefix;

  /// No description provided for @loginTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get loginTermsLink;

  /// No description provided for @loginLegalAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get loginLegalAnd;

  /// No description provided for @loginPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get loginPrivacyLink;

  /// No description provided for @loginLegalSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get loginLegalSuffix;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAccount;

  /// No description provided for @settingsLogin.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get settingsLogin;

  /// No description provided for @settingsLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to use AI features'**
  String get settingsLoginSubtitle;

  /// No description provided for @settingsSectionCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits & Subscription'**
  String get settingsSectionCredits;

  /// No description provided for @settingsCreditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage AI audio credits and plans'**
  String get settingsCreditsSubtitle;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogoutDialogTitle;

  /// No description provided for @settingsLogoutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get settingsLogoutDialogContent;

  /// No description provided for @settingsSectionLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsSectionLegal;

  /// No description provided for @settingsTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View our terms of service'**
  String get settingsTermsSubtitle;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get settingsPrivacySubtitle;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsTitle;

  /// No description provided for @creditsDailyFree.
  ///
  /// In en, this message translates to:
  /// **'Today\'s free quota'**
  String get creditsDailyFree;

  /// No description provided for @creditsMinRemaining.
  ///
  /// In en, this message translates to:
  /// **'min remaining'**
  String get creditsMinRemaining;

  /// No description provided for @creditsDailyResets.
  ///
  /// In en, this message translates to:
  /// **'Resets at midnight'**
  String get creditsDailyResets;

  /// No description provided for @creditsPurchasedCredits.
  ///
  /// In en, this message translates to:
  /// **'Purchased credits'**
  String get creditsPurchasedCredits;

  /// No description provided for @creditsMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get creditsMinutes;

  /// No description provided for @creditsSubscriptionActive.
  ///
  /// In en, this message translates to:
  /// **'subscription active'**
  String get creditsSubscriptionActive;

  /// No description provided for @creditsSubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Plans'**
  String get creditsSubscriptionsTitle;

  /// No description provided for @creditsMostPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get creditsMostPopular;

  /// No description provided for @creditsPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get creditsPerMonth;

  /// No description provided for @creditPacksTitle.
  ///
  /// In en, this message translates to:
  /// **'Credit Packs'**
  String get creditPacksTitle;

  /// No description provided for @creditPacksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase, no expiry'**
  String get creditPacksSubtitle;

  /// No description provided for @creditsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load credit info.'**
  String get creditsLoadError;

  /// No description provided for @creditsPaymentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Payment system coming soon'**
  String get creditsPaymentComingSoon;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsTitle;

  /// No description provided for @termsLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: March 2025'**
  String get termsLastUpdated;

  /// No description provided for @termsSec1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Service Overview'**
  String get termsSec1Title;

  /// No description provided for @termsSec1Body.
  ///
  /// In en, this message translates to:
  /// **'LingoNexus is an AI-powered language learning platform. These terms govern your use of the service.'**
  String get termsSec1Body;

  /// No description provided for @termsSec2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Account & Authentication'**
  String get termsSec2Title;

  /// No description provided for @termsSec2Body.
  ///
  /// In en, this message translates to:
  /// **'You must log in with a Google account to use AI features. You are responsible for the security of your account.'**
  String get termsSec2Body;

  /// No description provided for @termsSec3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Credits & Payment'**
  String get termsSec3Title;

  /// No description provided for @termsSec3Body.
  ///
  /// In en, this message translates to:
  /// **'AI audio processing consumes credits. 3 minutes of free usage is provided daily. Purchased credits are non-refundable.'**
  String get termsSec3Body;

  /// No description provided for @termsSec4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Usage Restrictions'**
  String get termsSec4Title;

  /// No description provided for @termsSec4Body.
  ///
  /// In en, this message translates to:
  /// **'Abusing the service or excessive automated usage is prohibited. 10-minute limit per upload.'**
  String get termsSec4Body;

  /// No description provided for @termsSec5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Intellectual Property'**
  String get termsSec5Title;

  /// No description provided for @termsSec5Body.
  ///
  /// In en, this message translates to:
  /// **'Copyright of uploaded content belongs to the user. AI results are for reference only.'**
  String get termsSec5Body;

  /// No description provided for @termsSec6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Disclaimer'**
  String get termsSec6Title;

  /// No description provided for @termsSec6Body.
  ///
  /// In en, this message translates to:
  /// **'We do not guarantee the accuracy of AI results. Terms may change with prior notice.'**
  String get termsSec6Body;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: March 2025'**
  String get privacyLastUpdated;

  /// No description provided for @privacySec1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacySec1Title;

  /// No description provided for @privacySec1Body.
  ///
  /// In en, this message translates to:
  /// **'When you sign in with Google, we collect your email, name, and profile photo. Audio data is not stored on our servers.'**
  String get privacySec1Body;

  /// No description provided for @privacySec2Title.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get privacySec2Title;

  /// No description provided for @privacySec2Body.
  ///
  /// In en, this message translates to:
  /// **'Information is used solely for service delivery and credit management. We do not sell personal information.'**
  String get privacySec2Body;

  /// No description provided for @privacySec3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Data Security'**
  String get privacySec3Title;

  /// No description provided for @privacySec3Body.
  ///
  /// In en, this message translates to:
  /// **'Authentication tokens are stored in your device\'s encrypted storage. Server data is encrypted at rest.'**
  String get privacySec3Body;

  /// No description provided for @privacySec4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Third-Party Services'**
  String get privacySec4Title;

  /// No description provided for @privacySec4Body.
  ///
  /// In en, this message translates to:
  /// **'We use Google Sign-In, Google Gemini API, and Alibaba Qwen API.'**
  String get privacySec4Body;

  /// No description provided for @privacySec5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Your Rights'**
  String get privacySec5Title;

  /// No description provided for @privacySec5Body.
  ///
  /// In en, this message translates to:
  /// **'You may request account deletion at any time. Contact: support@lingonexus.app'**
  String get privacySec5Body;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'he',
        'ja',
        'ko',
        'pt',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
