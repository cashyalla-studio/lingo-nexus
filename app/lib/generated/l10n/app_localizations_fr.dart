// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Scripta Sync';

  @override
  String get welcomeBack => 'Bon retour !';

  @override
  String get readyToMaster =>
      'Prêt à maîtriser une autre langue aujourd\'hui ?';

  @override
  String get continueStudying => 'Continuer l\'étude';

  @override
  String get myRecentActivity => 'Mon activité récente';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get home => 'Accueil';

  @override
  String get library => 'Bibliothèque';

  @override
  String get stats => 'Stats';

  @override
  String get settings => 'Paramètres';

  @override
  String get getStarted => 'Commencer';

  @override
  String get importContent => 'Importer du contenu';

  @override
  String get aiSyncAnalyze => 'Sync & Analyse AI';

  @override
  String get immersiveStudy => 'Étude immersive';

  @override
  String get importDescription =>
      'Importez facilement vos fichiers audio et scripts textuels.';

  @override
  String get aiSyncDescription =>
      'L\'IA analyse les phrases et les synchronise parfaitement.';

  @override
  String get immersiveDescription =>
      'Améliorez vos compétences linguistiques dans un lecteur immersif.';

  @override
  String get selectedSentence => 'Phrase sélectionnée';

  @override
  String get aiGrammarAnalysis => 'Analyse grammaticale AI';

  @override
  String get vocabularyHelper => 'Aide au vocabulaire';

  @override
  String get shadowingStudio => 'Studio de Shadowing';

  @override
  String get aiAutoSync => 'Auto-Sync AI';

  @override
  String get syncDescription =>
      'Alignez votre script avec l\'audio sans effort grâce à Scripta Sync AI.';

  @override
  String get startAutoSync => 'Démarrer l\'auto-sync (1 crédit)';

  @override
  String get buyCredits => 'Acheter des crédits';

  @override
  String get useOwnApiKey => 'Ou utilisez votre propre clé API (BYOK)';

  @override
  String get shadowingNativeSpeaker => 'Locuteur natif';

  @override
  String get shadowingYourTurn => 'À votre tour';

  @override
  String get listening => 'Écoute...';

  @override
  String get accuracy => 'Précision';

  @override
  String get intonation => 'Intonation';

  @override
  String get fluency => 'Fluidité';

  @override
  String get syncCompleted => 'Auto-sync terminée !';

  @override
  String get noContentFound =>
      'Aucun contenu trouvé. Appuyez sur l\'icône du dossier.';

  @override
  String get selectFile => 'Sélectionner un fichier';

  @override
  String get noScriptFile => 'Fichier de script introuvable.';

  @override
  String get noScriptHint =>
      'Ajoutez un fichier .txt portant le même nom que l\'audio dans le même dossier.';

  @override
  String get settingsSectionLanguage => 'Langue';

  @override
  String get settingsSectionAiProvider => 'Fournisseur IA';

  @override
  String get settingsApiKeyManage => 'Gérer les clés API';

  @override
  String get settingsSectionSubscription => 'Abonnement';

  @override
  String get settingsProPlanActive => 'Plan Pro actif';

  @override
  String get settingsFreePlan => 'Plan gratuit';

  @override
  String get settingsProPlanSubtitle => 'Toutes les fonctionnalités illimitées';

  @override
  String get settingsFreePlanSubtitle =>
      '20 utilisations IA/mois, 10 sessions de prononciation/mois';

  @override
  String get settingsSectionData => 'Données';

  @override
  String get settingsRescanLibrary => 'Rescanner la bibliothèque';

  @override
  String get settingsRescanSubtitle =>
      'Recherche de nouveaux fichiers dans le répertoire';

  @override
  String get settingsResetData => 'Réinitialiser les données d\'apprentissage';

  @override
  String get settingsResetSubtitle =>
      'Supprime tous les progrès et enregistrements';

  @override
  String get settingsResetDialogTitle => 'Réinitialiser les enregistrements';

  @override
  String get settingsResetDialogContent =>
      'Tous les enregistrements et progrès d\'apprentissage seront supprimés. Continuer ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get settingsResetSuccess =>
      'Tous les enregistrements ont été réinitialisés.';

  @override
  String get settingsSectionCache => 'Gestion du cache';

  @override
  String get settingsCacheDriveDownload => 'Téléchargements Google Drive';

  @override
  String get settingsClearAllCache => 'Effacer tout le cache';

  @override
  String get settingsClearCacheSubtitle =>
      'Supprimer les fichiers Google Drive téléchargés et les fichiers temporaires';

  @override
  String get settingsCacheDeleteDialogTitle => 'Supprimer le cache';

  @override
  String settingsCacheDeleteDialogContent(String size) {
    return '$size de cache sera supprimé.';
  }

  @override
  String get settingsCacheDeleteSuccess => 'Cache supprimé.';

  @override
  String get settingsAppLanguage => 'Langue de l\'appli';

  @override
  String get settingsAppLanguageTitle => 'Sélectionner la langue de l\'appli';

  @override
  String get settingsSystemDefault => 'Paramètre système';

  @override
  String get settingsSystemDefaultSubtitle => 'Suit la langue de l\'appareil';

  @override
  String homeStreakActive(int days) {
    return '$days jours de suite !';
  }

  @override
  String homeStreakStats(int longest, int total) {
    return 'Meilleur: $longest j · Total: $total j';
  }

  @override
  String get homeEmptyLibrary =>
      'Ajoutez des fichiers depuis la bibliothèque pour commencer.';

  @override
  String get homeNoHistory => 'Aucun historique d\'apprentissage.';

  @override
  String get homeStatusDone => 'Terminé';

  @override
  String get homeStatusStudying => 'En cours';

  @override
  String homeDueReview(int count) {
    return '$count phrases à réviser aujourd\'hui';
  }

  @override
  String get homeNoDueReview => 'Aucune phrase à réviser';

  @override
  String get homeAiConversation => 'Pratique de conversation IA';

  @override
  String get homeAiConversationSubtitle =>
      'Discutez librement avec une IA de niveau natif';

  @override
  String get homePhoneticsHub => 'Centre d\'entraînement à la prononciation';

  @override
  String get homePhoneticsHubSubtitle =>
      'TTS + notation sur l\'appareil · Pas d\'API requise';

  @override
  String get tutorialSkip => 'Passer';

  @override
  String get tutorialStart => 'Commencer 🚀';

  @override
  String get tutorialNext => 'Suivant';

  @override
  String get playerClipEdit => 'Modifier le clip';

  @override
  String get playerSpeedSuggestion =>
      'Vous avez écouté 70%+ ! Augmenter la vitesse ? 🚀';

  @override
  String get playerSpeedIncrease => 'Augmenter';

  @override
  String get playerMenuDictation => 'Pratique de dictée';

  @override
  String get playerSelectFileFirst =>
      'Veuillez d\'abord sélectionner un fichier audio.';

  @override
  String get playerMenuActiveRecall => 'Entraînement de rappel actif';

  @override
  String get playerMenuBookmark => 'Enregistrer le signet';

  @override
  String get playerBookmarkSaved => 'Signet enregistré !';

  @override
  String get playerBookmarkDuplicate =>
      'Cette phrase est déjà dans les signets.';

  @override
  String get playerBeginnerMode => 'Mode débutant (0.75x)';

  @override
  String get playerLoopOff => 'Pas de répétition';

  @override
  String get playerLoopOne => 'Répéter une';

  @override
  String get playerLoopAll => 'Tout répéter';

  @override
  String get playerScriptReady => 'Script prêt';

  @override
  String get playerNoScript => 'Pas de script';

  @override
  String playerAbLoopASet(String time) {
    return 'A : $time — B non défini';
  }

  @override
  String playerError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get conversationTopicSuggest => 'Suggérer un sujet';

  @override
  String conversationInputHint(String language) {
    return 'Parlez en $language...';
  }

  @override
  String conversationPracticeTitle(String language) {
    return 'Pratique de conversation en $language';
  }

  @override
  String get conversationWelcomeMsg =>
      'Discutez librement avec une IA de niveau natif.\nN\'ayez pas peur de faire des erreurs !';

  @override
  String get conversationStartBtn => 'Démarrer la conversation';

  @override
  String get conversationTopicExamples => 'Exemples de sujets';

  @override
  String get statsStudiedContent => 'Contenu étudié';

  @override
  String statsItemCount(int count) {
    return '$count éléments';
  }

  @override
  String get statsTotalTime => 'Temps d\'étude total';

  @override
  String statsMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get statsNoHistory =>
      'Aucun historique d\'apprentissage.\nAjoutez du contenu depuis la bibliothèque.';

  @override
  String get statsProgressByItem => 'Progression par élément';

  @override
  String get statsPronunciationProgress => 'Amélioration de la prononciation';

  @override
  String get statsPronunciationEmpty =>
      'Terminez des sessions de shadowing pour voir votre progression ici.';

  @override
  String statsPracticeCount(int count) {
    return '$count sessions';
  }

  @override
  String get statsStreakSection => 'Série d\'apprentissage';

  @override
  String get statsStreakCurrentLabel => 'Série actuelle';

  @override
  String get statsStreakLongestLabel => 'Série la plus longue';

  @override
  String get statsStreakTotalLabel => 'Jours totaux';

  @override
  String statsDays(int days) {
    return '$days jours';
  }

  @override
  String get statsJournal => 'Journal d\'apprentissage';

  @override
  String get statsJournalEmpty =>
      'Votre journal sera enregistré automatiquement dès que vous commencerez à étudier.';

  @override
  String get statsShareCard => 'Partager la carte d\'étude';

  @override
  String get statsShareSubtitle =>
      'Partagez vos réalisations d\'apprentissage sur les réseaux sociaux';

  @override
  String get statsMinimalPair => 'Entraînement aux paires minimales';

  @override
  String get statsMinimalPairSubtitle =>
      'Distinguer les sons similaires (EN/JA/ES)';

  @override
  String statsError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get phoneticsHubFreeTitle => 'Entraînement à la prononciation sans IA';

  @override
  String get phoneticsHubFreeSubtitle =>
      'TTS de l\'appareil + reconnaissance vocale\nGratuit sans clé API';

  @override
  String get phoneticsHubTrainingTools => 'Outils d\'entraînement';

  @override
  String get phoneticsComingSoon => 'Bientôt disponible';

  @override
  String get phoneticsSpanishIpa => 'IPA espagnol';

  @override
  String get phoneticsSpanishIpaSubtitle =>
      'Symboles phonétiques espagnol + pratique (bientôt)';

  @override
  String get apiKeyRequired => 'Veuillez entrer au moins une clé API.';

  @override
  String get apiKeyInvalidFormat =>
      'Format de clé API OpenAI invalide. (doit commencer par sk-)';

  @override
  String get apiKeySaved => 'Clé API enregistrée en toute sécurité.';

  @override
  String get libraryNewPlaylist => 'Nouvelle liste de lecture';

  @override
  String get libraryImport => 'Importer';

  @override
  String get libraryAllTab => 'Tout';

  @override
  String get libraryLocalSource => 'Local';

  @override
  String get libraryNoScript => 'Sans script';

  @override
  String get libraryUnsetLanguage => 'Non défini';

  @override
  String get libraryEmptyPlaylist => 'Aucune liste de lecture.';

  @override
  String get libraryCreatePlaylist => 'Créer une nouvelle liste de lecture';

  @override
  String libraryTrackCount(int count) {
    return '$count pistes';
  }

  @override
  String libraryMoreTracks(int count) {
    return '+ $count de plus';
  }

  @override
  String get libraryEditNameEmoji => 'Modifier nom/emoji';

  @override
  String get libraryDeletePlaylist => 'Supprimer';

  @override
  String get libraryEditPlaylist => 'Modifier la liste de lecture';

  @override
  String get librarySetLanguage => 'Définir la langue';

  @override
  String libraryChangeLanguage(String lang) {
    return 'Changer de langue (actuel: $lang)';
  }

  @override
  String get libraryAddToPlaylist => 'Ajouter à la liste de lecture';

  @override
  String get libraryLanguageBadge => 'Badge de langue';

  @override
  String get phoneticsQuizTitle => 'Quiz de prononciation';

  @override
  String get phoneticsQuizDesc =>
      'Quiz IPA ↔ correspondance de mots\nBonus de série + statistiques de précision';

  @override
  String get phoneticsTtsPracticeTitle => 'Pratique de prononciation TTS';

  @override
  String get phoneticsTtsPracticeDesc =>
      'Écoutez des mots et répétez avec les symboles IPA\nPas de clé API · Complètement gratuit';

  @override
  String get phoneticsMinimalPairDesc =>
      'Distinguer les sons similaires (ship vs sheep etc.)\nÉcoute TTS + notation de prononciation';

  @override
  String get phoneticsPitchAccentTitle => 'Accent de hauteur japonais';

  @override
  String get phoneticsPitchAccentDesc =>
      'Visualisez les patterns de hauteur pour les homophones\nex. はし (baguettes/pont/bord)';

  @override
  String get phoneticsKanaDrillTitle => 'Exercice Hiragana · Katakana';

  @override
  String get phoneticsKanaDrillDesc =>
      'Appuyez sur n\'importe quel caractère kana pour entendre la prononciation TTS\nTableau complet des 50 sons inclus';

  @override
  String get libraryPlaylistTab => 'Listes de lecture';

  @override
  String get importTitle => 'Importer';

  @override
  String get importFromDevice => 'Importer depuis cet appareil';

  @override
  String get importFromDeviceSubtitle =>
      'Charger audio + scripts depuis un dossier local';

  @override
  String get importFromICloud => 'Importer depuis iCloud Drive';

  @override
  String get importFromICloudSubtitle =>
      'Lier un dossier iCloud Drive à la bibliothèque';

  @override
  String get importFromGoogleDrive => 'Importer depuis Google Drive';

  @override
  String get importFromGoogleDriveSubtitle =>
      'Parcourir et télécharger un dossier Google Drive';

  @override
  String get importAutoSync =>
      'Synchronisation automatique du dossier Scripta Sync iCloud';

  @override
  String get importAutoSyncSubtitle =>
      'Scan automatique du dossier iCloud Drive/Scripta Sync/';

  @override
  String heatmapTitle(int weeks) {
    return 'Historique d\'apprentissage ($weeks dernières semaines)';
  }

  @override
  String heatmapTooltip(String date, int minutes) {
    return '$date : $minutes min';
  }

  @override
  String get heatmapNoActivity => 'Aucune activité';

  @override
  String get heatmapLess => 'Moins';

  @override
  String get heatmapMore => 'Plus';

  @override
  String get loginSubtitle =>
      'Améliorez vos compétences linguistiques avec l\'IA';

  @override
  String get loginWithGoogle => 'Continuer avec Google';

  @override
  String get loginFeatureAi =>
      'Tuteur IA en grammaire, vocabulaire et conversation (gratuit)';

  @override
  String get loginFeaturePronunciation =>
      'Évaluation de la prononciation et des tons';

  @override
  String get loginFeatureSync =>
      'Synchronisation automatique IA — générez des scripts depuis l\'audio';

  @override
  String get loginFeatureFree =>
      '3 minutes de traitement audio IA gratuit par jour';

  @override
  String get loginLegalPrefix => 'En continuant, vous acceptez nos ';

  @override
  String get loginTermsLink => 'Conditions d\'utilisation';

  @override
  String get loginLegalAnd => 'et notre';

  @override
  String get loginPrivacyLink => 'Politique de confidentialité';

  @override
  String get loginLegalSuffix => '.';

  @override
  String get settingsSectionAccount => 'Compte';

  @override
  String get settingsLogin => 'Se connecter';

  @override
  String get settingsLoginSubtitle =>
      'Connectez-vous pour utiliser les fonctions IA';

  @override
  String get settingsSectionCredits => 'Crédits et abonnement';

  @override
  String get settingsCreditsSubtitle =>
      'Gérer les crédits audio IA et les plans';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsLogoutDialogTitle => 'Se déconnecter';

  @override
  String get settingsLogoutDialogContent =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get settingsSectionLegal => 'Mentions légales';

  @override
  String get settingsTermsSubtitle => 'Voir nos conditions d\'utilisation';

  @override
  String get settingsPrivacySubtitle => 'Comment nous gérons vos données';

  @override
  String get creditsTitle => 'Crédits';

  @override
  String get creditsDailyFree => 'Quota gratuit du jour';

  @override
  String get creditsMinRemaining => 'min restantes';

  @override
  String get creditsDailyResets => 'Réinitialisé à minuit';

  @override
  String get creditsPurchasedCredits => 'Crédits achetés';

  @override
  String get creditsMinutes => 'min';

  @override
  String get creditsSubscriptionActive => 'abonnement actif';

  @override
  String get creditsSubscriptionsTitle => 'Plans d\'abonnement';

  @override
  String get creditsMostPopular => 'Populaire';

  @override
  String get creditsPerMonth => '/ mois';

  @override
  String get creditPacksTitle => 'Packs de crédits';

  @override
  String get creditPacksSubtitle => 'Achat unique, sans expiration';

  @override
  String get creditsLoadError =>
      'Échec du chargement des informations de crédit.';

  @override
  String get creditsPaymentComingSoon =>
      'Système de paiement bientôt disponible';

  @override
  String get termsTitle => 'Conditions d\'utilisation';

  @override
  String get termsLastUpdated => 'Dernière mise à jour : mars 2025';

  @override
  String get termsSec1Title => '1. Présentation du service';

  @override
  String get termsSec1Body =>
      'LingoNexus est une plateforme d\'apprentissage des langues propulsée par l\'IA. Ces conditions régissent votre utilisation du service.';

  @override
  String get termsSec2Title => '2. Compte et authentification';

  @override
  String get termsSec2Body =>
      'Vous devez vous connecter avec un compte Google pour utiliser les fonctions IA. Vous êtes responsable de la sécurité de votre compte.';

  @override
  String get termsSec3Title => '3. Crédits et paiement';

  @override
  String get termsSec3Body =>
      'Le traitement audio IA consomme des crédits. 3 minutes d\'utilisation gratuite sont fournies quotidiennement. Les crédits achetés ne sont pas remboursables.';

  @override
  String get termsSec4Title => '4. Restrictions d\'utilisation';

  @override
  String get termsSec4Body =>
      'L\'abus du service ou l\'utilisation automatisée excessive est interdit. Limite de 10 minutes par téléchargement.';

  @override
  String get termsSec5Title => '5. Propriété intellectuelle';

  @override
  String get termsSec5Body =>
      'Le droit d\'auteur du contenu téléchargé appartient à l\'utilisateur. Les résultats IA sont uniquement à titre de référence.';

  @override
  String get termsSec6Title => '6. Avertissement';

  @override
  String get termsSec6Body =>
      'Nous ne garantissons pas l\'exactitude des résultats IA. Les conditions peuvent changer avec préavis.';

  @override
  String get privacyTitle => 'Politique de confidentialité';

  @override
  String get privacyLastUpdated => 'Dernière mise à jour : mars 2025';

  @override
  String get privacySec1Title => '1. Informations collectées';

  @override
  String get privacySec1Body =>
      'Lors de la connexion avec Google, nous collectons votre e-mail, nom et photo de profil. Les données audio ne sont pas stockées sur nos serveurs.';

  @override
  String get privacySec2Title => '2. Utilisation de vos informations';

  @override
  String get privacySec2Body =>
      'Les informations sont utilisées exclusivement pour la prestation du service et la gestion des crédits. Nous ne vendons pas d\'informations personnelles.';

  @override
  String get privacySec3Title => '3. Sécurité des données';

  @override
  String get privacySec3Body =>
      'Les jetons d\'authentification sont stockés dans le stockage chiffré de l\'appareil. Les données du serveur sont chiffrées au repos.';

  @override
  String get privacySec4Title => '4. Services tiers';

  @override
  String get privacySec4Body =>
      'Nous utilisons Google Sign-In, Google Gemini API et Alibaba Qwen API.';

  @override
  String get privacySec5Title => '5. Vos droits';

  @override
  String get privacySec5Body =>
      'Vous pouvez demander la suppression de votre compte à tout moment. Contact : support@lingonexus.app';
}
