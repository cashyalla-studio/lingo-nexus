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

  @override
  String get loginSubtitle => 'שפר את כישורי השפה שלך עם AI';

  @override
  String get loginWithGoogle => 'המשך עם Google';

  @override
  String get loginFeatureAi => 'מורה AI לדקדוק, אוצר מילים ושיחה (חינם)';

  @override
  String get loginFeaturePronunciation => 'הערכת הגייה וטון';

  @override
  String get loginFeatureSync => 'סנכרון אוטומטי עם AI — יצירת תסריטים מאודיו';

  @override
  String get loginFeatureFree => '3 דקות עיבוד אודיו AI חינמי ביום';

  @override
  String get loginLegalPrefix => 'בהמשך, אתה מסכים ל';

  @override
  String get loginTermsLink => 'תנאי השירות';

  @override
  String get loginLegalAnd => 'ול';

  @override
  String get loginPrivacyLink => 'מדיניות הפרטיות';

  @override
  String get loginLegalSuffix => ' שלנו.';

  @override
  String get settingsSectionAccount => 'חשבון';

  @override
  String get settingsLogin => 'התחברות';

  @override
  String get settingsLoginSubtitle => 'התחבר כדי להשתמש בתכונות AI';

  @override
  String get settingsSectionCredits => 'קרדיטים ומנוי';

  @override
  String get settingsCreditsSubtitle => 'ניהול קרדיטי אודיו AI ותוכניות';

  @override
  String get settingsLogout => 'התנתקות';

  @override
  String get settingsLogoutDialogTitle => 'התנתקות';

  @override
  String get settingsLogoutDialogContent => 'האם אתה בטוח שברצונך להתנתק?';

  @override
  String get settingsSectionLegal => 'משפטי';

  @override
  String get settingsTermsSubtitle => 'הצג את תנאי השירות שלנו';

  @override
  String get settingsPrivacySubtitle => 'כיצד אנו מטפלים בנתונים שלך';

  @override
  String get creditsTitle => 'קרדיטים';

  @override
  String get creditsDailyFree => 'המכסה החינמית של היום';

  @override
  String get creditsMinRemaining => 'דקות נותרו';

  @override
  String get creditsDailyResets => 'מתאפס בחצות';

  @override
  String get creditsPurchasedCredits => 'קרדיטים שנרכשו';

  @override
  String get creditsMinutes => 'דק\'';

  @override
  String get creditsSubscriptionActive => 'מנוי פעיל';

  @override
  String get creditsSubscriptionsTitle => 'תוכניות מנוי';

  @override
  String get creditsMostPopular => 'פופולרי';

  @override
  String get creditsPerMonth => '/ חודש';

  @override
  String get creditPacksTitle => 'חבילות קרדיטים';

  @override
  String get creditPacksSubtitle => 'רכישה חד פעמית, ללא תפוגה';

  @override
  String get creditsLoadError => 'טעינת מידע הקרדיטים נכשלה.';

  @override
  String get creditsPaymentComingSoon => 'מערכת תשלום בקרוב';

  @override
  String get termsTitle => 'תנאי השירות';

  @override
  String get termsLastUpdated => 'עודכן לאחרונה: מרץ 2025';

  @override
  String get termsSec1Title => '1. סקירת השירות';

  @override
  String get termsSec1Body =>
      'LingoNexus היא פלטפורמת לימוד שפות מבוססת AI. תנאים אלה מסדירים את השימוש שלך בשירות.';

  @override
  String get termsSec2Title => '2. חשבון ואימות';

  @override
  String get termsSec2Body =>
      'עליך להתחבר עם חשבון Google כדי להשתמש בתכונות AI. אתה אחראי על אבטחת חשבונך.';

  @override
  String get termsSec3Title => '3. קרדיטים ותשלום';

  @override
  String get termsSec3Body =>
      'עיבוד אודיו AI צורך קרדיטים. 3 דקות שימוש חינמי מסופקות מדי יום. קרדיטים שנרכשו אינם ניתנים להחזר.';

  @override
  String get termsSec4Title => '4. הגבלות שימוש';

  @override
  String get termsSec4Body =>
      'שימוש לרעה בשירות או שימוש אוטומטי מוגזם אסור. הגבלה של 10 דקות לכל העלאה.';

  @override
  String get termsSec5Title => '5. קניין רוחני';

  @override
  String get termsSec5Body =>
      'זכויות היוצרים של התוכן שהועלה שייכות למשתמש. תוצאות AI הן לצורכי עיון בלבד.';

  @override
  String get termsSec6Title => '6. הגבלת אחריות';

  @override
  String get termsSec6Body =>
      'איננו מבטיחים את דיוק תוצאות ה-AI. התנאים עשויים להשתנות עם הודעה מוקדמת.';

  @override
  String get privacyTitle => 'מדיניות הפרטיות';

  @override
  String get privacyLastUpdated => 'עודכן לאחרונה: מרץ 2025';

  @override
  String get privacySec1Title => '1. מידע שאנו אוספים';

  @override
  String get privacySec1Body =>
      'בהתחברות עם Google, אנו אוספים את האימייל, השם ותמונת הפרופיל שלך. נתוני אודיו אינם מאוחסנים בשרתינו.';

  @override
  String get privacySec2Title => '2. כיצד אנו משתמשים במידע שלך';

  @override
  String get privacySec2Body =>
      'המידע משמש אך ורק למתן השירות וניהול קרדיטים. איננו מוכרים מידע אישי.';

  @override
  String get privacySec3Title => '3. אבטחת נתונים';

  @override
  String get privacySec3Body =>
      'אסימוני אימות מאוחסנים באחסון המוצפן של המכשיר. נתוני השרת מוצפנים במנוחה.';

  @override
  String get privacySec4Title => '4. שירותי צד שלישי';

  @override
  String get privacySec4Body =>
      'אנו משתמשים ב-Google Sign-In, Google Gemini API ו-Alibaba Qwen API.';

  @override
  String get privacySec5Title => '5. הזכויות שלך';

  @override
  String get privacySec5Body =>
      'תוכל לבקש מחיקת חשבון בכל עת. צור קשר: support@lingonexus.app';

  @override
  String get syncNoiseWarning =>
      'רעש רקע עלול להפחית את דיוק התמלול. השתמש בשמע שהוקלט בסביבה שקטה.';

  @override
  String get syncTranslationLanguage => 'שפת תרגום';

  @override
  String get syncAudioLanguage => 'שפת האודיו';

  @override
  String get syncAnnotating => 'מייצר פונטיקה ותרגום…';

  @override
  String syncScriptSaved(Object count) {
    return '$count משפטים סונכרנו! הסקריפט נשמר.';
  }
}
