// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Scripta Sync';

  @override
  String get welcomeBack => 'Willkommen zurück!';

  @override
  String get readyToMaster => 'Bereit, heute eine weitere Sprache zu meistern?';

  @override
  String get continueStudying => 'Studium fortsetzen';

  @override
  String get myRecentActivity => 'Meine letzte Aktivität';

  @override
  String get seeAll => 'Alle ansehen';

  @override
  String get home => 'Start';

  @override
  String get library => 'Bibliothek';

  @override
  String get stats => 'Statistiken';

  @override
  String get settings => 'Einstellungen';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get importContent => 'Inhalt importieren';

  @override
  String get aiSyncAnalyze => 'AI-Sync & Analyse';

  @override
  String get immersiveStudy => 'Immersives Lernen';

  @override
  String get importDescription =>
      'Importieren Sie Audio-Dateien und Skripte einfach von Ihrem Gerät.';

  @override
  String get aiSyncDescription =>
      'KI analysiert Sätze und synchronisiert sie perfekt mit dem Audio.';

  @override
  String get immersiveDescription =>
      'Verbessern Sie Ihre Sprachkenntnisse in einem immersiven Player.';

  @override
  String get selectedSentence => 'Ausgewählter Satz';

  @override
  String get aiGrammarAnalysis => 'AI-Grammatikanalyse';

  @override
  String get vocabularyHelper => 'Vokabelhilfe';

  @override
  String get shadowingStudio => 'Shadowing-Studio';

  @override
  String get aiAutoSync => 'AI Auto-Sync';

  @override
  String get syncDescription =>
      'Richten Sie Ihr Skript mühelos mit Scripta Sync AI am Audio aus.';

  @override
  String get startAutoSync => 'Auto-Sync starten (1 Credit)';

  @override
  String get buyCredits => 'Credits kaufen';

  @override
  String get useOwnApiKey => 'Oder eigenen API-Key verwenden (BYOK)';

  @override
  String get shadowingNativeSpeaker => 'Muttersprachler';

  @override
  String get shadowingYourTurn => 'Du bist dran';

  @override
  String get listening => 'Hören...';

  @override
  String get accuracy => 'Genauigkeit';

  @override
  String get intonation => 'Intonation';

  @override
  String get fluency => 'Flüssigkeit';

  @override
  String get syncCompleted => 'Auto-Sync abgeschlossen!';

  @override
  String get noContentFound =>
      'Kein Inhalt gefunden. Tippen Sie auf das Ordnersymbol.';

  @override
  String get selectFile => 'Datei auswählen';

  @override
  String get noScriptFile => 'Keine Skriptdatei gefunden.';

  @override
  String get noScriptHint =>
      'Fügen Sie eine .txt-Datei mit demselben Namen wie die Audiodatei im gleichen Ordner hinzu.';

  @override
  String get settingsSectionLanguage => 'Sprache';

  @override
  String get settingsSectionAiProvider => 'KI-Anbieter';

  @override
  String get settingsApiKeyManage => 'API-Schlüssel verwalten';

  @override
  String get settingsSectionSubscription => 'Abonnement';

  @override
  String get settingsProPlanActive => 'Pro-Plan aktiv';

  @override
  String get settingsFreePlan => 'Kostenloser Plan';

  @override
  String get settingsProPlanSubtitle => 'Alle Funktionen unbegrenzt';

  @override
  String get settingsFreePlanSubtitle =>
      '20 KI-Nutzungen/Monat, 10 Ausspracheübungen/Monat';

  @override
  String get settingsSectionData => 'Daten';

  @override
  String get settingsRescanLibrary => 'Bibliothek neu scannen';

  @override
  String get settingsRescanSubtitle =>
      'Sucht nach neuen Dateien im Verzeichnis';

  @override
  String get settingsResetData => 'Lerndaten zurücksetzen';

  @override
  String get settingsResetSubtitle =>
      'Löscht alle Fortschritte und Aufzeichnungen';

  @override
  String get settingsResetDialogTitle => 'Aufzeichnungen zurücksetzen';

  @override
  String get settingsResetDialogContent =>
      'Alle Lernaufzeichnungen und Fortschritte werden gelöscht. Fortfahren?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get settingsResetSuccess =>
      'Alle Aufzeichnungen wurden zurückgesetzt.';

  @override
  String get settingsSectionCache => 'Cache-Verwaltung';

  @override
  String get settingsCacheDriveDownload => 'Google Drive-Downloads';

  @override
  String get settingsClearAllCache => 'Gesamten Cache löschen';

  @override
  String get settingsClearCacheSubtitle =>
      'Heruntergeladene Google Drive-Dateien und temporäre Dateien löschen';

  @override
  String get settingsCacheDeleteDialogTitle => 'Cache löschen';

  @override
  String settingsCacheDeleteDialogContent(String size) {
    return '$size Cache wird gelöscht.';
  }

  @override
  String get settingsCacheDeleteSuccess => 'Cache wurde gelöscht.';

  @override
  String get settingsAppLanguage => 'App-Sprache';

  @override
  String get settingsAppLanguageTitle => 'App-Sprache auswählen';

  @override
  String get settingsSystemDefault => 'Systemstandard';

  @override
  String get settingsSystemDefaultSubtitle => 'Folgt der Gerätesprache';

  @override
  String homeStreakActive(int days) {
    return '$days Tage am Stück!';
  }

  @override
  String homeStreakStats(int longest, int total) {
    return 'Bestleistung: $longest T. · Gesamt: $total T.';
  }

  @override
  String get homeEmptyLibrary =>
      'Füge Dateien aus der Bibliothek hinzu, um zu beginnen.';

  @override
  String get homeNoHistory => 'Noch keine Lernhistorie.';

  @override
  String get homeStatusDone => 'Fertig';

  @override
  String get homeStatusStudying => 'In Bearbeitung';

  @override
  String homeDueReview(int count) {
    return '$count Sätze zur Wiederholung heute';
  }

  @override
  String get homeNoDueReview => 'Keine Sätze zur Wiederholung';

  @override
  String get homeAiConversation => 'KI-Konversationsübung';

  @override
  String get homeAiConversationSubtitle =>
      'Frei mit einer muttersprachlichen KI chatten';

  @override
  String get homePhoneticsHub => 'Aussprache-Trainingszentrum';

  @override
  String get homePhoneticsHubSubtitle =>
      'TTS + geräteseitige Bewertung · Kein API nötig';

  @override
  String get tutorialSkip => 'Überspringen';

  @override
  String get tutorialStart => 'Loslegen 🚀';

  @override
  String get tutorialNext => 'Weiter';

  @override
  String get playerClipEdit => 'Clip bearbeiten';

  @override
  String get playerSpeedSuggestion =>
      '70%+ gehört! Geschwindigkeit erhöhen? 🚀';

  @override
  String get playerSpeedIncrease => 'Erhöhen';

  @override
  String get playerMenuDictation => 'Diktatübung';

  @override
  String get playerSelectFileFirst => 'Bitte zuerst eine Audiodatei auswählen.';

  @override
  String get playerMenuActiveRecall => 'Aktives Abruftraining';

  @override
  String get playerMenuBookmark => 'Lesezeichen speichern';

  @override
  String get playerBookmarkSaved => 'Lesezeichen gespeichert!';

  @override
  String get playerBookmarkDuplicate =>
      'Dieser Satz ist bereits mit einem Lesezeichen versehen.';

  @override
  String get playerBeginnerMode => 'Anfängermodus (0.75x)';

  @override
  String get playerLoopOff => 'Kein Wiederholen';

  @override
  String get playerLoopOne => 'Eins wiederholen';

  @override
  String get playerLoopAll => 'Alle wiederholen';

  @override
  String get playerScriptReady => 'Skript bereit';

  @override
  String get playerNoScript => 'Kein Skript';

  @override
  String playerAbLoopASet(String time) {
    return 'A: $time — B nicht gesetzt';
  }

  @override
  String playerError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get conversationTopicSuggest => 'Thema vorschlagen';

  @override
  String conversationInputHint(String language) {
    return 'Sprechen Sie auf $language...';
  }

  @override
  String conversationPracticeTitle(String language) {
    return '$language-Konversationsübung';
  }

  @override
  String get conversationWelcomeMsg =>
      'Unterhalten Sie sich frei mit einer Muttersprachler-KI.\nHaben Sie keine Angst vor Fehlern!';

  @override
  String get conversationStartBtn => 'Gespräch starten';

  @override
  String get conversationTopicExamples => 'Themenbeispiele';

  @override
  String get statsStudiedContent => 'Gelernte Inhalte';

  @override
  String statsItemCount(int count) {
    return '$count Elemente';
  }

  @override
  String get statsTotalTime => 'Gesamtlernzeit';

  @override
  String statsMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get statsNoHistory =>
      'Noch keine Lernhistorie.\nFüge Inhalte aus der Bibliothek hinzu.';

  @override
  String get statsProgressByItem => 'Fortschritt nach Element';

  @override
  String get statsPronunciationProgress => 'Aussprache-Verbesserung';

  @override
  String get statsPronunciationEmpty =>
      'Nach dem Shadowing-Training wird dein Aussprache-Fortschritt hier angezeigt.';

  @override
  String statsPracticeCount(int count) {
    return '$count Sitzungen';
  }

  @override
  String get statsStreakSection => 'Lernsträhne';

  @override
  String get statsStreakCurrentLabel => 'Aktuelle Strähne';

  @override
  String get statsStreakLongestLabel => 'Längste Strähne';

  @override
  String get statsStreakTotalLabel => 'Gesamttage';

  @override
  String statsDays(int days) {
    return '$days Tage';
  }

  @override
  String get statsJournal => 'Lerntagebuch';

  @override
  String get statsJournalEmpty =>
      'Dein Tagebuch wird automatisch aufgezeichnet, sobald du anfängst zu lernen.';

  @override
  String get statsShareCard => 'Lernkarte teilen';

  @override
  String get statsShareSubtitle => 'Teile deine Lernerfolge in sozialen Medien';

  @override
  String get statsMinimalPair => 'Minimalpaartraining';

  @override
  String get statsMinimalPairSubtitle =>
      'Ähnliche Laute unterscheiden (EN/JA/ES)';

  @override
  String statsError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get phoneticsHubFreeTitle => 'Aussprachetraining ohne KI';

  @override
  String get phoneticsHubFreeSubtitle =>
      'Geräte-TTS + On-Device-Spracherkennung\nKostenlos ohne API-Schlüssel';

  @override
  String get phoneticsHubTrainingTools => 'Trainingstools';

  @override
  String get phoneticsComingSoon => 'Demnächst';

  @override
  String get phoneticsSpanishIpa => 'Spanisches IPA';

  @override
  String get phoneticsSpanishIpaSubtitle =>
      'Spanische Lautzeichen + Übungen (demnächst)';

  @override
  String get apiKeyRequired => 'Bitte gib mindestens einen API-Schlüssel ein.';

  @override
  String get apiKeyInvalidFormat =>
      'Ungültiges OpenAI-API-Schlüsselformat. (muss mit sk- beginnen)';

  @override
  String get apiKeySaved => 'API-Schlüssel sicher gespeichert.';

  @override
  String get libraryNewPlaylist => 'Neue Wiedergabeliste';

  @override
  String get libraryImport => 'Importieren';

  @override
  String get libraryAllTab => 'Alle';

  @override
  String get libraryLocalSource => 'Lokal';

  @override
  String get libraryNoScript => 'Kein Skript';

  @override
  String get libraryUnsetLanguage => 'Nicht gesetzt';

  @override
  String get libraryEmptyPlaylist => 'Noch keine Wiedergabelisten.';

  @override
  String get libraryCreatePlaylist => 'Neue Wiedergabeliste erstellen';

  @override
  String libraryTrackCount(int count) {
    return '$count Tracks';
  }

  @override
  String libraryMoreTracks(int count) {
    return '+ $count weitere';
  }

  @override
  String get libraryEditNameEmoji => 'Name/Emoji bearbeiten';

  @override
  String get libraryDeletePlaylist => 'Löschen';

  @override
  String get libraryEditPlaylist => 'Wiedergabeliste bearbeiten';

  @override
  String get librarySetLanguage => 'Sprache festlegen';

  @override
  String libraryChangeLanguage(String lang) {
    return 'Sprache ändern (aktuell: $lang)';
  }

  @override
  String get libraryAddToPlaylist => 'Zur Wiedergabeliste hinzufügen';

  @override
  String get libraryLanguageBadge => 'Sprach-Badge';

  @override
  String get phoneticsQuizTitle => 'Aussprache-Quiz';

  @override
  String get phoneticsQuizDesc =>
      'IPA-Symbol ↔ Wort-Matching-Quiz\nSträhnenbonus + Genauigkeitsstatistik';

  @override
  String get phoneticsTtsPracticeTitle => 'TTS-Aussprache-Übung';

  @override
  String get phoneticsTtsPracticeDesc =>
      'Wörter hören und mit IPA-Symbolen wiederholen\nKein API-Schlüssel nötig · Völlig kostenlos';

  @override
  String get phoneticsMinimalPairDesc =>
      'Ähnliche Laute unterscheiden (ship vs sheep usw.)\nTTS-Hören + Aussprache-Bewertung';

  @override
  String get phoneticsPitchAccentTitle => 'Japanischer Tonhöhenakzent';

  @override
  String get phoneticsPitchAccentDesc =>
      'Visualisierung von Tonhöhenmustern bei Homophonen\nz.B. はし (Essstäbchen/Brücke/Kante)';

  @override
  String get phoneticsKanaDrillTitle => 'Hiragana · Katakana-Drill';

  @override
  String get phoneticsKanaDrillDesc =>
      'Tippe auf ein Kana-Zeichen, um die TTS-Aussprache zu hören\nVollständige 50-Laute-Tabelle enthalten';

  @override
  String get libraryPlaylistTab => 'Wiedergabelisten';

  @override
  String get importTitle => 'Importieren';

  @override
  String get importFromDevice => 'Von diesem Gerät importieren';

  @override
  String get importFromDeviceSubtitle =>
      'Audio + Skripte aus einem lokalen Ordner laden';

  @override
  String get importFromICloud => 'Von iCloud Drive importieren';

  @override
  String get importFromICloudSubtitle =>
      'iCloud Drive-Ordner mit der Bibliothek verknüpfen';

  @override
  String get importFromGoogleDrive => 'Von Google Drive importieren';

  @override
  String get importFromGoogleDriveSubtitle =>
      'Google Drive-Ordner durchsuchen und herunterladen';

  @override
  String get importAutoSync =>
      'Scripta Sync iCloud-Ordner automatisch synchronisieren';

  @override
  String get importAutoSyncSubtitle =>
      'iCloud Drive/Scripta Sync/-Ordner automatisch scannen';

  @override
  String heatmapTitle(int weeks) {
    return 'Lernverlauf (letzte $weeks Wochen)';
  }

  @override
  String heatmapTooltip(String date, int minutes) {
    return '$date: $minutes Min.';
  }

  @override
  String get heatmapNoActivity => 'Keine Aktivität';

  @override
  String get heatmapLess => 'Wenig';

  @override
  String get heatmapMore => 'Viel';
}
