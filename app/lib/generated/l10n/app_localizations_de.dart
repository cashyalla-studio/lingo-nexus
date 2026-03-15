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

  @override
  String get loginSubtitle => 'Verbessere deine Sprachkenntnisse mit KI';

  @override
  String get loginWithGoogle => 'Mit Google fortfahren';

  @override
  String get loginFeatureAi =>
      'KI-Grammatik, Vokabeln & Gesprächstutor (kostenlos)';

  @override
  String get loginFeaturePronunciation => 'Aussprache- und Tonbewertung';

  @override
  String get loginFeatureSync => 'KI-Auto-Sync — Skripte aus Audio generieren';

  @override
  String get loginFeatureFree =>
      '3 Minuten kostenlose KI-Audioverarbeitung täglich';

  @override
  String get loginLegalPrefix => 'Durch Fortfahren stimmst du unseren ';

  @override
  String get loginTermsLink => 'Nutzungsbedingungen';

  @override
  String get loginLegalAnd => 'und der';

  @override
  String get loginPrivacyLink => 'Datenschutzerklärung';

  @override
  String get loginLegalSuffix => ' zu.';

  @override
  String get settingsSectionAccount => 'Konto';

  @override
  String get settingsLogin => 'Anmelden';

  @override
  String get settingsLoginSubtitle => 'Anmelden, um KI-Funktionen zu nutzen';

  @override
  String get settingsSectionCredits => 'Credits & Abonnement';

  @override
  String get settingsCreditsSubtitle => 'KI-Audio-Credits und Pläne verwalten';

  @override
  String get settingsLogout => 'Abmelden';

  @override
  String get settingsLogoutDialogTitle => 'Abmelden';

  @override
  String get settingsLogoutDialogContent =>
      'Möchtest du dich wirklich abmelden?';

  @override
  String get settingsSectionLegal => 'Rechtliches';

  @override
  String get settingsTermsSubtitle => 'Nutzungsbedingungen anzeigen';

  @override
  String get settingsPrivacySubtitle => 'Wie wir mit deinen Daten umgehen';

  @override
  String get creditsTitle => 'Credits';

  @override
  String get creditsDailyFree => 'Heutiges Freikontingent';

  @override
  String get creditsMinRemaining => 'Min. verbleibend';

  @override
  String get creditsDailyResets => 'Wird um Mitternacht zurückgesetzt';

  @override
  String get creditsPurchasedCredits => 'Gekaufte Credits';

  @override
  String get creditsMinutes => 'Min.';

  @override
  String get creditsSubscriptionActive => 'Abonnement aktiv';

  @override
  String get creditsSubscriptionsTitle => 'Abonnementpläne';

  @override
  String get creditsMostPopular => 'Beliebt';

  @override
  String get creditsPerMonth => '/ Monat';

  @override
  String get creditPacksTitle => 'Credit-Pakete';

  @override
  String get creditPacksSubtitle => 'Einmaliger Kauf, kein Ablaufdatum';

  @override
  String get creditsLoadError =>
      'Credit-Informationen konnten nicht geladen werden.';

  @override
  String get creditsPaymentComingSoon => 'Zahlungssystem demnächst verfügbar';

  @override
  String get termsTitle => 'Nutzungsbedingungen';

  @override
  String get termsLastUpdated => 'Zuletzt aktualisiert: März 2025';

  @override
  String get termsSec1Title => '1. Dienstübersicht';

  @override
  String get termsSec1Body =>
      'LingoNexus ist eine KI-gestützte Sprachlernplattform. Diese Bedingungen regeln die Nutzung des Dienstes.';

  @override
  String get termsSec2Title => '2. Konto & Authentifizierung';

  @override
  String get termsSec2Body =>
      'Du musst dich mit einem Google-Konto anmelden, um KI-Funktionen zu nutzen. Du bist für die Sicherheit deines Kontos verantwortlich.';

  @override
  String get termsSec3Title => '3. Credits & Zahlung';

  @override
  String get termsSec3Body =>
      'Die KI-Audioverarbeitung verbraucht Credits. Täglich werden 3 Minuten kostenlos zur Verfügung gestellt. Gekaufte Credits sind nicht erstattungsfähig.';

  @override
  String get termsSec4Title => '4. Nutzungsbeschränkungen';

  @override
  String get termsSec4Body =>
      'Missbrauch des Dienstes oder übermäßige automatisierte Nutzung ist verboten. Limit von 10 Minuten pro Upload.';

  @override
  String get termsSec5Title => '5. Geistiges Eigentum';

  @override
  String get termsSec5Body =>
      'Das Urheberrecht an hochgeladenen Inhalten liegt beim Nutzer. KI-Ergebnisse dienen nur als Referenz.';

  @override
  String get termsSec6Title => '6. Haftungsausschluss';

  @override
  String get termsSec6Body =>
      'Wir garantieren nicht die Genauigkeit der KI-Ergebnisse. Bedingungen können sich mit vorheriger Ankündigung ändern.';

  @override
  String get privacyTitle => 'Datenschutzerklärung';

  @override
  String get privacyLastUpdated => 'Zuletzt aktualisiert: März 2025';

  @override
  String get privacySec1Title => '1. Gesammelte Informationen';

  @override
  String get privacySec1Body =>
      'Bei der Google-Anmeldung erfassen wir E-Mail, Name und Profilfoto. Audiodaten werden nicht auf unseren Servern gespeichert.';

  @override
  String get privacySec2Title => '2. Verwendung deiner Informationen';

  @override
  String get privacySec2Body =>
      'Informationen werden ausschließlich für die Diensterbringung und das Credit-Management verwendet. Wir verkaufen keine persönlichen Daten.';

  @override
  String get privacySec3Title => '3. Datensicherheit';

  @override
  String get privacySec3Body =>
      'Authentifizierungstoken werden im verschlüsselten Gerätespeicher gespeichert. Serverdaten werden verschlüsselt gespeichert.';

  @override
  String get privacySec4Title => '4. Drittanbieterdienste';

  @override
  String get privacySec4Body =>
      'Wir nutzen Google Sign-In, Google Gemini API und Alibaba Qwen API.';

  @override
  String get privacySec5Title => '5. Deine Rechte';

  @override
  String get privacySec5Body =>
      'Du kannst jederzeit die Löschung deines Kontos beantragen. Kontakt: support@lingonexus.app';

  @override
  String get syncNoiseWarning =>
      'Hintergrundgeräusche können die Transkriptionsgenauigkeit verringern. Verwenden Sie in einer ruhigen Umgebung aufgenommenes Audio.';

  @override
  String get syncTranslationLanguage => 'Übersetzungssprache';

  @override
  String get syncAudioLanguage => 'Audiosprache';

  @override
  String get syncAnnotating => 'Lautschrift und Übersetzung werden generiert…';

  @override
  String syncScriptSaved(Object count) {
    return '$count Sätze synchronisiert! Skript gespeichert.';
  }

  @override
  String get shadowingAttempt => 'Versuch';

  @override
  String shadowingRetry(int current, int max) {
    return 'Erneut aufnehmen ($current/$max)';
  }

  @override
  String get shadowingBestScore => 'Beste Punktzahl';

  @override
  String get shadowingNewSession => 'Neue Sitzung';

  @override
  String shadowingAttemptCount(int max) {
    return 'Maximale Versuche erreicht ($max)';
  }

  @override
  String get urlImportTitle => 'Von URL importieren';

  @override
  String get urlImportHint => 'YouTube-, Podcast-URL einfügen';

  @override
  String get urlImportButton => 'Importieren';

  @override
  String get urlImportDownloading => 'Herunterladen...';

  @override
  String get urlImportSuccess => 'Import abgeschlossen';

  @override
  String get urlImportFailed => 'Import fehlgeschlagen';

  @override
  String get sampleContentLoad => 'Beispielinhalte laden';

  @override
  String get autoSplitSave => 'Automatisch teilen & speichern';

  @override
  String get waveformLoading => 'Wellenform wird geladen...';

  @override
  String get podcastTitle => 'Podcasts';

  @override
  String get podcastAddFeed => 'Feed hinzufügen';

  @override
  String get podcastFeedUrl => 'RSS-Feed-URL';

  @override
  String get podcastSubscribe => 'Abonnieren';

  @override
  String get podcastEpisodes => 'Episoden';

  @override
  String get podcastDownload => 'Herunterladen';

  @override
  String get podcastAddToLibrary => 'Zur Bibliothek hinzufügen';

  @override
  String get podcastNoFeeds => 'Keine abonnierten Podcasts';

  @override
  String get statsTitle => 'Lernstatistiken';

  @override
  String get statsTotalSessions => 'Gesamtsitzungen';

  @override
  String get statsMastered => 'Gemeisterte Sätze';

  @override
  String get statsStreak => 'Lernserie';

  @override
  String get statsRecentScores => 'Letzte Aussprache-Scores';

  @override
  String get statsDailyGoal => 'Tagesziel';

  @override
  String get statsDailyGoalDone => 'Ziel erreicht!';

  @override
  String get statsLanguageDist => 'Sprachverteilung';
}
