import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bindings/quiz_binding.dart';
import '../models/quiz_category.dart';
import '../services/quiz_service.dart';
import '../services/quiz_sound_service.dart';
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
  late final QuizSoundService sounds;
  bool _opening = false;
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<QuizService>()) QuizMasterBinding().dependencies();
    service = Get.find<QuizService>();
    sounds = Get.isRegistered<QuizSoundService>()
        ? Get.find<QuizSoundService>()
        : Get.put(QuizSoundService());
    sounds.suspend(false);
    unawaited(sounds.preload());
  }

  Future<void> _setup(QuizCategory category) async {
    if (_opening) return;
    _opening = true;
    sounds.play('tap');
    final count = await showDialog<int>(
        context: context, builder: (_) => QuizSetupDialog(category: category));
    if (mounted && count != null) {
      await Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => QuizScreen(
              category: category,
              questionCount: count,
              mode: QuizMode.practice)));
    }
    sounds.suspend(false);
    _opening = false;
  }

  @override
  Widget build(BuildContext context) => GalleryPage(
      backgroundArt: null,
      child: GalleryViewport(builder: (context, height) {
        final compact = height < 650;
        final gap = compact ? 6.0 : 8.0;
        final headerHeight = height * (compact ? .24 : .215);
        return Column(children: [
          SizedBox(
              height: headerHeight,
              child: Stack(children: [
                Positioned.fill(
                    child: ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback: (bounds) => const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white,
                                  Colors.white,
                                  Colors.transparent
                                ],
                                stops: [
                                  0,
                                  .88,
                                  1
                                ]).createShader(bounds),
                        child:
                            const GalleryArt('header-v2', fit: BoxFit.cover))),
                Positioned(
                    top: 0,
                    left: 0,
                    child: GalleryIcon(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).pop(),
                        label: 'Back')),
                Positioned(
                    top: 0,
                    right: 0,
                    child: GalleryIcon(
                        icon: Icons.question_mark_rounded,
                        onTap: _help,
                        label: 'How to play')),
                Positioned(
                    top: 0,
                    right: 50,
                    child: Obx(() => GalleryIcon(
                        icon: sounds.muted.value
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        onTap: sounds.toggleMute,
                        label: sounds.muted.value
                            ? 'Enable sound'
                            : 'Mute sound'))),
                Positioned(
                    left: 0,
                    bottom: 4,
                    right: MediaQuery.sizeOf(context).width * .49,
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomLeft,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('QUIZ',
                                  style: quizText(compact ? 40 : 56,
                                          display: true,
                                          color: const Color(0xFF003BAF))
                                      .copyWith(height: .98)),
                              Text('MASTER',
                                  style: quizText(compact ? 33 : 45,
                                          display: true, color: quizOrange)
                                      .copyWith(height: 1)),
                              const SizedBox(height: 5),
                              Text('Choose your topic',
                                  style: quizText(compact ? 13 : 16,
                                      color: quizMuted)),
                            ]))),
              ])),
          SizedBox(height: gap),
          Obx(() => GalleryPanel(
              padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 14, vertical: compact ? 7 : 10),
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
                        Icons.bar_chart_rounded,
                        iconColor: quizBlue)),
              ]))),
          SizedBox(height: gap),
          Expanded(
              child: Column(children: [
            Expanded(
                flex: 6,
                child: Row(children: [
                  Expanded(child: _card(service.categories[0])),
                  SizedBox(width: gap),
                  Expanded(child: _card(service.categories[1])),
                ])),
            SizedBox(height: gap),
            Expanded(
                flex: 6,
                child: Row(children: [
                  Expanded(child: _card(service.categories[2])),
                  SizedBox(width: gap),
                  Expanded(child: _card(service.categories[3])),
                ])),
            SizedBox(height: gap),
            Expanded(flex: 5, child: _card(service.categories[4], wide: true)),
          ])),
          SizedBox(height: gap),
          GalleryButton('HOW TO PLAY',
              icon: Icons.menu_book_rounded, onTap: _help),
        ]);
      }));

  void _help() => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const QuizHelpScreen()));

  Widget _card(QuizCategory category, {bool wide = false}) => Semantics(
      button: true,
      label: 'Start ${category.name} quiz',
      child: GalleryPanel(
          padding: const EdgeInsets.all(2),
          radius: 17,
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => _setup(category),
                  child: wide && MediaQuery.sizeOf(context).height < 650
                      ? Row(children: [
                          const Expanded(
                              child: GalleryArt('technology-banner-v2')),
                          Expanded(
                              child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(category.name,
                                      style: quizText(20, display: true)))),
                          const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.chevron_right_rounded,
                                  color: quizOrange)),
                        ])
                      : Column(children: [
                          Expanded(
                              child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14)),
                                  child: SizedBox.expand(
                                      child: GalleryArt(
                                          wide
                                              ? 'technology-banner-v2'
                                              : '${category.id}-v2',
                                    fit: MediaQuery.sizeOf(context).height < 650
                                        ? BoxFit.contain
                                        : BoxFit.cover)))),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(8, 4, 6, 5),
                              child: Row(children: [
                                Expanded(
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(category.name,
                                            style:
                                                quizText(20, display: true)))),
                                Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFFF9B41),
                                              quizOrange
                                            ]),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Color(0x33D55B00),
                                              blurRadius: 3,
                                              offset: Offset(0, 2))
                                        ]),
                                    child: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Colors.white,
                                        size: 25)),
                              ])),
                        ])))));
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
