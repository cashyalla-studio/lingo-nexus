// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Scripta Sync';

  @override
  String get welcomeBack => 'Bem-vindo de volta!';

  @override
  String get readyToMaster => 'Pronto para dominar outro idioma hoje?';

  @override
  String get continueStudying => 'Continuar estudando';

  @override
  String get myRecentActivity => 'Minha atividade recente';

  @override
  String get seeAll => 'Ver tudo';

  @override
  String get home => 'Início';

  @override
  String get library => 'Biblioteca';

  @override
  String get stats => 'Estatísticas';

  @override
  String get settings => 'Configurações';

  @override
  String get getStarted => 'Começar';

  @override
  String get importContent => 'Importar conteúdo';

  @override
  String get aiSyncAnalyze => 'Sincronização e análise AI';

  @override
  String get immersiveStudy => 'Estudo imersivo';

  @override
  String get importDescription =>
      'Importe facilmente seus arquivos de áudio e roteiros de texto.';

  @override
  String get aiSyncDescription =>
      'A IA analisa as frases e as sincroniza perfeitamente com o áudio.';

  @override
  String get immersiveDescription =>
      'Melhore suas habilidades linguísticas em um reprodutor imersivo.';

  @override
  String get selectedSentence => 'Frase selecionada';

  @override
  String get aiGrammarAnalysis => 'Análise gramatical AI';

  @override
  String get vocabularyHelper => 'Ajuda de vocabulário';

  @override
  String get shadowingStudio => 'Estúdio de Shadowing';

  @override
  String get aiAutoSync => 'Sincronização automática AI';

  @override
  String get syncDescription =>
      'Alinhe seu roteiro de texto com o áudio sem esforço usando Scripta Sync AI.';

  @override
  String get startAutoSync => 'Iniciar sincronização (1 crédito)';

  @override
  String get buyCredits => 'Comprar créditos';

  @override
  String get useOwnApiKey => 'Ou use sua própria chave API (BYOK)';

  @override
  String get shadowingNativeSpeaker => 'Falante nativo';

  @override
  String get shadowingYourTurn => 'Sua vez';

  @override
  String get listening => 'Ouvindo...';

  @override
  String get accuracy => 'Precisão';

  @override
  String get intonation => 'Entonação';

  @override
  String get fluency => 'Fluência';

  @override
  String get syncCompleted => 'Sincronização concluída!';

  @override
  String get noContentFound =>
      'Nenhum conteúdo encontrado. Toque no ícone da pasta.';

  @override
  String get selectFile => 'Selecione um arquivo';

  @override
  String get noScriptFile => 'Arquivo de roteiro não encontrado.';

  @override
  String get noScriptHint =>
      'Adicione um arquivo .txt com o mesmo nome do áudio na mesma pasta.';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get settingsSectionAiProvider => 'Provedor de IA';

  @override
  String get settingsApiKeyManage => 'Gerenciar chaves API';

  @override
  String get settingsSectionSubscription => 'Assinatura';

  @override
  String get settingsProPlanActive => 'Plano Pro ativo';

  @override
  String get settingsFreePlan => 'Plano gratuito';

  @override
  String get settingsProPlanSubtitle => 'Todas as funções ilimitadas';

  @override
  String get settingsFreePlanSubtitle =>
      '20 usos de IA/mês, 10 sessões de pronúncia/mês';

  @override
  String get settingsSectionData => 'Dados';

  @override
  String get settingsRescanLibrary => 'Reescanear biblioteca';

  @override
  String get settingsRescanSubtitle => 'Pesquisa novos arquivos no diretório';

  @override
  String get settingsResetData => 'Redefinir dados de aprendizado';

  @override
  String get settingsResetSubtitle => 'Exclui todo o progresso e registros';

  @override
  String get settingsResetDialogTitle => 'Redefinir registros';

  @override
  String get settingsResetDialogContent =>
      'Todos os registros e o progresso de aprendizado serão excluídos. Continuar?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get settingsResetSuccess => 'Todos os registros foram redefinidos.';

  @override
  String get settingsSectionCache => 'Gerenciamento de cache';

  @override
  String get settingsCacheDriveDownload => 'Downloads do Google Drive';

  @override
  String get settingsClearAllCache => 'Limpar todo o cache';

  @override
  String get settingsClearCacheSubtitle =>
      'Excluir arquivos do Google Drive e arquivos temporários';

  @override
  String get settingsCacheDeleteDialogTitle => 'Excluir cache';

  @override
  String settingsCacheDeleteDialogContent(String size) {
    return '$size de cache será excluído.';
  }

  @override
  String get settingsCacheDeleteSuccess => 'Cache excluído.';

  @override
  String get settingsAppLanguage => 'Idioma do aplicativo';

  @override
  String get settingsAppLanguageTitle => 'Selecionar idioma do aplicativo';

  @override
  String get settingsSystemDefault => 'Padrão do sistema';

  @override
  String get settingsSystemDefaultSubtitle => 'Segue o idioma do dispositivo';

  @override
  String homeStreakActive(int days) {
    return '$days dias seguidos!';
  }

  @override
  String homeStreakStats(int longest, int total) {
    return 'Melhor: $longest dias · Total: $total dias';
  }

  @override
  String get homeEmptyLibrary =>
      'Adicione arquivos da biblioteca para começar a aprender.';

  @override
  String get homeNoHistory => 'Ainda sem histórico de estudo.';

  @override
  String get homeStatusDone => 'Concluído';

  @override
  String get homeStatusStudying => 'Estudando';

  @override
  String homeDueReview(int count) {
    return '$count frases para revisar hoje';
  }

  @override
  String get homeNoDueReview => 'Nenhuma frase para revisar';

  @override
  String get homeAiConversation => 'Prática de conversa com IA';

  @override
  String get homeAiConversationSubtitle =>
      'Converse livremente com uma IA de nível nativo';

  @override
  String get homePhoneticsHub => 'Centro de treinamento de pronúncia';

  @override
  String get homePhoneticsHubSubtitle =>
      'TTS + pontuação no dispositivo · Sem API necessária';

  @override
  String get tutorialSkip => 'Pular';

  @override
  String get tutorialStart => 'Começar 🚀';

  @override
  String get tutorialNext => 'Próximo';

  @override
  String get playerClipEdit => 'Editar clipe';

  @override
  String get playerSpeedSuggestion =>
      'Você ouviu 70%+! Tentar aumentar a velocidade? 🚀';

  @override
  String get playerSpeedIncrease => 'Aumentar';

  @override
  String get playerMenuDictation => 'Prática de ditado';

  @override
  String get playerSelectFileFirst =>
      'Por favor, selecione um arquivo de áudio primeiro.';

  @override
  String get playerMenuActiveRecall => 'Treinamento de recuperação ativa';

  @override
  String get playerMenuBookmark => 'Salvar marcador';

  @override
  String get playerBookmarkSaved => 'Marcador salvo!';

  @override
  String get playerBookmarkDuplicate => 'Esta frase já está marcada.';

  @override
  String get playerBeginnerMode => 'Modo iniciante (0.75x)';

  @override
  String get playerLoopOff => 'Sem repetição';

  @override
  String get playerLoopOne => 'Repetir uma';

  @override
  String get playerLoopAll => 'Repetir todas';

  @override
  String get playerScriptReady => 'Roteiro pronto';

  @override
  String get playerNoScript => 'Sem roteiro';

  @override
  String playerAbLoopASet(String time) {
    return 'A: $time — B não definido';
  }

  @override
  String playerError(String error) {
    return 'Erro: $error';
  }

  @override
  String get conversationTopicSuggest => 'Sugerir tópico';

  @override
  String conversationInputHint(String language) {
    return 'Fale em $language...';
  }

  @override
  String conversationPracticeTitle(String language) {
    return 'Prática de conversa em $language';
  }

  @override
  String get conversationWelcomeMsg =>
      'Converse livremente com uma IA de nível nativo.\nNão tenha medo de errar!';

  @override
  String get conversationStartBtn => 'Iniciar conversa';

  @override
  String get conversationTopicExamples => 'Exemplos de tópicos';

  @override
  String get statsStudiedContent => 'Conteúdo estudado';

  @override
  String statsItemCount(int count) {
    return '$count itens';
  }

  @override
  String get statsTotalTime => 'Tempo total de estudo';

  @override
  String statsMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get statsNoHistory =>
      'Ainda sem histórico de estudo.\nAdicione conteúdo da biblioteca para começar.';

  @override
  String get statsProgressByItem => 'Progresso por item';

  @override
  String get statsPronunciationProgress => 'Melhoria de pronúncia';

  @override
  String get statsPronunciationEmpty =>
      'Complete sessões de shadowing para ver sua melhoria de pronúncia aqui.';

  @override
  String statsPracticeCount(int count) {
    return '$count sessões';
  }

  @override
  String get statsStreakSection => 'Sequência de estudo';

  @override
  String get statsStreakCurrentLabel => 'Sequência atual';

  @override
  String get statsStreakLongestLabel => 'Maior sequência';

  @override
  String get statsStreakTotalLabel => 'Dias totais';

  @override
  String statsDays(int days) {
    return '$days dias';
  }

  @override
  String get statsJournal => 'Diário de estudo';

  @override
  String get statsJournalEmpty =>
      'Seu diário será registrado automaticamente assim que você começar a estudar.';

  @override
  String get statsShareCard => 'Compartilhar cartão de estudo';

  @override
  String get statsShareSubtitle =>
      'Compartilhe suas conquistas de aprendizado nas redes sociais';

  @override
  String get statsMinimalPair => 'Treinamento de pares mínimos';

  @override
  String get statsMinimalPairSubtitle =>
      'Distinguir sons semelhantes (EN/JA/ES)';

  @override
  String statsError(String error) {
    return 'Erro: $error';
  }

  @override
  String get phoneticsHubFreeTitle => 'Treinamento de pronúncia sem IA';

  @override
  String get phoneticsHubFreeSubtitle =>
      'TTS do dispositivo + reconhecimento de voz\nGrátis sem chave de API';

  @override
  String get phoneticsHubTrainingTools => 'Ferramentas de treinamento';

  @override
  String get phoneticsComingSoon => 'Em breve';

  @override
  String get phoneticsSpanishIpa => 'IPA espanhol';

  @override
  String get phoneticsSpanishIpaSubtitle =>
      'Símbolos fonéticos espanhol + prática (em breve)';

  @override
  String get apiKeyRequired => 'Por favor, insira pelo menos uma chave API.';

  @override
  String get apiKeyInvalidFormat =>
      'Formato de chave API OpenAI inválido. (deve começar com sk-)';

  @override
  String get apiKeySaved => 'Chave API salva com segurança.';

  @override
  String get libraryNewPlaylist => 'Nova lista de reprodução';

  @override
  String get libraryImport => 'Importar';

  @override
  String get libraryAllTab => 'Tudo';

  @override
  String get libraryLocalSource => 'Local';

  @override
  String get libraryNoScript => 'Sem roteiro';

  @override
  String get libraryUnsetLanguage => 'Não definido';

  @override
  String get libraryEmptyPlaylist => 'Ainda sem listas de reprodução.';

  @override
  String get libraryCreatePlaylist => 'Criar nova lista de reprodução';

  @override
  String libraryTrackCount(int count) {
    return '$count faixas';
  }

  @override
  String libraryMoreTracks(int count) {
    return '+ $count mais';
  }

  @override
  String get libraryEditNameEmoji => 'Editar nome/emoji';

  @override
  String get libraryDeletePlaylist => 'Excluir';

  @override
  String get libraryEditPlaylist => 'Editar lista de reprodução';

  @override
  String get librarySetLanguage => 'Definir idioma';

  @override
  String libraryChangeLanguage(String lang) {
    return 'Alterar idioma (atual: $lang)';
  }

  @override
  String get libraryAddToPlaylist => 'Adicionar à lista de reprodução';

  @override
  String get libraryLanguageBadge => 'Distintivo de idioma';

  @override
  String get phoneticsQuizTitle => 'Quiz de pronúncia';

  @override
  String get phoneticsQuizDesc =>
      'Quiz de IPA ↔ correspondência de palavras\nBônus de sequência + estatísticas de precisão';

  @override
  String get phoneticsTtsPracticeTitle => 'Prática de pronúncia TTS';

  @override
  String get phoneticsTtsPracticeDesc =>
      'Ouça palavras e repita com símbolos IPA\nSem chave de API · Completamente grátis';

  @override
  String get phoneticsMinimalPairDesc =>
      'Distinguir sons semelhantes (ship vs sheep etc.)\nAudição TTS + pontuação de pronúncia';

  @override
  String get phoneticsPitchAccentTitle => 'Acento tonal japonês';

  @override
  String get phoneticsPitchAccentDesc =>
      'Visualize padrões de tom para homófonos\nex. はし (pauzinhos/ponte/beira)';

  @override
  String get phoneticsKanaDrillTitle => 'Exercício de Hiragana · Katakana';

  @override
  String get phoneticsKanaDrillDesc =>
      'Toque em qualquer caractere kana para ouvir a pronúncia TTS\nTabela completa de 50 sons incluída';

  @override
  String get libraryPlaylistTab => 'Listas de reprodução';

  @override
  String get importTitle => 'Importar';

  @override
  String get importFromDevice => 'Importar deste dispositivo';

  @override
  String get importFromDeviceSubtitle =>
      'Carregar áudio + scripts de uma pasta local';

  @override
  String get importFromICloud => 'Importar do iCloud Drive';

  @override
  String get importFromICloudSubtitle =>
      'Vincular pasta do iCloud Drive à biblioteca';

  @override
  String get importFromGoogleDrive => 'Importar do Google Drive';

  @override
  String get importFromGoogleDriveSubtitle =>
      'Navegar e baixar uma pasta do Google Drive';

  @override
  String get importAutoSync =>
      'Sincronização automática da pasta Scripta Sync iCloud';

  @override
  String get importAutoSyncSubtitle =>
      'Varredura automática da pasta iCloud Drive/Scripta Sync/';

  @override
  String heatmapTitle(int weeks) {
    return 'Registro de estudo (últimas $weeks semanas)';
  }

  @override
  String heatmapTooltip(String date, int minutes) {
    return '$date: $minutes min';
  }

  @override
  String get heatmapNoActivity => 'Sem atividade';

  @override
  String get heatmapLess => 'Menos';

  @override
  String get heatmapMore => 'Mais';

  @override
  String get loginSubtitle => 'Melhore suas habilidades linguísticas com IA';

  @override
  String get loginWithGoogle => 'Continuar com Google';

  @override
  String get loginFeatureAi =>
      'Tutor de gramática, vocabulário e conversação com IA (grátis)';

  @override
  String get loginFeaturePronunciation => 'Avaliação de pronúncia e tons';

  @override
  String get loginFeatureSync =>
      'Sincronização automática com IA — gere roteiros a partir de áudio';

  @override
  String get loginFeatureFree =>
      '3 minutos diários de processamento de áudio com IA gratuitamente';

  @override
  String get loginLegalPrefix => 'Ao continuar, você concorda com nossos ';

  @override
  String get loginTermsLink => 'Termos de Serviço';

  @override
  String get loginLegalAnd => 'e a';

  @override
  String get loginPrivacyLink => 'Política de Privacidade';

  @override
  String get loginLegalSuffix => '.';

  @override
  String get settingsSectionAccount => 'Conta';

  @override
  String get settingsLogin => 'Entrar';

  @override
  String get settingsLoginSubtitle => 'Faça login para usar os recursos de IA';

  @override
  String get settingsSectionCredits => 'Créditos e Assinatura';

  @override
  String get settingsCreditsSubtitle =>
      'Gerenciar créditos de áudio IA e planos';

  @override
  String get settingsLogout => 'Sair';

  @override
  String get settingsLogoutDialogTitle => 'Sair';

  @override
  String get settingsLogoutDialogContent => 'Tem certeza que deseja sair?';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsTermsSubtitle => 'Ver nossos termos de serviço';

  @override
  String get settingsPrivacySubtitle => 'Como tratamos seus dados';

  @override
  String get creditsTitle => 'Créditos';

  @override
  String get creditsDailyFree => 'Cota gratuita de hoje';

  @override
  String get creditsMinRemaining => 'min restantes';

  @override
  String get creditsDailyResets => 'Redefine à meia-noite';

  @override
  String get creditsPurchasedCredits => 'Créditos comprados';

  @override
  String get creditsMinutes => 'min';

  @override
  String get creditsSubscriptionActive => 'assinatura ativa';

  @override
  String get creditsSubscriptionsTitle => 'Planos de Assinatura';

  @override
  String get creditsMostPopular => 'Popular';

  @override
  String get creditsPerMonth => '/ mês';

  @override
  String get creditPacksTitle => 'Pacotes de Créditos';

  @override
  String get creditPacksSubtitle => 'Compra única, sem expiração';

  @override
  String get creditsLoadError => 'Falha ao carregar informações de crédito.';

  @override
  String get creditsPaymentComingSoon => 'Sistema de pagamento em breve';

  @override
  String get termsTitle => 'Termos de Serviço';

  @override
  String get termsLastUpdated => 'Última atualização: março de 2025';

  @override
  String get termsSec1Title => '1. Visão geral do serviço';

  @override
  String get termsSec1Body =>
      'LingoNexus é uma plataforma de aprendizado de idiomas com IA. Estes termos regem o uso do serviço.';

  @override
  String get termsSec2Title => '2. Conta e autenticação';

  @override
  String get termsSec2Body =>
      'Você deve fazer login com uma conta Google para usar os recursos de IA. Você é responsável pela segurança da sua conta.';

  @override
  String get termsSec3Title => '3. Créditos e pagamento';

  @override
  String get termsSec3Body =>
      'O processamento de áudio com IA consome créditos. 3 minutos de uso gratuito são fornecidos diariamente. Créditos comprados não são reembolsáveis.';

  @override
  String get termsSec4Title => '4. Restrições de uso';

  @override
  String get termsSec4Body =>
      'O abuso do serviço ou uso automatizado excessivo é proibido. Limite de 10 minutos por upload.';

  @override
  String get termsSec5Title => '5. Propriedade intelectual';

  @override
  String get termsSec5Body =>
      'Os direitos autorais do conteúdo enviado pertencem ao usuário. Os resultados de IA são apenas para referência.';

  @override
  String get termsSec6Title => '6. Isenção de responsabilidade';

  @override
  String get termsSec6Body =>
      'Não garantimos a precisão dos resultados de IA. Os termos podem mudar com aviso prévio.';

  @override
  String get privacyTitle => 'Política de Privacidade';

  @override
  String get privacyLastUpdated => 'Última atualização: março de 2025';

  @override
  String get privacySec1Title => '1. Informações que coletamos';

  @override
  String get privacySec1Body =>
      'Ao fazer login com Google, coletamos seu e-mail, nome e foto de perfil. Dados de áudio não são armazenados em nossos servidores.';

  @override
  String get privacySec2Title => '2. Como usamos suas informações';

  @override
  String get privacySec2Body =>
      'As informações são usadas exclusivamente para a prestação do serviço e gerenciamento de créditos. Não vendemos informações pessoais.';

  @override
  String get privacySec3Title => '3. Segurança de dados';

  @override
  String get privacySec3Body =>
      'Os tokens de autenticação são armazenados no armazenamento criptografado do dispositivo. Os dados do servidor são criptografados em repouso.';

  @override
  String get privacySec4Title => '4. Serviços de terceiros';

  @override
  String get privacySec4Body =>
      'Usamos Google Sign-In, Google Gemini API e Alibaba Qwen API.';

  @override
  String get privacySec5Title => '5. Seus direitos';

  @override
  String get privacySec5Body =>
      'Você pode solicitar a exclusão da conta a qualquer momento. Contato: support@lingonexus.app';

  @override
  String get syncNoiseWarning =>
      'O ruído de fundo pode reduzir a precisão da transcrição. Use áudio gravado em um ambiente silencioso.';

  @override
  String get syncTranslationLanguage => 'Idioma de tradução';

  @override
  String get syncAudioLanguage => 'Idioma do áudio';

  @override
  String get syncAnnotating => 'Gerando fonética e tradução…';

  @override
  String syncScriptSaved(Object count) {
    return '$count frases sincronizadas! Script salvo.';
  }
}
