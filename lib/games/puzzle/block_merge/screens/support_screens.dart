import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../widgets/resin_ui.dart';

class BlockMergeHelpScreen extends StatelessWidget {
  const BlockMergeHelpScreen({super.key});
  @override
  Widget build(BuildContext context) => ResinPage(
          child: ListView(padding: const EdgeInsets.all(16), children: [
        ResinHeader('HOW TO PLAY', back: () => Get.back()),
        const SizedBox(height: 16),
        Text('Learn the basics',
            style: resinText(21), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        _lesson(
            '1  SWIPE',
            'Swipe anywhere on the board. Every tile slides in that direction.',
            const Icon(Icons.swipe_rounded, size: 66, color: resinInk)),
        _lesson(
            '2  MERGE',
            'Equal tiles become one. Each tile can merge only once per swipe.',
            const SizedBox(
                height: 66,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox.square(dimension: 58, child: ResinTile(8)),
                  Text(' + ',
                      style: TextStyle(
                          fontFamily: 'BlockResin',
                          fontSize: 22,
                          color: resinInk)),
                  SizedBox.square(dimension: 58, child: ResinTile(8)),
                  Icon(Icons.arrow_forward, color: resinInk),
                  SizedBox.square(dimension: 58, child: ResinTile(16)),
                ]))),
        _lesson(
            '3  REACH 2048',
            'Build bigger tiles and reach 2048. Keep playing after the milestone.',
            const SizedBox.square(dimension: 78, child: ResinTile(2048))),
        ResinSurface(
            child: Text(
                'CLASSIC · No clock\nTIME CHALLENGE · Three minutes of active play\nZEN · Relaxed, untimed play\n\nOne undo restores the last valid move, not the clock. A full board ends a run if no pairs can merge.',
                style: resinText(15, weight: FontWeight.w600))),
        const SizedBox(height: 16),
        ResinButton('GOT IT', onTap: () => Get.back()),
      ]));
  Widget _lesson(String title, String text, Widget art) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ResinSurface(
          child: Column(children: [
        Text(title, style: resinText(23)),
        const SizedBox(height: 12),
        art,
        const SizedBox(height: 14),
        Text(text,
            textAlign: TextAlign.center,
            style: resinText(16, weight: FontWeight.w600))
      ])));
}

Future<void> resetBlockStatistics(
    BuildContext context, BlockMergeSettingsController settings) async {
  if (await resinConfirm(
      context,
      'RESET STATISTICS?',
      'This clears your scores and records. Your preferences stay unchanged.',
      'RESET',
      icon: Icons.bar_chart_rounded,
      cancelLabel: 'CANCEL')) {
    settings.resetStatistics();
  }
}

class BlockMergeStatisticsScreen extends StatelessWidget {
  const BlockMergeStatisticsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Get.find<BlockMergeSettingsController>();
    return ResinPage(
        child: ListView(padding: const EdgeInsets.all(16), children: [
      ResinHeader('STATISTICS', back: () => Get.back()),
      const SizedBox(height: 16),
      const ResinArt('trophy', height: 160),
      Obx(() => ResinStat('BEST SCORE', '${s.bestScore.value}')),
      const SizedBox(height: 14),
      Obx(() => Column(children: [
            Row(children: [
              Expanded(
                  child: ResinStat('GAMES PLAYED', '${s.gamesPlayed.value}')),
              const SizedBox(width: 12),
              Expanded(child: ResinStat('2048 REACHED', '${s.gamesWon.value}'))
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: ResinStat('HIGHEST TILE', '${s.highestTile.value}')),
              const SizedBox(width: 12),
              Expanded(child: ResinStat('WIN RATE', s.getWinRate()))
            ]),
          ])),
      const ResinArt('objects', height: 130),
      ResinButton('RESET STATISTICS',
          color: resinMint, onTap: () => resetBlockStatistics(context, s)),
      const SizedBox(height: 16),
      Text('Saved on this device',
          style: resinText(14), textAlign: TextAlign.center),
    ]));
  }
}
