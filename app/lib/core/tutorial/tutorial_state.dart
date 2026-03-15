enum TutorialStep {
  importFile,
  playerControls,
  aiTutor,
  phonetics,
  podcast,
  done,
}

class TutorialStepInfo {
  final TutorialStep step;
  final String emoji;
  final String title;
  final String description;

  const TutorialStepInfo({
    required this.step,
    required this.emoji,
    required this.title,
    required this.description,
  });
}

/// 튜토리얼 단계 정보 목록. 새로운 기능 추가 시 여기에도 반영할 것.
const List<TutorialStepInfo> tutorialSteps = [
  TutorialStepInfo(
    step: TutorialStep.importFile,
    emoji: '📂',
    title: '파일 가져오기',
    description: '하단 메뉴의 라이브러리(📚)를 눌러 음원 파일(.mp3/.m4a/.wav)을 가져오세요.\n'
        '같은 이름의 .txt 파일이 있으면 대본으로 자동 연결됩니다.',
  ),
  TutorialStepInfo(
    step: TutorialStep.playerControls,
    emoji: '🎧',
    title: '쉐도잉 플레이어',
    description: '파일을 선택하면 플레이어가 열립니다.\n'
        '구간 반복, 속도 조절, A-B 루프로 집중 쉐도잉 연습을 하세요.',
  ),
  TutorialStepInfo(
    step: TutorialStep.aiTutor,
    emoji: '🤖',
    title: 'AI 문법 튜터',
    description: '대본의 문장을 탭하면 AI가 문법을 설명해 줍니다.\n'
        '설정에서 Google Gemini 또는 OpenAI API 키를 등록하세요.',
  ),
  TutorialStepInfo(
    step: TutorialStep.phonetics,
    emoji: '🗣️',
    title: '발음 훈련 센터',
    description: '홈 화면에서 발음 훈련 센터로 이동하세요.\n'
        'TTS 발음 연습, 최소쌍 훈련, 피치 악센트 등 다양한 훈련이 준비되어 있습니다.',
  ),
  TutorialStepInfo(
    step: TutorialStep.podcast,
    emoji: '🎙️',
    title: '팟캐스트 구독',
    description: '하단 팟캐스트 탭에서 RSS 피드 URL을 추가해 에피소드를 구독하세요.\n'
        '에피소드를 다운로드하면 라이브러리에 추가하여 쉐도잉 연습에 활용할 수 있습니다.',
  ),
];
