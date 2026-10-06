import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/game_mode.dart';
import '../services/navigation_service.dart';
import '../widgets/tactile_ui.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});
  void _start(GameMode mode) {
    Get.find<TicTacToeSettingsController>().updateGameMode(mode);
    Get.find<TicTacToeGameController>().resetGame();
    Get.find<TicTacToeNavigationService>().toGame();
  }

  @override
  Widget build(BuildContext context) => TactilePage(builder: (context, c) {
        final compact = c.maxHeight < 650;
        return TactileViewportContent(
            padding: EdgeInsets.all(compact ? 12 : 16),
            builder: (context) => Column(children: [
                  Row(children: [
                    TactileIcon(Icons.arrow_back_rounded,
                        label: 'Back', onPressed: () => Get.back()),
                    const Spacer(),
                    TactileIcon(Icons.bar_chart_rounded,
                        label: 'Statistics',
                        onPressed:
                            Get.find<TicTacToeNavigationService>().toStats),
                    const SizedBox(width: 12),
                    TactileIcon(Icons.settings_rounded,
                        label: 'Settings',
                        onPressed:
                            Get.find<TicTacToeNavigationService>().toSettings)
                  ]),
                  const SizedBox(height: 4),
                  TactileGameTitle(size: compact ? 38 : 50),
                  const SizedBox(height: 8),
                  Text('Choose your match', style: tttText(compact ? 18 : 21)),
                  Expanded(
                      child: Image.asset('${tttAssets}hero-board.png',
                          fit: BoxFit.contain)),
                  _mode('PLAY VS AI', 'Challenge the computer', tttOrange,
                      compact, () async {
                    final settings = Get.find<TicTacToeSettingsController>();
                    await Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (setupContext) => TactileDifficultyPage(
                            initial: settings.settings.difficulty,
                            onSelected: (difficulty) {
                              settings.updateDifficulty(difficulty);
                              Navigator.pop(setupContext);
                              _start(GameMode.singlePlayer);
                            })));
                  }),
                  SizedBox(height: compact ? 10 : 12),
                  _mode('TWO PLAYERS', 'Play with a friend', tttBlue, compact,
                      () => _start(GameMode.multiPlayer)),
                  SizedBox(height: compact ? 10 : 16),
                  TactileButton('HOW TO PLAY',
                      icon: Icons.menu_book_rounded,
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (_) => const TactileHelpPage()))),
                ]));
      });
  Widget _mode(String title, String subtitle, Color color, bool compact,
          VoidCallback onTap) =>
      Semantics(
          button: true,
          label: '$title. $subtitle',
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(24),
                  child: TactileSurface(
                      color: color,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: compact ? 6 : 10),
                      child: Row(children: [
                        Expanded(
                            flex: 5,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: tttText(compact ? 24 : 28,
                                          color: Colors.white, heavy: true)),
                                  const SizedBox(height: 4),
                                  Text(subtitle,
                                      style: tttText(13, color: Colors.white)),
                                ])),
                        Expanded(
                            flex: 3,
                            child: Image.asset('${tttAssets}paired-pieces.png',
                                height: compact ? 48 : 80)),
                        const SizedBox(width: 4),
                        const CircleAvatar(
                            radius: 17,
                            backgroundColor: tttCream,
                            child: Icon(Icons.chevron_right_rounded,
                                color: tttInk)),
                      ])))));
}
