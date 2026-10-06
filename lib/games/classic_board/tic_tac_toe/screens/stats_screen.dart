import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stats_controller.dart';
import '../models/achievement.dart';
import '../models/game_difficulty.dart';
import '../models/player.dart';
import '../widgets/tactile_ui.dart';

class TicTacToeStatsScreen extends StatefulWidget {
  const TicTacToeStatsScreen({super.key});
  @override
  State<TicTacToeStatsScreen> createState() => _TicTacToeStatsScreenState();
}

class _TicTacToeStatsScreenState extends State<TicTacToeStatsScreen> {
  bool local = false;
  @override
  Widget build(BuildContext context) => TactilePage(
      builder: (context, c) => SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            Align(
                alignment: Alignment.centerLeft,
                child: TactileIcon(Icons.arrow_back_rounded,
                    label: 'Back', onPressed: () => Get.back())),
            const SizedBox(height: 16),
            const TactileTitle('STATISTICS'),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                  child: TactileButton('VS AI',
                      primary: !local,
                      onPressed: () => setState(() => local = false))),
              const SizedBox(width: 10),
              Expanded(
                  child: TactileButton('TWO PLAYERS',
                      primary: local,
                      onPressed: () => setState(() => local = true)))
            ]),
            const SizedBox(height: 20),
            Obx(() {
              final s = Get.find<TicTacToeStatsController>().stats;
              final mp = s.multiplayerStats;
              final played = local ? mp.gamesPlayed : s.gamesPlayed;
              final won = local ? mp.player1Wins : s.gamesWon;
              final draws = local ? mp.draws : s.gamesDrawn;
              final lost = local ? mp.player2Wins : s.gamesLost;
              final rate = played == 0 ? 0.0 : won / played;
              return Column(children: [
                TactileSurface(
                    child: Column(children: [
                  Row(children: [
                    Image.asset(
                        'assets/images/games/memory_match/trophy_v1.png',
                        height: 85,
                        width: 80),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(children: [
                      Text(local ? 'PLAYER 1 WIN RATE' : 'WIN RATE',
                          textAlign: TextAlign.center,
                          style: tttText(22, heavy: true)),
                      Text('${(rate * 100).round()}%',
                          style: tttText(48, heavy: true)),
                    ])),
                    SizedBox(
                        width: 45,
                        height: 45,
                        child: CircularProgressIndicator(
                            value: rate.clamp(0.0, 1.0),
                            color: tttOrange,
                            backgroundColor: const Color(0xFFE5CDAA),
                            strokeWidth: 7)),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: _metric('PLAYED', played, null)),
                    const SizedBox(width: 8),
                    Expanded(
                        child:
                            _metric(local ? 'P1 WINS' : 'WON', won, Player.x)),
                    const SizedBox(width: 8),
                    Expanded(child: _metric('DRAWS', draws, Player.o)),
                  ]),
                  const SizedBox(height: 12),
                  Text(local ? 'Player 2 wins: $lost' : 'Lost: $lost',
                      style: tttText(14)),
                  if (played == 0)
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('Play your first round to start tracking.',
                            textAlign: TextAlign.center, style: tttText(14))),
                ])),
                const SizedBox(height: 18),
                if (!local)
                  TactileSurface(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('BY DIFFICULTY', style: tttText(28, heavy: true)),
                        const SizedBox(height: 10),
                        for (final d in GameDifficulty.values)
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              child: Row(children: [
                                Expanded(
                                    child: Text(d.displayName,
                                        style: tttText(17))),
                                Row(
                                    children: List.generate(
                                        4,
                                        (i) => Padding(
                                            padding: const EdgeInsets.all(3),
                                            child: CircleAvatar(
                                                radius: 5,
                                                backgroundColor: i <= d.index
                                                    ? tttOrange
                                                    : const Color(
                                                        0xFFE2CBAA))))),
                                const SizedBox(width: 12),
                                Text(
                                    '${s.difficultyStats[d]?.gamesWon ?? 0} wins',
                                    style: tttText(17)),
                              ])),
                      ])),
                const SizedBox(height: 18),
                TactileSurface(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('ACHIEVEMENTS', style: tttText(28, heavy: true)),
                      const SizedBox(height: 12),
                      Wrap(spacing: 14, runSpacing: 14, children: [
                        for (final a in Achievement.values)
                          Semantics(
                              label:
                                  '${a.title}: ${a.description}. ${s.unlockedAchievements.contains(a) ? 'Unlocked' : 'Locked'}',
                              child: SizedBox(
                                  width:
                                      (c.maxWidth.clamp(0.0, 560.0) - 90) / 2,
                                  child: Column(children: [
                                    Icon(a.icon,
                                        size: 40,
                                        color:
                                            s.unlockedAchievements.contains(a)
                                                ? const Color(0xFFE9A20B)
                                                : const Color(0xFFBCA988)),
                                    Text(a.title,
                                        textAlign: TextAlign.center,
                                        style: tttText(18, heavy: true)),
                                    Text(a.description,
                                        textAlign: TextAlign.center,
                                        style: tttText(12)),
                                  ]))),
                      ]),
                    ])),
              ]);
            }),
            const SizedBox(height: 18),
          ])));
  Widget _metric(String label, int value, Player? p) => TactileSurface(
      radius: 18,
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        if (p != null)
          TactilePiece(p, size: 28)
        else
          const Icon(Icons.tag_rounded, color: tttInk, size: 28),
        Text(label, style: tttText(18, heavy: true)),
        Text('$value', style: tttText(36, heavy: true))
      ]));
}
