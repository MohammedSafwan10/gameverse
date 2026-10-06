import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bindings/quiz_binding.dart';
import '../models/quiz_category.dart';
import '../services/quiz_service.dart';
import '../widgets/gallery_ui.dart';
import 'quiz_screen.dart';
import 'support_screens.dart';
import '../controllers/mode_selection_controller.dart';

class QuizMasterModeSelectionScreen extends StatefulWidget {
  const QuizMasterModeSelectionScreen({super.key});
  @override
  State<QuizMasterModeSelectionScreen> createState() => _QuizMenuState();
}

class _QuizMenuState extends State<QuizMasterModeSelectionScreen> {
  late final QuizService service;
  bool _opening = false;
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<QuizService>()) QuizMasterBinding().dependencies();
    service = Get.find<QuizService>();
  }

  Future<void> _setup(QuizCategory category) async {
    if (_opening) return;
    _opening = true;
    final count = await showDialog<int>(
        context: context, builder: (_) => QuizSetupDialog(category: category));
    if (mounted && count != null) {
      await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => QuizScreen(
              category: category,
              questionCount: count,
              mode: QuizMode.practice)));
    }
    _opening = false;
  }

  @override
  Widget build(BuildContext context) =>
      GalleryPage(child: GalleryViewport(builder: (context, height) {
        final compact = height < 650;
        final gap = compact ? 8.0 : 12.0;
        return Column(children: [
          Row(children: [
            GalleryIcon(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
                label: 'Back'),
            const Spacer(),
            GalleryIcon(
                icon: Icons.help_outline_rounded,
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const QuizHelpScreen())),
                label: 'How to play')
          ]),
          SizedBox(height: gap),
          SizedBox(
              height: height * .20,
              child: Row(children: [
                Expanded(
                    flex: 11,
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('QUIZ',
                                  style: quizText(compact ? 38 : 49,
                                      display: true)),
                              Text('MASTER',
                                  style: quizText(compact ? 32 : 40,
                                      display: true, color: quizOrange)),
                              const SizedBox(height: 4),
                              Text('Choose your topic',
                                  style: quizText(compact ? 13 : 16)),
                            ]))),
                Expanded(
                    flex: 9,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: const GalleryArt('hero', fit: BoxFit.contain))),
              ])),
          SizedBox(height: gap),
          Obx(() => GalleryPanel(
              padding: EdgeInsets.all(compact ? 8 : 12),
              child: Row(children: [
                Expanded(
                    child: GalleryStat(
                        'BEST SCORE',
                        '${service.highScores.values.fold<int>(0, (a, b) => a > b ? a : b)}',
                        Icons.emoji_events_rounded)),
                Container(width: 1, height: 32, color: const Color(0xFFCED8E4)),
                Expanded(
                    child: GalleryStat(
                        'QUIZZES PLAYED',
                        '${service.totalQuizzesPlayed.value}',
                        Icons.bar_chart_rounded)),
              ]))),
          SizedBox(height: gap),
          Expanded(
              child: Column(children: [
            Expanded(
                flex: 3,
                child: Row(children: [
                  Expanded(child: _card(service.categories[0])),
                  SizedBox(width: gap),
                  Expanded(child: _card(service.categories[1])),
                ])),
            SizedBox(height: gap),
            Expanded(
                flex: 3,
                child: Row(children: [
                  Expanded(child: _card(service.categories[2])),
                  SizedBox(width: gap),
                  Expanded(child: _card(service.categories[3])),
                ])),
            SizedBox(height: gap),
            Expanded(flex: 2, child: _card(service.categories[4], wide: true)),
          ])),
          SizedBox(height: gap),
          GalleryButton('HOW TO PLAY',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => const QuizHelpScreen()))),
        ]);
      }));
  Widget _card(QuizCategory category, {bool wide = false}) {
    if (wide && MediaQuery.sizeOf(context).height < 650) {
      return GalleryPanel(
          padding: EdgeInsets.zero,
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius: BorderRadius.circular(19),
                  onTap: () => _setup(category),
                  child: Row(children: [
                    const Expanded(flex: 2, child: GalleryArt('technology')),
                    Expanded(
                        flex: 3,
                        child: Text(category.name,
                            style: quizText(19, display: true))),
                    const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.chevron_right_rounded,
                            color: quizOrange)),
                  ]))));
    }
    return Semantics(
        button: true,
        label: 'Start ${category.name} quiz',
        child: GalleryPanel(
            padding: EdgeInsets.zero,
            radius: 19,
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    borderRadius: BorderRadius.circular(19),
                    onTap: () => _setup(category),
                    child: Column(children: [
                      Expanded(
                          child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(17)),
                              child: SizedBox.expand(
                                  child: GalleryArt(category.id,
                                      fit: wide ||
                                              MediaQuery.sizeOf(context)
                                                      .height <
                                                  650
                                          ? BoxFit.contain
                                          : BoxFit.cover)))),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(9, 6, 8, 6),
                          child: Row(children: [
                            Expanded(
                                child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(category.name,
                                        maxLines: 1,
                                        style: quizText(
                                            category.id == 'mathematics'
                                                ? 17
                                                : 19,
                                            display: true)))),
                            Container(
                                width: 25,
                                height: 25,
                                decoration: const BoxDecoration(
                                    color: quizOrange, shape: BoxShape.circle),
                                child: const Icon(Icons.chevron_right_rounded,
                                    color: Colors.white, size: 22)),
                          ])),
                    ])))));
  }
}

class QuizSetupDialog extends StatefulWidget {
  const QuizSetupDialog({super.key, required this.category});
  final QuizCategory category;
  @override
  State<QuizSetupDialog> createState() => _SetupState();
}

class _SetupState extends State<QuizSetupDialog> {
  late int count;
  @override
  void initState() {
    super.initState();
    count = widget.category.questionCount.clamp(1, 10);
  }

  @override
  Widget build(BuildContext context) {
    final max = widget.category.questionCount;
    final short = MediaQuery.sizeOf(context).height < 650;
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(18),
        child: GalleryPanel(
            child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerRight,
              child: GalleryIcon(
                  icon: Icons.close,
                  onTap: () => Navigator.of(context).pop(),
                  label: 'Cancel setup')),
          SizedBox(
              height: short ? 80 : 150, child: GalleryArt(widget.category.id)),
          Text(widget.category.name.toUpperCase(),
              style: quizText(short ? 27 : 35, display: true)),
          Text('Set your quiz length', style: quizText(16, color: quizMuted)),
          const SizedBox(height: 16),
          GalleryPanel(
              child: Column(children: [
            Text('QUESTIONS', style: quizText(12, color: quizMuted)),
            Text('$count', style: quizText(45, display: true)),
            if (max > 1)
              Slider(
                  activeColor: quizBlue,
                  inactiveColor: const Color(0xFFDCE5ED),
                  value: count.toDouble(),
                  min: 1,
                  max: max.toDouble(),
                  divisions: max - 1,
                  label: '$count',
                  onChanged: (v) => setState(() => count = v.round())),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('1', style: quizText(12, color: quizMuted)),
              Text('$max available', style: quizText(12, color: quizMuted))
            ]),
          ])),
          const SizedBox(height: 12),
          Text('30 seconds per question\nSpeed + streak bonuses',
              textAlign: TextAlign.center,
              style: quizText(14, color: quizMuted)),
          const SizedBox(height: 16),
          GalleryButton('START QUIZ',
              onTap: max > 0 ? () => Navigator.of(context).pop(count) : null),
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('CANCEL', style: quizText(14))),
        ]))));
  }
}
