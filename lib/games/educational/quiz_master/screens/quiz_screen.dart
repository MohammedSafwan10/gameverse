import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import '../controllers/mode_selection_controller.dart';
import '../models/quiz_category.dart';
import '../widgets/gallery_ui.dart';
import '../services/quiz_sound_service.dart';
import 'support_screens.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen(
      {super.key,
      required this.category,
      required this.questionCount,
      required this.mode,
      this.controller});
  final QuizCategory category;
  final int questionCount;
  final QuizMode mode;
  final QuizMasterController? controller;
  @override
  State<QuizScreen> createState() => _QuizState();
}

class _QuizState extends State<QuizScreen> with WidgetsBindingObserver {
  late final QuizMasterController game;
  QuizSoundService? sounds;
  Worker? _answerSound, _completionSound;
  bool _leaving = false, _allowPop = false, _background = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    game = widget.controller ?? QuizMasterController();
    if (widget.controller == null && Get.isRegistered<QuizSoundService>()) {
      sounds = Get.find<QuizSoundService>()..suspend(false);
      _answerSound = ever(game.answers, (_) {
        if (game.answers.isEmpty) return;
        final answer = game.answers.last;
        sounds?.play(answer.timedOut
            ? 'timeout'
            : answer.isCorrect
                ? 'correct'
                : 'wrong');
      });
      _completionSound = ever(game.isCompleted, (complete) {
        if (complete) sounds?.play('complete');
      });
    }
    if (widget.controller == null) {
      game.startQuiz(
          category: widget.category,
          questionCount: widget.questionCount,
          mode: widget.mode);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _background = state != AppLifecycleState.resumed;
    game.setPaused(_background || _leaving);
    sounds?.suspend(_background || _leaving);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _answerSound?.dispose();
    _completionSound?.dispose();
    sounds?.suspend(true);
    if (widget.controller == null) game.onClose();
    super.dispose();
  }

  Future<void> _exit() async {
    if (_leaving) return;
    if (game.isCompleted.value) {
      _pop();
      return;
    }
    _leaving = true;
    game.setPaused(true);
    sounds?.suspend(true);
    final leave = await showDialog<bool>(
        context: context, builder: (_) => const QuizLeaveDialog());
    if (!mounted) return;
    _leaving = false;
    if (leave == true) {
      _pop();
    } else {
      game.setPaused(_background);
      sounds?.suspend(_background);
    }
  }

