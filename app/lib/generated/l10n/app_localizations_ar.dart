// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Scripta Sync';

  @override
  String get welcomeBack => 'مرحباً بعودتك!';

  @override
  String get readyToMaster => 'هل أنت مستعد لإتقان لغة أخرى اليوم؟';

  @override
  String get continueStudying => 'مواصلة الدراسة';

  @override
  String get myRecentActivity => 'نشاطي الأخير';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get home => 'الرئيسية';

  @override
  String get library => 'المكتبة';

  @override
  String get stats => 'الإحصائيات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get importContent => 'استيراد المحتوى';

  @override
  String get aiSyncAnalyze => 'مزامنة وتحليل AI';

  @override
  String get immersiveStudy => 'دراسة غامرة';

  @override
  String get importDescription =>
      'استورد ملفاتك الصوتية ونصوصك بسهولة من جهازك.';

  @override
  String get aiSyncDescription =>
      'يقوم الذكاء الاصطناعي بتحليل الجمل ومزامنتها تماماً مع الصوت.';

  @override
  String get immersiveDescription =>
      'حسن مهاراتك اللغوية في مشغل غامر بدون تشتيت.';

  @override
  String get selectedSentence => 'الجملة المختارة';

  @override
  String get aiGrammarAnalysis => 'تحليل قواعد AI';

  @override
  String get vocabularyHelper => 'مساعد المفردات';

  @override
  String get shadowingStudio => 'استوديو الظل';

  @override
  String get aiAutoSync => 'مزامنة تلقائية AI';

  @override
  String get syncDescription =>
      'قم بمحاذاة النص مع الصوت بسهولة باستخدام ذكاء Scripta Sync.';

  @override
  String get startAutoSync => 'ابدأ المزامنة التلقائية (1 رصيد)';

  @override
  String get buyCredits => 'شراء رصيد';

  @override
  String get useOwnApiKey => 'أو استخدم مفتاح API الخاص بك (BYOK)';

  @override
  String get shadowingNativeSpeaker => 'المتحدث الأصلي';

  @override
  String get shadowingYourTurn => 'دورك';

  @override
  String get listening => 'جاري الاستماع...';

  @override
  String get accuracy => 'الدقة';

  @override
  String get intonation => 'التنغيم';

  @override
  String get fluency => 'الطلاقة';

  @override
  String get syncCompleted => 'اكتملت المزامنة التلقائية!';

  @override
  String get noContentFound =>
      'لم يتم العثور على محتوى. اضغط على أيقونة المجلد للاستيراد.';

  @override
  String get selectFile => 'اختر ملفاً';

  @override
  String get noScriptFile => 'لم يتم العثور على ملف النص.';

  @override
  String get noScriptHint => 'أضف ملف .txt بنفس اسم الصوت في نفس المجلد.';

  @override
  String get settingsSectionLanguage => 'اللغة';

  @override
  String get settingsSectionAiProvider => 'مزود الذكاء الاصطناعي';

  @override
  String get settingsApiKeyManage => 'إدارة مفاتيح API';

  @override
  String get settingsSectionSubscription => 'الاشتراك';

  @override
  String get settingsProPlanActive => 'خطة Pro نشطة';

  @override
  String get settingsFreePlan => 'الخطة المجانية';

  @override
  String get settingsProPlanSubtitle => 'جميع الميزات غير محدودة';

  @override
  String get settingsFreePlanSubtitle =>
      '20 استخداماً للذكاء الاصطناعي/شهر، 10 جلسات نطق/شهر';

  @override
  String get settingsSectionData => 'البيانات';

  @override
  String get settingsRescanLibrary => 'إعادة فحص المكتبة';

  @override
  String get settingsRescanSubtitle => 'يبحث عن ملفات جديدة في الدليل';

  @override
  String get settingsResetData => 'إعادة تعيين بيانات التعلم';

  @override
  String get settingsResetSubtitle => 'يحذف جميع التقدم والسجلات';

  @override
  String get settingsResetDialogTitle => 'إعادة تعيين السجلات';

  @override
  String get settingsResetDialogContent =>
      'سيتم حذف جميع سجلات التعلم والتقدم. هل تريد المتابعة؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get settingsResetSuccess => 'تم إعادة تعيين جميع السجلات.';

  @override
  String get settingsSectionCache => 'إدارة ذاكرة التخزين المؤقت';

  @override
  String get settingsCacheDriveDownload => 'تنزيلات Google Drive';

  @override
  String get settingsClearAllCache => 'مسح كل ذاكرة التخزين المؤقت';

  @override
  String get settingsClearCacheSubtitle =>
      'حذف ملفات Google Drive المحملة والملفات المؤقتة';

  @override
  String get settingsCacheDeleteDialogTitle => 'حذف ذاكرة التخزين المؤقت';

  @override
  String settingsCacheDeleteDialogContent(String size) {
    return 'سيتم حذف $size من ذاكرة التخزين المؤقت.';
  }

  @override
  String get settingsCacheDeleteSuccess => 'تم حذف ذاكرة التخزين المؤقت.';

  @override
  String get settingsAppLanguage => 'لغة التطبيق';

  @override
  String get settingsAppLanguageTitle => 'اختر لغة التطبيق';

  @override
  String get settingsSystemDefault => 'الافتراضي للنظام';

  @override
  String get settingsSystemDefaultSubtitle => 'يتبع لغة الجهاز';

  @override
  String homeStreakActive(int days) {
    return '$days أيام متتالية!';
  }

  @override
  String homeStreakStats(int longest, int total) {
    return 'الأفضل: $longest أيام · الإجمالي: $total أيام';
  }

  @override
  String get homeEmptyLibrary => 'أضف ملفات من المكتبة لبدء التعلم.';

  @override
  String get homeNoHistory => 'لا يوجد سجل دراسة بعد.';

  @override
  String get homeStatusDone => 'مكتمل';

  @override
  String get homeStatusStudying => 'قيد الدراسة';

  @override
  String homeDueReview(int count) {
    return '$count جمل للمراجعة اليوم';
  }

  @override
  String get homeNoDueReview => 'لا توجد جمل للمراجعة';

  @override
  String get homeAiConversation => 'ممارسة المحادثة مع الذكاء الاصطناعي';

  @override
  String get homeAiConversationSubtitle =>
      'تحدث بحرية مع ذكاء اصطناعي بمستوى المتحدث الأصلي';

  @override
  String get homePhoneticsHub => 'مركز تدريب النطق';

  @override
  String get homePhoneticsHubSubtitle =>
      'TTS + تسجيل النقاط على الجهاز · لا حاجة لـ API';

  @override
  String get tutorialSkip => 'تخطي';

  @override
  String get tutorialStart => 'ابدأ 🚀';

  @override
  String get tutorialNext => 'التالي';

  @override
  String get playerClipEdit => 'تعديل المقطع';

  @override
  String get playerSpeedSuggestion =>
      'لقد استمعت لأكثر من 70%! هل تجرب زيادة السرعة؟ 🚀';

  @override
  String get playerSpeedIncrease => 'زيادة';

  @override
  String get playerMenuDictation => 'تمرين الإملاء';

  @override
  String get playerSelectFileFirst => 'يرجى اختيار ملف صوتي أولاً.';

  @override
  String get playerMenuActiveRecall => 'تدريب الاسترجاع النشط';

  @override
  String get playerMenuBookmark => 'حفظ الإشارة المرجعية';

  @override
  String get playerBookmarkSaved => 'تم حفظ الإشارة المرجعية!';

  @override
  String get playerBookmarkDuplicate => 'هذه الجملة محفوظة بالفعل.';

  @override
  String get playerBeginnerMode => 'وضع المبتدئ (0.75x)';

  @override
  String get playerLoopOff => 'بدون تكرار';

  @override
  String get playerLoopOne => 'تكرار واحد';

  @override
  String get playerLoopAll => 'تكرار الكل';

  @override
  String get playerScriptReady => 'النص جاهز';

  @override
  String get playerNoScript => 'لا يوجد نص';

  @override
  String playerAbLoopASet(String time) {
    return 'A: $time — B غير محدد';
  }

  @override
  String playerError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get conversationTopicSuggest => 'اقتراح موضوع';

  @override
  String conversationInputHint(String language) {
    return 'تحدث بالـ $language...';
  }

  @override
  String conversationPracticeTitle(String language) {
    return 'تمرين محادثة $language';
  }

  @override
  String get conversationWelcomeMsg =>
      'تحدث بحرية مع ذكاء اصطناعي بمستوى المتحدث الأصلي.\nلا تخف من ارتكاب الأخطاء!';

  @override
  String get conversationStartBtn => 'بدء المحادثة';

  @override
  String get conversationTopicExamples => 'أمثلة على الموضوعات';

  @override
  String get statsStudiedContent => 'المحتوى المدروس';

  @override
  String statsItemCount(int count) {
    return '$count عناصر';
  }

  @override
  String get statsTotalTime => 'إجمالي وقت الدراسة';

  @override
  String statsMinutes(int minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get statsNoHistory =>
      'لا يوجد سجل دراسة بعد.\nأضف محتوى من المكتبة للبدء.';

  @override
  String get statsProgressByItem => 'التقدم حسب العنصر';

  @override
  String get statsPronunciationProgress => 'تحسين النطق';

  @override
  String get statsPronunciationEmpty =>
      'أكمل جلسات المحاكاة لرؤية تحسن نطقك هنا.';

  @override
  String statsPracticeCount(int count) {
    return '$count جلسات';
  }

  @override
  String get statsStreakSection => 'سلسلة الدراسة';

  @override
  String get statsStreakCurrentLabel => 'السلسلة الحالية';

  @override
  String get statsStreakLongestLabel => 'أطول سلسلة';

  @override
  String get statsStreakTotalLabel => 'إجمالي الأيام';

  @override
  String statsDays(int days) {
    return '$days أيام';
  }

  @override
  String get statsJournal => 'يوميات الدراسة';

  @override
  String get statsJournalEmpty =>
      'سيتم تسجيل يوميات الدراسة تلقائيًا بمجرد البدء.';

  @override
  String get statsShareCard => 'مشاركة بطاقة الدراسة';

  @override
  String get statsShareSubtitle =>
      'شارك إنجازات تعلمك على وسائل التواصل الاجتماعي';

  @override
  String get statsMinimalPair => 'تدريب الأزواج الصغيرة';

  @override
  String get statsMinimalPairSubtitle => 'تمييز الأصوات المتشابهة (EN/JA/ES)';

  @override
  String statsError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get phoneticsHubFreeTitle => 'تدريب النطق بدون ذكاء اصطناعي';

  @override
  String get phoneticsHubFreeSubtitle =>
      'TTS للجهاز + التعرف على الكلام\nمجاني بدون مفتاح API';

  @override
  String get phoneticsHubTrainingTools => 'أدوات التدريب';

  @override
  String get phoneticsComingSoon => 'قريبًا';

  @override
  String get phoneticsSpanishIpa => 'IPA الإسبانية';

  @override
  String get phoneticsSpanishIpaSubtitle =>
      'رموز صوتية إسبانية + تمرين (قريبًا)';

  @override
  String get apiKeyRequired => 'يرجى إدخال مفتاح API واحد على الأقل.';

  @override
  String get apiKeyInvalidFormat =>
      'تنسيق مفتاح OpenAI API غير صحيح. (يجب أن يبدأ بـ sk-)';

  @override
  String get apiKeySaved => 'تم حفظ مفتاح API بأمان.';

  @override
  String get libraryNewPlaylist => 'قائمة تشغيل جديدة';

  @override
  String get libraryImport => 'استيراد';

  @override
  String get libraryAllTab => 'الكل';

  @override
  String get libraryLocalSource => 'محلي';

  @override
  String get libraryNoScript => 'بدون نص';

  @override
  String get libraryUnsetLanguage => 'غير محدد';

  @override
  String get libraryEmptyPlaylist => 'لا توجد قوائم تشغيل بعد.';

  @override
  String get libraryCreatePlaylist => 'إنشاء قائمة تشغيل جديدة';

  @override
  String libraryTrackCount(int count) {
    return '$count مقاطع';
  }

  @override
  String libraryMoreTracks(int count) {
    return '+ $count أكثر';
  }

  @override
  String get libraryEditNameEmoji => 'تعديل الاسم/الرمز التعبيري';

  @override
  String get libraryDeletePlaylist => 'حذف';

  @override
  String get libraryEditPlaylist => 'تعديل قائمة التشغيل';

  @override
  String get librarySetLanguage => 'تعيين اللغة';

  @override
  String libraryChangeLanguage(String lang) {
    return 'تغيير اللغة (الحالية: $lang)';
  }

  @override
  String get libraryAddToPlaylist => 'إضافة إلى قائمة التشغيل';

  @override
  String get libraryLanguageBadge => 'شارة اللغة';

  @override
  String get phoneticsQuizTitle => 'اختبار النطق';

  @override
  String get phoneticsQuizDesc =>
      'اختبار IPA ↔ مطابقة الكلمات\nمكافأة السلسلة + إحصائيات الدقة';

  @override
  String get phoneticsTtsPracticeTitle => 'ممارسة النطق TTS';

  @override
  String get phoneticsTtsPracticeDesc =>
      'استمع إلى كلمات وكررها مع رموز IPA\nلا حاجة لمفتاح API · مجاني تمامًا';

  @override
  String get phoneticsMinimalPairDesc =>
      'تمييز الأصوات المتشابهة (ship vs sheep إلخ)\nاستماع TTS + تسجيل النطق';

  @override
  String get phoneticsPitchAccentTitle => 'لهجة نبرة اليابانية';

  @override
  String get phoneticsPitchAccentDesc =>
      'تصور أنماط النبرة للمترادفات الصوتية\nمثال: はし (عيدان/جسر/حافة)';

  @override
  String get phoneticsKanaDrillTitle => 'تمرين الهيراغانا والكاتاكانا';

  @override
  String get phoneticsKanaDrillDesc =>
      'اضغط على أي حرف كانا لسماع نطق TTS\nيتضمن جدول 50 صوتًا كاملًا';

  @override
  String get libraryPlaylistTab => 'قوائم التشغيل';

  @override
  String get importTitle => 'استيراد';

  @override
  String get importFromDevice => 'الاستيراد من هذا الجهاز';

  @override
  String get importFromDeviceSubtitle => 'تحميل الصوت + النصوص من مجلد محلي';

  @override
  String get importFromICloud => 'الاستيراد من iCloud Drive';

  @override
  String get importFromICloudSubtitle => 'ربط مجلد iCloud Drive بالمكتبة';

  @override
  String get importFromGoogleDrive => 'الاستيراد من Google Drive';

  @override
  String get importFromGoogleDriveSubtitle => 'تصفح مجلد Google Drive وتنزيله';

  @override
  String get importAutoSync => 'المزامنة التلقائية لمجلد Scripta Sync iCloud';

  @override
  String get importAutoSyncSubtitle =>
      'المسح التلقائي لمجلد iCloud Drive/Scripta Sync/';

  @override
  String heatmapTitle(int weeks) {
    return 'سجل الدراسة (آخر $weeks أسابيع)';
  }

  @override
  String heatmapTooltip(String date, int minutes) {
    return '$date: $minutes دقيقة';
  }

  @override
  String get heatmapNoActivity => 'لا نشاط';

  @override
  String get heatmapLess => 'أقل';

  @override
  String get heatmapMore => 'أكثر';

  @override
  String get loginSubtitle => 'طوّر مهاراتك اللغوية بالذكاء الاصطناعي';

  @override
  String get loginWithGoogle => 'المتابعة مع Google';

  @override
  String get loginFeatureAi =>
      'مدرّس ذكاء اصطناعي للقواعد والمفردات والمحادثة (مجاني)';

  @override
  String get loginFeaturePronunciation => 'تقييم النطق والنبرة';

  @override
  String get loginFeatureSync =>
      'مزامنة تلقائية بالذكاء الاصطناعي — إنشاء نصوص من الصوت';

  @override
  String get loginFeatureFree =>
      '3 دقائق مجانية يومياً لمعالجة الصوت بالذكاء الاصطناعي';

  @override
  String get loginLegalPrefix => 'بالمتابعة، توافق على ';

  @override
  String get loginTermsLink => 'شروط الخدمة';

  @override
  String get loginLegalAnd => 'و';

  @override
  String get loginPrivacyLink => 'سياسة الخصوصية';

  @override
  String get loginLegalSuffix => '.';

  @override
  String get settingsSectionAccount => 'الحساب';

  @override
  String get settingsLogin => 'تسجيل الدخول';

  @override
  String get settingsLoginSubtitle =>
      'سجّل الدخول لاستخدام ميزات الذكاء الاصطناعي';

  @override
  String get settingsSectionCredits => 'الرصيد والاشتراك';

  @override
  String get settingsCreditsSubtitle => 'إدارة أرصدة الصوت والخطط';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsLogoutDialogTitle => 'تسجيل الخروج';

  @override
  String get settingsLogoutDialogContent =>
      'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get settingsSectionLegal => 'القانونية';

  @override
  String get settingsTermsSubtitle => 'عرض شروط الخدمة';

  @override
  String get settingsPrivacySubtitle => 'كيف نتعامل مع بياناتك';

  @override
  String get creditsTitle => 'الرصيد';

  @override
  String get creditsDailyFree => 'الحصة المجانية اليوم';

  @override
  String get creditsMinRemaining => 'دقيقة متبقية';

  @override
  String get creditsDailyResets => 'يُعاد ضبطه منتصف الليل';

  @override
  String get creditsPurchasedCredits => 'الرصيد المشترى';

  @override
  String get creditsMinutes => 'دقيقة';

  @override
  String get creditsSubscriptionActive => 'الاشتراك نشط';

  @override
  String get creditsSubscriptionsTitle => 'خطط الاشتراك';

  @override
  String get creditsMostPopular => 'الأكثر شيوعاً';

  @override
  String get creditsPerMonth => '/ شهر';

  @override
  String get creditPacksTitle => 'حزم الرصيد';

  @override
  String get creditPacksSubtitle => 'شراء لمرة واحدة، بدون انتهاء صلاحية';

  @override
  String get creditsLoadError => 'فشل تحميل معلومات الرصيد.';

  @override
  String get creditsPaymentComingSoon => 'نظام الدفع قادم قريباً';

  @override
  String get termsTitle => 'شروط الخدمة';

  @override
  String get termsLastUpdated => 'آخر تحديث: مارس 2025';

  @override
  String get termsSec1Title => '1. نظرة عامة على الخدمة';

  @override
  String get termsSec1Body =>
      'LingoNexus منصة تعلّم اللغات بالذكاء الاصطناعي. تحكم هذه الشروط استخدامك للخدمة.';

  @override
  String get termsSec2Title => '2. الحساب والمصادقة';

  @override
  String get termsSec2Body =>
      'يجب تسجيل الدخول بحساب Google لاستخدام ميزات الذكاء الاصطناعي. أنت مسؤول عن أمان حسابك.';

  @override
  String get termsSec3Title => '3. الرصيد والدفع';

  @override
  String get termsSec3Body =>
      'معالجة الصوت بالذكاء الاصطناعي تستهلك رصيداً. يُمنح 3 دقائق مجانية يومياً. الرصيد المشترى غير قابل للاسترداد.';

  @override
  String get termsSec4Title => '4. قيود الاستخدام';

  @override
  String get termsSec4Body =>
      'يُحظر إساءة استخدام الخدمة أو الاستخدام الآلي المفرط. الحد الأقصى 10 دقائق لكل رفع.';

  @override
  String get termsSec5Title => '5. الملكية الفكرية';

  @override
  String get termsSec5Body =>
      'حقوق النشر للمحتوى المرفوع تعود للمستخدم. نتائج الذكاء الاصطناعي للإشارة فقط.';

  @override
  String get termsSec6Title => '6. إخلاء المسؤولية';

  @override
  String get termsSec6Body =>
      'لا نضمن دقة نتائج الذكاء الاصطناعي. قد تتغير الشروط مع إشعار مسبق.';

  @override
  String get privacyTitle => 'سياسة الخصوصية';

  @override
  String get privacyLastUpdated => 'آخر تحديث: مارس 2025';

  @override
  String get privacySec1Title => '1. المعلومات التي نجمعها';

  @override
  String get privacySec1Body =>
      'عند تسجيل الدخول بـ Google، نجمع بريدك الإلكتروني واسمك وصورة ملفك الشخصي. لا يتم تخزين بيانات الصوت على خوادمنا.';

  @override
  String get privacySec2Title => '2. كيف نستخدم معلوماتك';

  @override
  String get privacySec2Body =>
      'تُستخدم المعلومات فقط لتقديم الخدمة وإدارة الرصيد. لا نبيع المعلومات الشخصية.';

  @override
  String get privacySec3Title => '3. أمان البيانات';

  @override
  String get privacySec3Body =>
      'تُخزّن رموز المصادقة في التخزين المشفّر للجهاز. بيانات الخادم مشفّرة في حالة السكون.';

  @override
  String get privacySec4Title => '4. خدمات الطرف الثالث';

  @override
  String get privacySec4Body =>
      'نستخدم Google Sign-In وGoogle Gemini API وAlibaba Qwen API.';

  @override
  String get privacySec5Title => '5. حقوقك';

  @override
  String get privacySec5Body =>
      'يمكنك طلب حذف حسابك في أي وقت. التواصل: support@lingonexus.app';
}
