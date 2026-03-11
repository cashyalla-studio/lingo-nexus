// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Scripta Sync';

  @override
  String get welcomeBack => '¡Bienvenido de nuevo!';

  @override
  String get readyToMaster => '¿Listo para dominar otro idioma hoy?';

  @override
  String get continueStudying => 'Continuar estudiando';

  @override
  String get myRecentActivity => 'Mi actividad reciente';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get home => 'Inicio';

  @override
  String get library => 'Biblioteca';

  @override
  String get stats => 'Estadísticas';

  @override
  String get settings => 'Ajustes';

  @override
  String get getStarted => 'Empezar';

  @override
  String get importContent => 'Importar contenido';

  @override
  String get aiSyncAnalyze => 'Sincronización y análisis AI';

  @override
  String get immersiveStudy => 'Estudio inmersivo';

  @override
  String get importDescription =>
      'Importa fácilmente tus archivos de audio y guiones de texto.';

  @override
  String get aiSyncDescription =>
      'La IA analiza las frases y las sincroniza perfectamente con el audio.';

  @override
  String get immersiveDescription =>
      'Mejora tus habilidades lingüísticas en un reproductor inmersivo.';

  @override
  String get selectedSentence => 'Frase seleccionada';

  @override
  String get aiGrammarAnalysis => 'Análisis gramatical AI';

  @override
  String get vocabularyHelper => 'Ayuda de vocabulario';

  @override
  String get shadowingStudio => 'Estudio de Shadowing';

  @override
  String get aiAutoSync => 'Sincronización automática AI';

  @override
  String get syncDescription =>
      'Alinea tu guión de texto con el audio sin esfuerzo usando Scripta Sync AI.';

  @override
  String get startAutoSync => 'Iniciar sincronización (1 crédito)';

  @override
  String get buyCredits => 'Comprar créditos';

  @override
  String get useOwnApiKey => 'O usa tu propia clave API (BYOK)';

  @override
  String get shadowingNativeSpeaker => 'Hablante nativo';

  @override
  String get shadowingYourTurn => 'Tu turno';

  @override
  String get listening => 'Escuchando...';

  @override
  String get accuracy => 'Precisión';

  @override
  String get intonation => 'Entonación';

  @override
  String get fluency => 'Fluidez';

  @override
  String get syncCompleted => '¡Sincronización completada!';

  @override
  String get noContentFound =>
      'No se encontró contenido. Toca el icono de la carpeta.';

  @override
  String get selectFile => 'Selecciona un archivo';

  @override
  String get noScriptFile => 'No se encontró el archivo de guión.';

  @override
  String get noScriptHint =>
      'Agrega un archivo .txt con el mismo nombre que el audio en la misma carpeta.';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get settingsSectionAiProvider => 'Proveedor de IA';

  @override
  String get settingsApiKeyManage => 'Administrar claves API';

  @override
  String get settingsSectionSubscription => 'Suscripción';

  @override
  String get settingsProPlanActive => 'Plan Pro activo';

  @override
  String get settingsFreePlan => 'Plan gratuito';

  @override
  String get settingsProPlanSubtitle => 'Todas las funciones ilimitadas';

  @override
  String get settingsFreePlanSubtitle =>
      '20 usos de IA/mes, 10 sesiones de pronunciación/mes';

  @override
  String get settingsSectionData => 'Datos';

  @override
  String get settingsRescanLibrary => 'Volver a escanear la biblioteca';

  @override
  String get settingsRescanSubtitle => 'Busca nuevos archivos en el directorio';

  @override
  String get settingsResetData => 'Restablecer datos de aprendizaje';

  @override
  String get settingsResetSubtitle =>
      'Elimina todo el progreso y los registros';

  @override
  String get settingsResetDialogTitle => 'Restablecer registros';

  @override
  String get settingsResetDialogContent =>
      'Se eliminarán todos los registros y el progreso de aprendizaje. ¿Continuar?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get settingsResetSuccess =>
      'Todos los registros han sido restablecidos.';

  @override
  String get settingsSectionCache => 'Gestión de caché';

  @override
  String get settingsCacheDriveDownload => 'Descargas de Google Drive';

  @override
  String get settingsClearAllCache => 'Borrar todo el caché';

  @override
  String get settingsClearCacheSubtitle =>
      'Eliminar archivos descargados de Google Drive y archivos temporales';

  @override
  String get settingsCacheDeleteDialogTitle => 'Eliminar caché';

  @override
  String settingsCacheDeleteDialogContent(String size) {
    return 'Se eliminará $size de caché.';
  }

  @override
  String get settingsCacheDeleteSuccess => 'Caché eliminado.';

  @override
  String get settingsAppLanguage => 'Idioma de la app';

  @override
  String get settingsAppLanguageTitle => 'Seleccionar idioma de la app';

  @override
  String get settingsSystemDefault => 'Predeterminado del sistema';

  @override
  String get settingsSystemDefaultSubtitle => 'Sigue el idioma del dispositivo';

  @override
  String homeStreakActive(int days) {
    return '¡$days días seguidos!';
  }

  @override
  String homeStreakStats(int longest, int total) {
    return 'Mejor: $longest días · Total: $total días';
  }

  @override
  String get homeEmptyLibrary =>
      'Agrega archivos de la biblioteca para empezar a estudiar.';

  @override
  String get homeNoHistory => 'Aún no hay historial de estudio.';

  @override
  String get homeStatusDone => 'Completado';

  @override
  String get homeStatusStudying => 'Estudiando';

  @override
  String homeDueReview(int count) {
    return '$count oraciones para repasar hoy';
  }

  @override
  String get homeNoDueReview => 'No hay oraciones para repasar';

  @override
  String get homeAiConversation => 'Práctica de conversación con IA';

  @override
  String get homeAiConversationSubtitle =>
      'Conversa libremente con una IA de nivel nativo';

  @override
  String get homePhoneticsHub => 'Centro de entrenamiento de pronunciación';

  @override
  String get homePhoneticsHubSubtitle =>
      'TTS + puntuación en dispositivo · Sin API necesaria';

  @override
  String get tutorialSkip => 'Saltar';

  @override
  String get tutorialStart => '¡Empezar! 🚀';

  @override
  String get tutorialNext => 'Siguiente';

  @override
  String get playerClipEdit => 'Editar clip';

  @override
  String get playerSpeedSuggestion =>
      '¡Escuchaste más del 70%! ¿Aumentar la velocidad? 🚀';

  @override
  String get playerSpeedIncrease => 'Aumentar';

  @override
  String get playerMenuDictation => 'Práctica de dictado';

  @override
  String get playerSelectFileFirst => 'Selecciona primero un archivo de audio.';

  @override
  String get playerMenuActiveRecall => 'Entrenamiento de recuperación activa';

  @override
  String get playerMenuBookmark => 'Guardar marcador';

  @override
  String get playerBookmarkSaved => '¡Marcador guardado!';

  @override
  String get playerBookmarkDuplicate => 'Esta oración ya está marcada.';

  @override
  String get playerBeginnerMode => 'Modo principiante (0.75x)';

  @override
  String get playerLoopOff => 'Sin repetición';

  @override
  String get playerLoopOne => 'Repetir uno';

  @override
  String get playerLoopAll => 'Repetir todo';

  @override
  String get playerScriptReady => 'Guion listo';

  @override
  String get playerNoScript => 'Sin guion';

  @override
  String playerAbLoopASet(String time) {
    return 'A: $time — B no configurado';
  }

  @override
  String playerError(String error) {
    return 'Error: $error';
  }

  @override
  String get conversationTopicSuggest => 'Sugerir tema';

  @override
  String conversationInputHint(String language) {
    return 'Habla en $language...';
  }

  @override
  String conversationPracticeTitle(String language) {
    return 'Práctica de conversación en $language';
  }

  @override
  String get conversationWelcomeMsg =>
      'Conversa libremente con una IA de nivel nativo.\n¡No temas cometer errores!';

  @override
  String get conversationStartBtn => 'Iniciar conversación';

  @override
  String get conversationTopicExamples => 'Temas de ejemplo';

  @override
  String get statsStudiedContent => 'Contenido estudiado';

  @override
  String statsItemCount(int count) {
    return '$count elementos';
  }

  @override
  String get statsTotalTime => 'Tiempo total de estudio';

  @override
  String statsMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get statsNoHistory =>
      'Aún no hay historial de estudio.\nAgrega contenido desde la biblioteca.';

  @override
  String get statsProgressByItem => 'Progreso por elemento';

  @override
  String get statsPronunciationProgress => 'Mejora de pronunciación';

  @override
  String get statsPronunciationEmpty =>
      'Completa sesiones de shadowing para ver tu mejora de pronunciación aquí.';

  @override
  String statsPracticeCount(int count) {
    return '$count sesiones';
  }

  @override
  String get statsStreakSection => 'Racha de estudio';

  @override
  String get statsStreakCurrentLabel => 'Racha actual';

  @override
  String get statsStreakLongestLabel => 'Racha más larga';

  @override
  String get statsStreakTotalLabel => 'Días totales';

  @override
  String statsDays(int days) {
    return '$days días';
  }

  @override
  String get statsJournal => 'Diario de estudio';

  @override
  String get statsJournalEmpty =>
      'Tu diario se registrará automáticamente cuando comiences a estudiar.';

  @override
  String get statsShareCard => 'Compartir tarjeta de estudio';

  @override
  String get statsShareSubtitle =>
      'Comparte tus logros de aprendizaje en redes sociales';

  @override
  String get statsMinimalPair => 'Entrenamiento de pares mínimos';

  @override
  String get statsMinimalPairSubtitle =>
      'Distinguir sonidos similares (EN/JA/ES)';

  @override
  String statsError(String error) {
    return 'Error: $error';
  }

  @override
  String get phoneticsHubFreeTitle => 'Entrenamiento de pronunciación sin IA';

  @override
  String get phoneticsHubFreeSubtitle =>
      'TTS del dispositivo + reconocimiento de voz\nGratis sin clave API';

  @override
  String get phoneticsHubTrainingTools => 'Herramientas de entrenamiento';

  @override
  String get phoneticsComingSoon => 'Próximamente';

  @override
  String get phoneticsSpanishIpa => 'IPA español';

  @override
  String get phoneticsSpanishIpaSubtitle =>
      'Símbolos fonéticos español + práctica (próximamente)';

  @override
  String get apiKeyRequired => 'Por favor, ingresa al menos una clave API.';

  @override
  String get apiKeyInvalidFormat =>
      'Formato de clave API de OpenAI no válido. (debe comenzar con sk-)';

  @override
  String get apiKeySaved => 'Clave API guardada de forma segura.';

  @override
  String get libraryNewPlaylist => 'Nueva lista de reproducción';

  @override
  String get libraryImport => 'Importar';

  @override
  String get libraryAllTab => 'Todo';

  @override
  String get libraryLocalSource => 'Local';

  @override
  String get libraryNoScript => 'Sin guión';

  @override
  String get libraryUnsetLanguage => 'Sin establecer';

  @override
  String get libraryEmptyPlaylist => 'Aún no hay listas de reproducción.';

  @override
  String get libraryCreatePlaylist => 'Crear nueva lista de reproducción';

  @override
  String libraryTrackCount(int count) {
    return '$count pistas';
  }

  @override
  String libraryMoreTracks(int count) {
    return '+ $count más';
  }

  @override
  String get libraryEditNameEmoji => 'Editar nombre/emoji';

  @override
  String get libraryDeletePlaylist => 'Eliminar';

  @override
  String get libraryEditPlaylist => 'Editar lista de reproducción';

  @override
  String get librarySetLanguage => 'Establecer idioma';

  @override
  String libraryChangeLanguage(String lang) {
    return 'Cambiar idioma (actual: $lang)';
  }

  @override
  String get libraryAddToPlaylist => 'Agregar a la lista de reproducción';

  @override
  String get libraryLanguageBadge => 'Insignia de idioma';

  @override
  String get phoneticsQuizTitle => 'Quiz de pronunciación';

  @override
  String get phoneticsQuizDesc =>
      'Quiz de IPA ↔ coincidencia de palabras\nBono de racha + estadísticas de precisión';

  @override
  String get phoneticsTtsPracticeTitle => 'Práctica de pronunciación TTS';

  @override
  String get phoneticsTtsPracticeDesc =>
      'Escucha palabras y repite con símbolos IPA\nSin clave API · Completamente gratis';

  @override
  String get phoneticsMinimalPairDesc =>
      'Distinguir sonidos similares (ship vs sheep etc.)\nEscucha TTS + puntuación de pronunciación';

  @override
  String get phoneticsPitchAccentTitle => 'Acento de tono japonés';

  @override
  String get phoneticsPitchAccentDesc =>
      'Entrena patrones de tono para homófonos\nej. はし (palillos/puente/borde)';

  @override
  String get phoneticsKanaDrillTitle => 'Ejercicio de Hiragana · Katakana';

  @override
  String get phoneticsKanaDrillDesc =>
      'Toca cualquier carácter kana para escuchar la pronunciación TTS\nTabla completa de 50 sonidos incluida';

  @override
  String get libraryPlaylistTab => 'Listas de reproducción';

  @override
  String get importTitle => 'Importar';

  @override
  String get importFromDevice => 'Importar desde este dispositivo';

  @override
  String get importFromDeviceSubtitle =>
      'Cargar audio + scripts desde una carpeta local';

  @override
  String get importFromICloud => 'Importar desde iCloud Drive';

  @override
  String get importFromICloudSubtitle =>
      'Vincular carpeta de iCloud Drive a la biblioteca';

  @override
  String get importFromGoogleDrive => 'Importar desde Google Drive';

  @override
  String get importFromGoogleDriveSubtitle =>
      'Explorar y descargar una carpeta de Google Drive';

  @override
  String get importAutoSync =>
      'Sincronización automática de carpeta Scripta Sync iCloud';

  @override
  String get importAutoSyncSubtitle =>
      'Escaneo automático de la carpeta iCloud Drive/Scripta Sync/';

  @override
  String heatmapTitle(int weeks) {
    return 'Registro de estudio (últimas $weeks semanas)';
  }

  @override
  String heatmapTooltip(String date, int minutes) {
    return '$date: $minutes min';
  }

  @override
  String get heatmapNoActivity => 'Sin actividad';

  @override
  String get heatmapLess => 'Menos';

  @override
  String get heatmapMore => 'Más';

  @override
  String get loginSubtitle => 'Mejora tus habilidades lingüísticas con IA';

  @override
  String get loginWithGoogle => 'Continuar con Google';

  @override
  String get loginFeatureAi =>
      'Tutor de gramática, vocabulario y conversación con IA (gratis)';

  @override
  String get loginFeaturePronunciation => 'Evaluación de pronunciación y tonos';

  @override
  String get loginFeatureSync =>
      'Sincronización automática con IA — genera guiones desde audio';

  @override
  String get loginFeatureFree =>
      '3 minutos diarios de procesamiento de audio con IA gratis';

  @override
  String get loginLegalPrefix => 'Al continuar, aceptas nuestros ';

  @override
  String get loginTermsLink => 'Términos de Servicio';

  @override
  String get loginLegalAnd => 'y la';

  @override
  String get loginPrivacyLink => 'Política de Privacidad';

  @override
  String get loginLegalSuffix => '.';

  @override
  String get settingsSectionAccount => 'Cuenta';

  @override
  String get settingsLogin => 'Iniciar sesión';

  @override
  String get settingsLoginSubtitle => 'Inicia sesión para usar funciones de IA';

  @override
  String get settingsSectionCredits => 'Créditos y Suscripción';

  @override
  String get settingsCreditsSubtitle =>
      'Gestionar créditos de audio IA y planes';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsLogoutDialogTitle => 'Cerrar sesión';

  @override
  String get settingsLogoutDialogContent =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsTermsSubtitle => 'Ver nuestros términos de servicio';

  @override
  String get settingsPrivacySubtitle => 'Cómo manejamos tus datos';

  @override
  String get creditsTitle => 'Créditos';

  @override
  String get creditsDailyFree => 'Cuota gratuita de hoy';

  @override
  String get creditsMinRemaining => 'min restantes';

  @override
  String get creditsDailyResets => 'Se restablece a medianoche';

  @override
  String get creditsPurchasedCredits => 'Créditos comprados';

  @override
  String get creditsMinutes => 'min';

  @override
  String get creditsSubscriptionActive => 'suscripción activa';

  @override
  String get creditsSubscriptionsTitle => 'Planes de suscripción';

  @override
  String get creditsMostPopular => 'Popular';

  @override
  String get creditsPerMonth => '/ mes';

  @override
  String get creditPacksTitle => 'Paquetes de créditos';

  @override
  String get creditPacksSubtitle => 'Compra única, sin caducidad';

  @override
  String get creditsLoadError =>
      'No se pudo cargar la información de créditos.';

  @override
  String get creditsPaymentComingSoon => 'Sistema de pago próximamente';

  @override
  String get termsTitle => 'Términos de Servicio';

  @override
  String get termsLastUpdated => 'Última actualización: marzo de 2025';

  @override
  String get termsSec1Title => '1. Descripción del servicio';

  @override
  String get termsSec1Body =>
      'LingoNexus es una plataforma de aprendizaje de idiomas con IA. Estos términos rigen el uso del servicio.';

  @override
  String get termsSec2Title => '2. Cuenta y autenticación';

  @override
  String get termsSec2Body =>
      'Debes iniciar sesión con una cuenta de Google para usar las funciones de IA. Eres responsable de la seguridad de tu cuenta.';

  @override
  String get termsSec3Title => '3. Créditos y pago';

  @override
  String get termsSec3Body =>
      'El procesamiento de audio con IA consume créditos. Se proporcionan 3 minutos gratuitos diariamente. Los créditos comprados no son reembolsables.';

  @override
  String get termsSec4Title => '4. Restricciones de uso';

  @override
  String get termsSec4Body =>
      'Se prohíbe el abuso del servicio o el uso automatizado excesivo. Límite de 10 minutos por carga.';

  @override
  String get termsSec5Title => '5. Propiedad intelectual';

  @override
  String get termsSec5Body =>
      'El copyright del contenido subido pertenece al usuario. Los resultados de IA son solo de referencia.';

  @override
  String get termsSec6Title => '6. Aviso legal';

  @override
  String get termsSec6Body =>
      'No garantizamos la exactitud de los resultados de IA. Los términos pueden cambiar con aviso previo.';

  @override
  String get privacyTitle => 'Política de Privacidad';

  @override
  String get privacyLastUpdated => 'Última actualización: marzo de 2025';

  @override
  String get privacySec1Title => '1. Información que recopilamos';

  @override
  String get privacySec1Body =>
      'Al iniciar sesión con Google, recopilamos tu correo, nombre y foto de perfil. Los datos de audio no se almacenan en nuestros servidores.';

  @override
  String get privacySec2Title => '2. Cómo usamos tu información';

  @override
  String get privacySec2Body =>
      'La información se usa exclusivamente para la prestación del servicio y la gestión de créditos. No vendemos información personal.';

  @override
  String get privacySec3Title => '3. Seguridad de datos';

  @override
  String get privacySec3Body =>
      'Los tokens de autenticación se almacenan en el almacenamiento cifrado del dispositivo. Los datos del servidor están cifrados en reposo.';

  @override
  String get privacySec4Title => '4. Servicios de terceros';

  @override
  String get privacySec4Body =>
      'Usamos Google Sign-In, Google Gemini API y Alibaba Qwen API.';

  @override
  String get privacySec5Title => '5. Tus derechos';

  @override
  String get privacySec5Body =>
      'Puedes solicitar la eliminación de tu cuenta en cualquier momento. Contacto: support@lingonexus.app';

  @override
  String get syncNoiseWarning =>
      'El ruido de fondo puede reducir la precisión de la transcripción. Use audio grabado en un ambiente silencioso.';

  @override
  String get syncTranslationLanguage => 'Idioma de traducción';

  @override
  String get syncAnnotating => 'Generando fonética y traducción…';

  @override
  String syncScriptSaved(Object count) {
    return '¡$count oraciones sincronizadas! Guión guardado.';
  }
}
