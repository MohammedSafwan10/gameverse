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
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Row(children: [
              TactileIcon(Icons.arrow_back_rounded,
                  label: 'Back', onPressed: () => Get.back()),
              const SizedBox(width: 12),
              const Expanded(child: TactileTitle('STATISTICS', size: 32))
            ]),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
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
                    padding: const EdgeInsets.all(12),
                    child: Column(children: [
                      Row(children: [
                        Image.asset(
                            'assets/images/games/memory_match/trophy_v1.png',
                            height: 65,
                            width: 65),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(children: [
                          Text(local ? 'PLAYER 1 WIN RATE' : 'WIN RATE',
                              textAlign: TextAlign.center,
                              style: tttText(19, heavy: true)),
                          Text('${(rate * 100).round()}%',
                              style: tttText(38, heavy: true)),
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
                            child: _metric(
                                local ? 'P1 WINS' : 'WON', won, Player.x)),
                        const SizedBox(width: 8),
                        Expanded(child: _metric('DRAWS', draws, Player.o)),
                      ]),
                      const SizedBox(height: 8),
                      Text(local ? 'Player 2 wins: $lost' : 'Lost: $lost',
                          style: tttText(14)),
                    ])),
                const SizedBox(height: 8),
                if (!local)
                  TactileSurface(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BY DIFFICULTY',
                                style: tttText(24, heavy: true)),
                            const SizedBox(height: 10),
                            for (final d in GameDifficulty.values)
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(children: [
                                    Expanded(
                                        child: Text(d.displayName,
                                            style: tttText(17))),
                                    Row(
                                        children: List.generate(
                                            4,
                                            (i) => Padding(
                                                padding:
                                                    const EdgeInsets.all(3),
                                                child: CircleAvatar(
                                                    radius: 5,
                                                    backgroundColor:
                                                        i <= d.index
                                                            ? tttOrange
                                                            : const Color(
                                                                0xFFE2CBAA))))),
                                    const SizedBox(width: 12),
                                    Text(
                                        '${s.difficultyStats[d]?.gamesWon ?? 0} wins',
                                        style: tttText(17)),
                                  ])),
                          ])),
                const SizedBox(height: 8),
                TactileSurface(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ACHIEVEMENTS', style: tttText(24, heavy: true)),
                          const SizedBox(height: 8),
                          Wrap(spacing: 10, runSpacing: 10, children: [
                            for (final a in Achievement.values)
                              Semantics(
                                  label:
                                      '${a.title}: ${a.description}. ${s.unlockedAchievements.contains(a) ? 'Unlocked' : 'Locked'}',
                                  child: _AchievementBadge(
                                      achievement: a,
                                      unlocked:
                                          s.unlockedAchievements.contains(a),
                                      width:
                                          (c.maxWidth.clamp(0.0, 560.0) - 80) /
                                              2)),
                          ]),
                        ])),
              ]);
            }),
            const SizedBox(height: 8),
          ])));
  Widget _metric(String label, int value, Player? p) => Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (p != null) ...[
            TactilePiece(p, size: 20),
            const SizedBox(width: 4)
          ],
          Flexible(child: Text('$value', style: tttText(30, heavy: true))),
        ]),
        Text(label, style: tttText(15, heavy: true)),
      ]);
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge(
      {required this.achievement, required this.unlocked, required this.width});
  final Achievement achievement;
  final bool unlocked;
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: width,
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: TactileSurface(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(achievement.icon,
                            size: 44, color: unlocked ? tttOrange : tttInk),
                        const SizedBox(height: 8),
                        TactileTitle(achievement.title, size: 28),
                        const SizedBox(height: 8),
                        Text(achievement.description,
                            textAlign: TextAlign.center, style: tttText(17)),
                        const SizedBox(height: 8),
                        Text(unlocked ? 'Unlocked' : 'Not unlocked yet',
                            style: tttText(14)),
                        const SizedBox(height: 20),
                        TactileButton('CLOSE',
                            onPressed: () => Navigator.pop(dialogContext)),
                      ])))),
              child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(children: [
                    Icon(achievement.icon,
                        size: 25,
                        color: unlocked
                            ? const Color(0xFFE9A20B)
                            : const Color(0xFFBCA988)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(achievement.title,
                            style: tttText(16, heavy: true))),
                  ])))));
}