  void _pop() {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _restart() => game.startQuiz(
      category: widget.category,
      questionCount: widget.questionCount,
      mode: widget.mode);
  @override
  Widget build(BuildContext context) => PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exit();
      },
      child: GalleryPage(child: Obx(() {
        if (game.isCompleted.value && game.sessionResult.value != null) {
          return _results();
        }
        if (game.isLoading.value || game.currentQuestion.value == null) {
          return Column(children: [
            Align(
                alignment: Alignment.centerLeft,
                child: GalleryIcon(
                    icon: Icons.arrow_back, onTap: _exit, label: 'Back')),
            const Spacer(),
            const SizedBox(height: 130, child: GalleryArt('hero')),
            if (game.isLoading.value)
              const CircularProgressIndicator()
            else ...[
              Text(game.errorMessage.value ?? 'No questions available',
                  style: quizText(18)),
              const SizedBox(height: 20),
              GalleryButton('TRY AGAIN', onTap: _restart)
            ],
            const Spacer(),
          ]);
        }
        return _play();
      })));
  Widget _play() {
    final q = game.currentQuestion.value!;
    final answered = game.hasAnswered.value;
    final answer = answered ? game.answers.last : null;
    final height = MediaQuery.sizeOf(context).height;
    final compact = height < 650;
    return Column(children: [
      Row(children: [
        GalleryIcon(
            icon: Icons.arrow_back_rounded, onTap: _exit, label: 'Leave quiz'),
        const SizedBox(width: 10),
        Expanded(
            child: Text('${widget.category.name.toUpperCase()} QUIZ',
                style: quizText(compact ? 22 : 28, display: true))),
        if (sounds != null)
          Obx(() => GalleryIcon(
              icon: sounds!.muted.value
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
              onTap: sounds!.toggleMute,
              label: sounds!.muted.value ? 'Enable sound' : 'Mute sound')),
      ]),
      const SizedBox(height: 10),
      GalleryPanel(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
                child: GalleryStat(
                    'SCORE', '${game.score.value}', Icons.bar_chart)),
            Expanded(
                child: GalleryStat('STREAK', '${game.streak.value}',
                    Icons.local_fire_department)),
          ])),
      const SizedBox(height: 10),
      GalleryPanel(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: Text(
                      'QUESTION ${game.currentQuestionIndex.value + 1} OF ${game.questions.length}',
                      style: quizText(12, color: quizMuted))),
              Icon(Icons.timer_outlined,
                  size: 20,
                  color: game.timeRemaining.value < 6 ? quizOrange : quizBlue),
              const SizedBox(width: 5),
              Text('${game.timeRemaining.value}s',
                  style: quizText(20, display: true))
            ]),
            const SizedBox(height: 7),
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                    value: (game.currentQuestionIndex.value + 1) /
                        game.questions.length,
                    backgroundColor: const Color(0xFFDCE5ED),
                    color: quizBlue)),
            const SizedBox(height: 5),
            LinearProgressIndicator(
                value: game.timeRemaining.value / 30,
                minHeight: 2,
                color: quizOrange,
                backgroundColor: const Color(0xFFF0E5DC)),
          ])),
      const SizedBox(height: 10),
      Expanded(child: LayoutBuilder(builder: (context, box) {
        final artHeight =
            compact ? 32.0 : (box.maxHeight * .12).clamp(48.0, 75.0);
        return SingleChildScrollView(
            child: Column(children: [
          GalleryPanel(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                SizedBox(
                    height: artHeight,
                    width: double.infinity,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GalleryArt(widget.category.id))),
                const SizedBox(height: 10),
                Text(q.question,
                    style: quizText(compact ? 22 : 25, display: true),
                    textAlign: TextAlign.center),
              ])),
          const SizedBox(height: 10),
          for (int i = 0; i < q.options.length; i++)
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _option(
                    i,
                    q.options[i],
                    answered && i == q.correctOptionIndex,
                    answered &&
                        i == game.selectedAnswer.value &&
                        i != q.correctOptionIndex,
                    answered)),
          if (answer != null)
            GalleryPanel(
                radius: 17,
                color: answer.isCorrect
                    ? const Color(0xFFE4F5EA)
                    : const Color(0xFFFFF0E6),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(
                            answer.isCorrect
                                ? Icons.check_circle
                                : answer.timedOut
                                    ? Icons.timer_outlined
                                    : Icons.lightbulb_outline,
                            color: answer.isCorrect
                                ? const Color(0xFF237245)
                                : quizOrange),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(
                                answer.isCorrect
                                    ? 'CORRECT! +${answer.points} points'
                                    : answer.timedOut
                                        ? "TIME'S UP"
                                        : 'NOT QUITE',
                                style: quizText(20, display: true)))
                      ]),
                      const SizedBox(height: 6),
                      if (!answer.isCorrect)
                        Text(
                            'Correct answer: ${q.options[q.correctOptionIndex]}',
                            style: quizText(15)),
                      Text(q.explanation,
                          style: quizText(15, color: quizMuted)),
                    ])),
        ]));
      })),
      const SizedBox(height: 10),
      SizedBox(
          height: 50,
          child: answered
              ? GalleryButton(
                  game.currentQuestionIndex.value == game.questions.length - 1
                      ? 'FINISH QUIZ'
                      : 'NEXT QUESTION',
                  orange: answer!.isCorrect,
                  onTap: game.nextQuestion)
              : Center(
                  child: Text('Tap an answer to continue',
                      style: quizText(14, color: quizMuted)))),
    ]);
  }

  Widget _option(
          int i, String label, bool correct, bool wrong, bool disabled) =>
      Semantics(
          button: true,
          enabled: !disabled,
          label:
              '${String.fromCharCode(65 + i)} $label${correct ? ", correct answer" : wrong ? ", your incorrect answer" : ""}',
          child: GalleryPanel(
              radius: 17,
              padding: EdgeInsets.zero,
              color: correct
                  ? const Color(0xFFE4F5EA)
                  : wrong
                      ? const Color(0xFFFFE8E6)
                      : Colors.white,
              border: correct
                  ? const Color(0xFF237245)
                  : wrong
                      ? const Color(0xFFB33939)
                      : null,
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      borderRadius: BorderRadius.circular(17),
                      onTap: disabled ? null : () => game.answerQuestion(i),
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(children: [
                            CircleAvatar(
                                radius: 17,
                                backgroundColor: correct
                                    ? const Color(0xFF237245)
                                    : wrong
                                        ? const Color(0xFFB33939)
                                        : disabled
                                            ? const Color(0xFFD8E1EB)
                                            : quizBlue,
                                child: Text(String.fromCharCode(65 + i),
                                    style: quizText(15,
                                        color: disabled && !correct && !wrong
                                            ? quizNavy
                                            : Colors.white))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(label, style: quizText(17))),
                            if (correct || wrong)
                              Icon(correct ? Icons.check_circle : Icons.cancel,
                                  color: correct
                                      ? const Color(0xFF237245)
                                      : const Color(0xFFB33939)),
                          ]))))));
  Widget _results() {
    final r = game.sessionResult.value!;
    return Column(children: [
      Align(
          alignment: Alignment.centerLeft,
          child: GalleryIcon(
              icon: Icons.arrow_back, onTap: _exit, label: 'Back to topics')),
      Expanded(
          child: SingleChildScrollView(
              child: Column(children: [
        SizedBox(
            height: MediaQuery.sizeOf(context).height < 650 ? 85 : 155,
            child: const GalleryArt('trophy')),
        Text('QUIZ COMPLETE',
            style: quizText(34, display: true), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
            r.accuracy >= .8
                ? 'A brilliant round of discovery'
                : 'Every question is a chance to learn',
            style: quizText(16, color: quizMuted),
            textAlign: TextAlign.center),
        const SizedBox(height: 14),
        GalleryPanel(
            child: Column(children: [
          Text('${widget.category.name} • ${r.totalQuestions} questions',
              style: quizText(15, color: quizMuted)),
          const Divider(height: 24, color: Color(0xFFDAE3EA)),
          Text('FINAL SCORE', style: quizText(12, color: quizMuted)),
          Text('${r.finalScore}', style: quizText(58, display: true)),
          Row(children: [
            Expanded(
                child: GalleryStat(
                    'CORRECT',
                    '${r.correctAnswers}/${r.totalQuestions}',
                    Icons.check_circle)),
            Expanded(
                child: GalleryStat(
                    'ACCURACY', '${(r.accuracy * 100).round()}%', Icons.adjust))
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: GalleryStat('BEST STREAK', '${r.highestStreak}x',
                    Icons.local_fire_department)),
            Expanded(
                child: GalleryStat(
                    'QUESTIONS', '${r.totalQuestions}', Icons.bar_chart))
          ]),
        ])),
        if (game.errorMessage.value != null) ...[
          const SizedBox(height: 12),
          Text(game.errorMessage.value!, style: quizText(14)),
          TextButton(
              onPressed: game.saveSessionStats,
              child: const Text('RETRY SAVE')),
        ],
      ]))),
      const SizedBox(height: 12),
      GalleryButton('PLAY AGAIN', orange: true, onTap: _restart),
      const SizedBox(height: 10),
      GalleryButton('REVIEW ANSWERS',
          outline: true,
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => QuizReviewScreen(
                  answers: List.unmodifiable(game.answers),
                  categoryName: widget.category.name)))),
      TextButton(onPressed: _exit, child: const Text('BACK TO TOPICS')),
    ]);
  }
}

class QuizLeaveDialog extends StatelessWidget {
  const QuizLeaveDialog({super.key});
  @override
  Widget build(BuildContext context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: GalleryPanel(
          child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            height: MediaQuery.sizeOf(context).height < 650 ? 90 : 150,
            child: const GalleryArt('leave')),
        Text('LEAVE THIS QUIZ?',
            style: quizText(27, display: true), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text('This unfinished round will not be saved.',
            style: quizText(16, color: quizMuted), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        GalleryButton('KEEP PLAYING',
            onTap: () => Navigator.of(context).pop(false)),
        const SizedBox(height: 12),
        GalleryButton('LEAVE QUIZ',
            outline: true,
            orange: true,
            onTap: () => Navigator.of(context).pop(true)),
      ]))));
}
