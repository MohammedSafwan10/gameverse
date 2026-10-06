import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stats_controller.dart';
import '../widgets/arcade_ui.dart';

class ConnectFourStatsScreen extends StatefulWidget {
  const ConnectFourStatsScreen({super.key});
  @override
  State<ConnectFourStatsScreen> createState() => _ConnectFourStatsScreenState();
}

class _ConnectFourStatsScreenState extends State<ConnectFourStatsScreen> {
  bool _local = false;
  @override
  Widget build(BuildContext context) {
    ensureConnectFourServices();
    final s = Get.find<ConnectFourStatsController>();
    return CFPage(
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            child: Column(children: [
              const CFHeading('STATISTICS'),
              const SizedBox(height: 20),
              CFSurface(
                  padding: const EdgeInsets.all(6),
                  child: Row(children: [
                    for (final local in [false, true])
                      Expanded(
                          child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: _local == local
                                      ? cfRed
                                      : Colors.transparent,
                                  foregroundColor:
                                      _local == local ? cfCream : cfInk),
                              onPressed: () => setState(() => _local = local),
                              child: Text(local ? 'TWO PLAYERS' : 'VS AI',
                                  style: cfText(16,
                                      color:
                                          _local == local ? cfCream : cfInk)))),
                  ])),
              const SizedBox(height: 18),
              Obx(() {
                final played = _local
                    ? s.multiplayerGamesPlayed.value
                    : s.gamesPlayed.value;
                final won = _local ? s.player1Wins.value : s.playerWins.value;
                final lost = _local ? s.player2Wins.value : s.aiWins.value;
                final draws = _local ? s.multiplayerDraws.value : s.draws.value;
                final rate = played == 0 ? 0 : ((won / played) * 100).round();
                return CFSurface(
                    child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                            'assets/images/games/memory_match/trophy_v1.png',
                            height: 110,
                            width: 110),
                        SizedBox(
                            width: 120,
                            height: 120,
                            child:
                                Stack(alignment: Alignment.center, children: [
                              SizedBox.expand(
                                  child: CircularProgressIndicator(
                                      value: (rate / 100).clamp(0.0, 1.0),
                                      strokeWidth: 7,
                                      color: const Color(0xFFF2AF16),
                                      backgroundColor:
                                          const Color(0xFFE9D8B7))),
                              Column(mainAxisSize: MainAxisSize.min, children: [
                                Text('$rate%', style: cfText(35)),
                                Text(_local ? 'RED WIN RATE' : 'WIN RATE',
                                    style: cfText(12)),
                              ]),
                            ])),
                      ]),
                  const SizedBox(height: 18),
                  Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      spacing: 22,
                      runSpacing: 14,
                      children: [
                        _Stat('PLAYED', played),
                        _Stat(_local ? 'RED WINS' : 'WON', won),
                        _Stat('DRAWS', draws),
                        _Stat(_local ? 'YELLOW WINS' : 'LOST', lost),
                      ]),
                ]));
              }),
              const SizedBox(height: 18),
              if (!_local) ...[
                Obx(() => CFSurface(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('WINS BY DIFFICULTY', style: cfText(23)),
                          const SizedBox(height: 14),
                          _Line('Easy', s.easyWins.value),
                          _Line('Medium', s.mediumWins.value),
                          _Line('Hard', s.hardWins.value),
                        ]))),
                const SizedBox(height: 18),
                Obx(() => CFSurface(
                        child: Column(children: [
                      Text('STREAKS', style: cfText(23)),
                      const SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _Stat('CURRENT', s.currentStreak.value),
                            _Stat('BEST', s.bestStreak.value),
                          ]),
                    ]))),
                const SizedBox(height: 24),
              ],
              CFButton(
                  label: 'RESET STATISTICS',
                  onTap: () async {
                    if (await cfConfirm(context,
                        title: 'RESET STATISTICS?',
                        message:
                            'Clear results for this mode? This cannot be undone.',
                        action: 'RESET')) {
                      if (_local) {
                        s.resetMultiplayerStats();
                      } else {
                        s.resetSinglePlayerStats();
                      }
                    }
                  }),
            ])));
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text('$value', style: cfText(29)),
        const SizedBox(height: 4),
        Text(label, style: cfText(12)),
      ]);
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        Expanded(child: Text(label, style: cfText(18))),
        Text('$value wins', style: cfText(18))
      ]));
}
