import 'package:flutter/material.dart';
import '../models/quiz_answer.dart';
import '../widgets/gallery_ui.dart';

class QuizHelpScreen extends StatelessWidget {
  const QuizHelpScreen({super.key});
  @override
  Widget build(BuildContext context) => GalleryPage(
          child: Column(children: [
        Align(
            alignment: Alignment.centerLeft,
            child: GalleryIcon(
                icon: Icons.arrow_back,
                onTap: () => Navigator.of(context).pop(),
                label: 'Back')),
        Expanded(
            child: SingleChildScrollView(
                child: Column(children: [
          SizedBox(
              height: MediaQuery.sizeOf(context).height < 650 ? 80 : 150,
              child: const GalleryArt('help')),
          Text('HOW TO PLAY', style: quizText(32, display: true)),
          const SizedBox(height: 6),
          Text('A little curiosity goes a long way',
              style: quizText(15, color: quizMuted),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          for (final lesson in const [
            (
              '1',
              'Choose a topic',
              'Explore Science, History, Geography, Mathematics or Technology.'
            ),
            (
              '2',
              'Set your quiz length',
              'Choose how many questions to answer.'
            ),
            (
              '3',
              'Pick your answer',
              'You have 30 seconds per question. Correct answers earn points, with bonuses for speed and streaks.'
            ),
          ])
            Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GalleryPanel(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      CircleAvatar(
                          backgroundColor: quizOrange,
                          foregroundColor: Colors.white,
                          child: Text(lesson.$1)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(lesson.$2, style: quizText(23, display: true)),
                            const SizedBox(height: 8),
                            Text(lesson.$3,
                                style: quizText(16, color: quizMuted)),
                          ])),
                    ]))),
        ]))),
        const SizedBox(height: 10),
        GalleryButton('GOT IT', onTap: () => Navigator.of(context).pop()),
      ]));
}

class QuizReviewScreen extends StatefulWidget {
  const QuizReviewScreen(
      {super.key, required this.answers, required this.categoryName});
  final List<QuizAnswer> answers;
  final String categoryName;
  @override
  State<QuizReviewScreen> createState() => _ReviewState();
}

class _ReviewState extends State<QuizReviewScreen> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final answer = widget.answers[index];
    final q = answer.question;
    return GalleryPage(
        child: Column(children: [
      Row(children: [
        GalleryIcon(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
            label: 'Back to results'),
        const SizedBox(width: 12),
        Expanded(
            child: Text('ANSWER REVIEW', style: quizText(25, display: true)))
      ]),
      const SizedBox(height: 12),
      Text(
          '${widget.categoryName} • ${widget.answers.where((a) => a.isCorrect).length} of ${widget.answers.length} correct',
          style: quizText(15, color: quizMuted)),
      const SizedBox(height: 12),
      Expanded(
          child: SingleChildScrollView(
              child: GalleryPanel(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
            Text('QUESTION ${index + 1} OF ${widget.answers.length}',
                style: quizText(12, color: quizMuted)),
            const SizedBox(height: 12),
            Text(q.question, style: quizText(25, display: true)),
            const SizedBox(height: 16),
            for (int i = 0; i < q.options.length; i++)
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GalleryPanel(
                      radius: 15,
                      color: i == q.correctOptionIndex
                          ? const Color(0xFFE4F5EA)
                          : i == answer.selectedIndex
                              ? const Color(0xFFFFE8E6)
                              : const Color(0xFFF2F5F8),
                      child: Row(children: [
                        Text(String.fromCharCode(65 + i), style: quizText(16)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(q.options[i], style: quizText(17))),
                        if (i == q.correctOptionIndex ||
                            i == answer.selectedIndex)
                          Icon(
                              i == q.correctOptionIndex
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: i == q.correctOptionIndex
                                  ? const Color(0xFF237245)
                                  : const Color(0xFFB33939)),
                      ]))),
            Text(
                answer.timedOut
                    ? 'Your answer: Time ran out'
                    : 'Your answer: ${q.options[answer.selectedIndex]}',
                style: quizText(15,
                    color: answer.isCorrect
                        ? const Color(0xFF237245)
                        : const Color(0xFFB33939))),
            const SizedBox(height: 14),
            Text('WHY?', style: quizText(23, display: true)),
            const SizedBox(height: 8),
            Text(q.explanation, style: quizText(17, color: quizMuted)),
          ])))),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: GalleryButton('PREVIOUS',
                outline: true,
                onTap: index == 0 ? null : () => setState(() => index--))),
        const SizedBox(width: 10),
        Expanded(
            child: GalleryButton('NEXT',
                orange: true,
                onTap: index == widget.answers.length - 1
                    ? null
                    : () => setState(() => index++)))
      ]),
      TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('BACK TO RESULTS')),
    ]));
  }
}
