import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bindings/game_binding.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/resin_ui.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'support_screens.dart';

class BlockMergeModeSelectionScreen extends StatefulWidget {
  const BlockMergeModeSelectionScreen({super.key});
  @override
  State<BlockMergeModeSelectionScreen> createState() =>
      _BlockMergeModeSelectionScreenState();
}

class _BlockMergeModeSelectionScreenState
    extends State<BlockMergeModeSelectionScreen> {
  late final BlockMergeSettingsController settings;
  late final BlockMergeController game;
  @override
  void initState() {
    super.initState();
    BlockMergeBinding().dependencies();
    settings = Get.find<BlockMergeSettingsController>();
    game = Get.find<BlockMergeController>();
    game.setPaused(true);
    if (settings.soundEnabled.value) unawaited(game.audio.preload());
  }

  Future<void> start(BlockMergeMode mode) async {
    game.startMode(mode);
    await Get.to(() => const BlockMergeGameScreen());
    game.setPaused(true);
  }

  @override
  Widget build(BuildContext context) {
    return ResinPage(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: ResinViewport(builder: (context, box) {
              final compact = box.maxHeight < 650;
              final scale = MediaQuery.textScalerOf(context).scale(1);
              return Column(children: [
                Row(children: [
                  ResinIcon(Icons.arrow_back_rounded,
                      label: 'Back', onTap: () => Get.back()),
                  const Spacer(),
                  ResinIcon(Icons.bar_chart_rounded,
                      label: 'Statistics',
                      onTap: () =>
                          Get.to(() => const BlockMergeStatisticsScreen())),
                  const SizedBox(width: 10),
                  ResinIcon(Icons.settings_rounded,
                      label: 'Settings',
                      onTap: () =>
                          Get.to(() => const BlockMergeSettingsScreen())),
                ]),
                const SizedBox(height: 6),
                Expanded(
                    child: Stack(children: [
                  Positioned.fill(
                      top: compact ? 94 : 113, child: const ResinArt('hero')),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('BLOCK\nMERGE',
                                style: resinText(compact ? 32 : 52)),
                            const SizedBox(height: 4),
                            Text('Choose your mode',
                                style: resinText(compact ? 16 : 20,
                                    weight: FontWeight.w600)),
                          ])),
                ])),
                Obx(() => ResinSurface(
                    radius: 30,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                    color: resinMint,
                    child: Text('BEST  ${settings.bestScore.value}',
                        style: resinText(19)))),
                const SizedBox(height: 10),
                SizedBox(
                    height: (compact ? 90 : 103) * scale,
                    child: _ModeCard(
                        title: 'CLASSIC',
                        subtitle: 'Swipe. Merge. Reach 2048.',
                        art: 'objects',
                        color: resinCoral,
                        onTap: () => start(BlockMergeMode.classic))),
                const SizedBox(height: 10),
                SizedBox(
                    height: (compact ? 112 : 142) * scale,
                    child: Row(children: [
                      Expanded(
                          child: _ModeCard(
                              title: 'TIME\nCHALLENGE',
                              subtitle: 'Beat the clock.',
                              art: 'clock',
                              color: resinMint,
                              small: true,
                              onTap: () =>
                                  start(BlockMergeMode.timeChallenge))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _ModeCard(
                              title: 'ZEN',
                              subtitle: 'Play at your pace.',
                              art: 'zen',
                              color: resinLilac,
                              small: true,
                              onTap: () => start(BlockMergeMode.zen))),
                    ])),
                const SizedBox(height: 12),
                ResinButton('HOW TO PLAY',
                    color: const Color(0xFFF5F4E9),
                    icon: Icons.menu_book_rounded,
                    onTap: () => Get.to(() => const BlockMergeHelpScreen())),
              ]);
            })));
  }
}

class _ModeCard extends StatelessWidget {
  final String title, subtitle, art;
  final Color color;
  final VoidCallback onTap;
  final bool small;
  const _ModeCard(
      {required this.title,
      required this.subtitle,
      required this.art,
      required this.color,
      required this.onTap,
      this.small = false});
  @override
  Widget build(BuildContext context) => Semantics(
      button: true,
      label: title.replaceAll('\n', ' '),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: ResinSurface(
                  color: color,
                  padding: const EdgeInsets.all(12),
                  child: Stack(fit: StackFit.expand, children: [
                    Positioned(
                        right: small ? -10 : 5,
                        bottom: small ? -8 : -12,
                        width: small ? 65 : 105,
                        height: small ? 48 : 90,
                        child: ResinArt(art)),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: resinText(small ? 19 : 25)),
                          const SizedBox(height: 5),
                          SizedBox(
                              width: small
                                  ? 110
                                  : MediaQuery.sizeOf(context).width * .53,
                              child: Text(subtitle,
                                  style: resinText(small ? 12 : 14,
                                      weight: FontWeight.w600))),
                          if (small) ...[
                            const Spacer(),
                            const Icon(Icons.arrow_forward_rounded,
                                color: resinInk, size: 22),
                          ],
                        ]),
                  ])))));
}
