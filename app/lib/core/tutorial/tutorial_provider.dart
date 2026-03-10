import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tutorial_service.dart';
import 'tutorial_state.dart';

final tutorialServiceProvider = Provider((ref) => TutorialService());

/// 현재 튜토리얼 단계. null이면 튜토리얼 비활성.
final tutorialStepProvider = StateNotifierProvider<TutorialNotifier, TutorialStep?>((ref) {
  return TutorialNotifier(ref.read(tutorialServiceProvider));
});

class TutorialNotifier extends StateNotifier<TutorialStep?> {
  final TutorialService _service;

  TutorialNotifier(this._service) : super(null) {
    _init();
  }

  Future<void> _init() async {
    final completed = await _service.isCompleted();
    if (!completed) {
      state = TutorialStep.importFile;
    }
  }

  void advance() {
    final current = state;
    if (current == null) return;

    switch (current) {
      case TutorialStep.importFile:
        state = TutorialStep.playerControls;
      case TutorialStep.playerControls:
        state = TutorialStep.aiTutor;
      case TutorialStep.aiTutor:
        state = TutorialStep.phonetics;
      case TutorialStep.phonetics:
        _complete();
      case TutorialStep.done:
        state = null;
    }
  }

  void skip() => _complete();

  Future<void> _complete() async {
    await _service.markCompleted();
    state = null;
  }
}
