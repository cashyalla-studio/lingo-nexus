// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'Scripta Sync';

  @override
  String get welcomeBack => 'ברוך הבא!';

  @override
  String get readyToMaster => 'מוכן לשלוט בשפה נוספת היום?';

  @override
  String get continueStudying => 'המשך ללמוד';

  @override
  String get myRecentActivity => 'הפעילות האחרונה שלי';

  @override
  String get seeAll => 'ראה הכל';

  @override
  String get home => 'בית';

  @override
  String get library => 'ספרייה';

  @override
  String get stats => 'סטטיסטיקה';

  @override
  String get settings => 'הגדרות';

  @override
  String get getStarted => 'מתחילים';

  @override
  String get importContent => 'ייבוא תוכן';

  @override
  String get aiSyncAnalyze => 'סנכרון וניתוח AI';

  @override
  String get immersiveStudy => 'למידה מעמיקה';

  @override
  String get importDescription =>
      'ייבא בקלות קבצי אודיו ותמלילי טקסט מהמכשיר שלך.';

  @override
  String get aiSyncDescription =>
      'AI מנתח משפטים ומסנכרן אותם בצורה מושלמת עם האודיו.';

  @override
  String get immersiveDescription =>
      'שפר את כישורי השפה שלך בנגן מעמיק ללא הסחות דעת.';

  @override
  String get selectedSentence => 'משפט נבחר';

  @override
  String get aiGrammarAnalysis => 'ניתוח דקדוק AI';

  @override
  String get vocabularyHelper => 'עוזר אוצר מילים';

  @override
  String get shadowingStudio => 'סטודיו צל';

  @override
  String get aiAutoSync => 'סנכרון אוטומטי AI';

  @override
  String get syncDescription =>
      'יישר את תמליל הטקסט שלך עם האודיו ללא מאמץ באמצעות Scripta Sync AI.';

  @override
  String get startAutoSync => 'התחל סנכרון אוטומטי (קרדיט 1)';

  @override
  String get buyCredits => 'קנה קרדיטים';

  @override
  String get useOwnApiKey => 'או השתמש במפתח API משלך (BYOK)';

  @override
  String get shadowingNativeSpeaker => 'דובר שפת אם';

  @override
  String get shadowingYourTurn => 'תורך';

  @override
  String get listening => 'מקשיב...';

  @override
  String get accuracy => 'דיוק';

  @override
  String get intonation => 'אינטונציה';

  @override
  String get fluency => 'שטף';

  @override
  String get syncCompleted => 'הסנכרון האוטומטי הושלם!';

  @override
  String get noContentFound => 'לא נמצא תוכן. הקש על סמל התיקייה לייבוא.';

  @override
  String get selectFile => 'בחר קובץ';

  @override
  String get noScriptFile => 'קובץ תמליל לא נמצא.';

  @override
  String get noScriptHint =>
      'הוסף קובץ .txt עם אותו שם כמו האודיו באותה תיקייה.';

  @override
  String get settingsSectionLanguage => 'שפה';

  @override
  String get settingsSectionAiProvider => 'ספק בינה מלאכותית';

  @override
  String get settingsApiKeyManage => 'נהל מפתחות API';

  @override
  String get settingsSectionSubscription => 'מנוי';

  @override
  String get settingsProPlanActive => 'תוכנית Pro פעילה';

  @override
  String get settingsFreePlan => 'תוכנית חינמית';

  @override
  String get settingsProPlanSubtitle => 'כל התכונות ללא הגבלה';

  @override
  String get settingsFreePlanSubtitle =>
      '20 שימושי AI לחודש, 10 שיעורי הגייה לחודש';

  @override
  String get settingsSectionData => 'נתונים';

  @override
  String get settingsRescanLibrary => 'סרוק מחדש את הספרייה';

  @override
  String get settingsRescanSubtitle => 'מחפש קבצים חדשים בספרייה';

  @override
  String get settingsResetData => 'אפס נתוני למידה';

  @override
  String get settingsResetSubtitle => 'מוחק את כל ההתקדמות והרשומות';

  @override
  String get settingsResetDialogTitle => 'אפס רשומות';

  @override
  String get settingsResetDialogContent =>
      'כל רשומות הלמידה וההתקדמות יימחקו. האם להמשיך?';

  @override
  String get cancel => 'ביטול';

  @override
  String get delete => 'מחק';

  @override
  String get settingsResetSuccess => 'כל הרשומות אופסו.';

  @override
  String get settingsSectionCache => 'ניהול מטמון';

  @override
  String get settingsCacheDriveDownload => 'הורדות Google Drive';

  @override
  String get settingsClearAllCache => 'נקה את כל המטמון';

  @override
  String get settingsClearCacheSubtitle =>
      'מחק קבצי Google Drive שהורדו וקבצים זמניים';

  @override
  String get settingsCacheDeleteDialogTitle => 'מחק מטמון';

  @override
  String settingsCacheDeleteDialogContent(String size) {
    return '$size של מטמון יימחק.';
  }

  @override
  String get settingsCacheDeleteSuccess => 'המטמון נמחק.';

  @override
  String get settingsAppLanguage => 'שפת האפליקציה';

  @override
  String get settingsAppLanguageTitle => 'בחר שפת אפליקציה';

  @override
  String get settingsSystemDefault => 'ברירת מחדל של המערכת';

  @override
  String get settingsSystemDefaultSubtitle => 'עוקב אחר שפת המכשיר';

  @override
  String homeStreakActive(int days) {
    return '$days ימים רצופים!';
  }

  @override
  String homeStreakStats(int longest, int total) {
    return 'הכי טוב: $longest ימים · סה\"כ: $total ימים';
  }

  @override
  String get homeEmptyLibrary => 'הוסף קבצים מהספרייה כדי להתחיל ללמוד.';

  @override
  String get homeNoHistory => 'אין עדיין היסטוריית לימוד.';

  @override
  String get homeStatusDone => 'הושלם';

  @override
  String get homeStatusStudying => 'לומד';

  @override
  String homeDueReview(int count) {
    return '$count משפטים לחזרה היום';
  }

  @override
  String get homeNoDueReview => 'אין משפטים לחזרה';

  @override
  String get homeAiConversation => 'תרגול שיחה עם AI';

  @override
  String get homeAiConversationSubtitle => 'שוחח בחופשיות עם AI ברמת שפת אם';

  @override
  String get homePhoneticsHub => 'מרכז אימון הגייה';

  @override
  String get homePhoneticsHubSubtitle => 'TTS + ניקוד במכשיר · ללא API';

  @override
  String get tutorialSkip => 'דלג';

  @override
  String get tutorialStart => 'התחל 🚀';

  @override
  String get tutorialNext => 'הבא';

  @override
  String get playerClipEdit => 'ערוך קליפ';

  @override
  String get playerSpeedSuggestion => 'האזנת ל-70%+! לנסות להאיץ? 🚀';

  @override
  String get playerSpeedIncrease => 'הגדל';

  @override
  String get playerMenuDictation => 'תרגול כתיב';

  @override
  String get playerSelectFileFirst => 'אנא בחר קובץ שמע תחילה.';

  @override
  String get playerMenuActiveRecall => 'אימון היזכרות פעילה';

  @override
  String get playerMenuBookmark => 'שמור סימניה';

  @override
  String get playerBookmarkSaved => 'הסימניה נשמרה!';

  @override
  String get playerBookmarkDuplicate => 'משפט זה כבר מסומן.';

  @override
  String get playerBeginnerMode => 'מצב מתחיל (0.75x)';

  @override
  String get playerLoopOff => 'ללא חזרה';

  @override
  String get playerLoopOne => 'חזור על אחת';

  @override
  String get playerLoopAll => 'חזור על הכל';

  @override
  String get playerScriptReady => 'תסריט מוכן';

  @override
  String get playerNoScript => 'אין תסריט';

  @override
  String playerAbLoopASet(String time) {
    return 'A: $time — B לא הוגדר';
  }

  @override
  String playerError(String error) {
    return 'שגיאה: $error';
  }

  @override
  String get conversationTopicSuggest => 'הצע נושא';

  @override
  String conversationInputHint(String language) {
    return 'דבר ב$language...';
  }

  @override
  String conversationPracticeTitle(String language) {
    return 'תרגול שיחה ב$language';
  }

  @override
  String get conversationWelcomeMsg =>
      'שוחח בחופשיות עם AI ברמת שפת אם.\nאל תפחד לטעות!';

  @override
  String get conversationStartBtn => 'התחל שיחה';

  @override
  String get conversationTopicExamples => 'דוגמאות לנושאים';

  @override
  String get statsStudiedContent => 'תוכן שנלמד';

  @override
  String statsItemCount(int count) {
    return '$count פריטים';
  }

  @override
  String get statsTotalTime => 'זמן לימוד כולל';

  @override
  String statsMinutes(int minutes) {
    return '$minutes דק\'';
  }

  @override
  String get statsNoHistory =>
      'אין עדיין היסטוריית לימוד.\nהוסף תוכן מהספרייה כדי להתחיל.';

  @override
  String get statsProgressByItem => 'התקדמות לפי פריט';

  @override
  String get statsPronunciationProgress => 'שיפור הגייה';

  @override
  String get statsPronunciationEmpty =>
      'השלם סשנים של צַלְלוּת כדי לראות את שיפור ההגייה שלך כאן.';

  @override
  String statsPracticeCount(int count) {
    return '$count סשנים';
  }

  @override
  String get statsStreakSection => 'רצף לימוד';

  @override
  String get statsStreakCurrentLabel => 'רצף נוכחי';

  @override
  String get statsStreakLongestLabel => 'רצף ארוך ביותר';

  @override
  String get statsStreakTotalLabel => 'ימים כולל';

  @override
  String statsDays(int days) {
    return '$days ימים';
  }

  @override
  String get statsJournal => 'יומן לימוד';

  @override
  String get statsJournalEmpty => 'היומן יירשם אוטומטית כשתתחיל ללמוד.';

  @override
  String get statsShareCard => 'שתף כרטיס לימוד';

  @override
  String get statsShareSubtitle => 'שתף את הישגי הלמידה שלך ברשתות החברתיות';

  @override
  String get statsMinimalPair => 'אימון זוגות מינימליים';

  @override
  String get statsMinimalPairSubtitle => 'הבחנה בין צלילים דומים (EN/JA/ES)';

  @override
  String statsError(String error) {
    return 'שגיאה: $error';
  }

  @override
  String get phoneticsHubFreeTitle => 'אימון הגייה ללא AI';

  @override
  String get phoneticsHubFreeSubtitle =>
      'TTS של המכשיר + זיהוי דיבור\nבחינם ללא מפתח API';

  @override
  String get phoneticsHubTrainingTools => 'כלי אימון';

  @override
  String get phoneticsComingSoon => 'בקרוב';

  @override
  String get phoneticsSpanishIpa => 'IPA ספרדית';

  @override
  String get phoneticsSpanishIpaSubtitle =>
      'סמלים פונטיים ספרדיים + תרגול (בקרוב)';

  @override
  String get apiKeyRequired => 'אנא הזן לפחות מפתח API אחד.';

  @override
  String get apiKeyInvalidFormat =>
      'פורמט מפתח API של OpenAI שגוי. (חייב להתחיל ב-sk-)';

  @override
  String get apiKeySaved => 'מפתח ה-API נשמר בבטחה.';

  @override
  String get libraryNewPlaylist => 'רשימת השמעה חדשה';

  @override
  String get libraryImport => 'ייבוא';

  @override
  String get libraryAllTab => 'הכל';

  @override
  String get libraryLocalSource => 'מקומי';

  @override
  String get libraryNoScript => 'ללא תסריט';

  @override
  String get libraryUnsetLanguage => 'לא מוגדר';

  @override
  String get libraryEmptyPlaylist => 'אין רשימות השמעה עדיין.';

  @override
  String get libraryCreatePlaylist => 'צור רשימת השמעה חדשה';

  @override
  String libraryTrackCount(int count) {
    return '$count רצועות';
  }

  @override
  String libraryMoreTracks(int count) {
    return '+ $count עוד';
  }

  @override
  String get libraryEditNameEmoji => 'ערוך שם/אמוג\'י';

  @override
  String get libraryDeletePlaylist => 'מחק';

  @override
  String get libraryEditPlaylist => 'ערוך רשימת השמעה';

  @override
  String get librarySetLanguage => 'הגדר שפה';

  @override
  String libraryChangeLanguage(String lang) {
    return 'שנה שפה (נוכחי: $lang)';
  }

  @override
  String get libraryAddToPlaylist => 'הוסף לרשימת השמעה';

  @override
  String get libraryLanguageBadge => 'תג שפה';

  @override
  String get phoneticsQuizTitle => 'חידון הגייה';

  @override
  String get phoneticsQuizDesc =>
      'חידון IPA ↔ התאמת מילים\nבונוס רצף + סטטיסטיקת דיוק';

  @override
  String get phoneticsTtsPracticeTitle => 'תרגול הגייה TTS';

  @override
  String get phoneticsTtsPracticeDesc =>
      'האזן למילים וחזור עם סמלי IPA\nללא מפתח API · חינם לחלוטין';

  @override
  String get phoneticsMinimalPairDesc =>
      'הבחנה בין צלילים דומים (ship vs sheep וכו\')\nהאזנה TTS + ניקוד הגייה';

  @override
  String get phoneticsPitchAccentTitle => 'מבטא גובה יפני';

  @override
  String get phoneticsPitchAccentDesc =>
      'הצג תבניות גובה לבעלי הגייה זהה\nלמשל はし (מקלות אכילה/גשר/קצה)';

  @override
  String get phoneticsKanaDrillTitle => 'תרגיל הירגנה · קטקנה';

  @override
  String get phoneticsKanaDrillDesc =>
      'הקש על כל תו קנה כדי לשמוע הגייה TTS\nכולל טבלת 50 הצלילים המלאה';

  @override
  String get libraryPlaylistTab => 'רשימות השמעה';

  @override
  String get importTitle => 'ייבוא';

  @override
  String get importFromDevice => 'ייבוא מהמכשיר הזה';

  @override
  String get importFromDeviceSubtitle => 'טען שמע + תסריטים מתיקייה מקומית';

  @override
  String get importFromICloud => 'ייבוא מ-iCloud Drive';

  @override
  String get importFromICloudSubtitle => 'קשר תיקיית iCloud Drive לספרייה';

  @override
  String get importFromGoogleDrive => 'ייבוא מ-Google Drive';

  @override
  String get importFromGoogleDriveSubtitle => 'עיין והורד תיקיית Google Drive';

  @override
  String get importAutoSync => 'סנכרון אוטומטי של תיקיית Scripta Sync iCloud';

  @override
  String get importAutoSyncSubtitle =>
      'סריקה אוטומטית של תיקיית iCloud Drive/Scripta Sync/';

  @override
  String heatmapTitle(int weeks) {
    return 'רשומת לימוד ($weeks שבועות אחרונים)';
  }

  @override
  String heatmapTooltip(String date, int minutes) {
    return '$date: $minutes דק\'';
  }

  @override
  String get heatmapNoActivity => 'ללא פעילות';

  @override
  String get heatmapLess => 'פחות';

  @override
  String get heatmapMore => 'יותר';
}
