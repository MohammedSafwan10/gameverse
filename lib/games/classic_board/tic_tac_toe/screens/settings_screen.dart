import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../models/game_mode.dart';
import '../widgets/tactile_ui.dart';

class TicTacToeSettingsScreen extends StatelessWidget {
  const TicTacToeSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TicTacToeSettingsController>();
    return TactilePage(
        builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: TactileIcon(Icons.arrow_back_rounded,
                      label: 'Back', onPressed: () => Get.back())),
              const SizedBox(height: 16),
              Row(children: [
                const Expanded(child: TactileTitle('SETTINGS')),
                Image.asset('${tttAssets}paired-pieces.png',
                    width: 95, height: 65),
              ]),
              const SizedBox(height: 20),
              Obx(() {
                final s = controller.settings;
                return Column(children: [
                  _group('GAMEPLAY', [
                    _row(
                        'Game mode',
                        s.gameMode == GameMode.singlePlayer
                            ? 'VS AI'
                            : 'Two players',
                        Icons.desktop_windows_rounded, () async {
                      final mode = await showDialog<GameMode>(
                          context: context,
                          builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: TactileSurface(
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                    const TactileTitle('GAME MODE', size: 30),
                                    const SizedBox(height: 18),
                                    for (final mode in GameMode.values)
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: TactileButton(
                                              mode == GameMode.singlePlayer
                                                  ? 'VS AI'
                                                  : 'TWO PLAYERS',
                                              primary: mode == s.gameMode,
                                              onPressed: () => Navigator.pop(
                                                  context, mode))),
                                  ]))));
                      if (mode != null) controller.updateGameMode(mode);
                    }),
                    if (s.gameMode == GameMode.singlePlayer)
                      _row(
                          'Difficulty',
                          s.difficulty.displayName,
                          Icons.bar_chart_rounded,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (pageContext) =>
                                      TactileDifficultyPage(
                                          initial: s.difficulty,
                                          startGame: false,
                                          onSelected: (difficulty) {
                                            controller
                                                .updateDifficulty(difficulty);
                                            Navigator.pop(pageContext);
                                          })))),
                    _toggle('Auto restart', Icons.restart_alt_rounded,
                        s.autoRestart, controller.toggleAutoRestart),
                  ]),
                  _group('SOUND & HAPTICS', [
                    _toggle('Sound effects', Icons.volume_up_rounded,
                        s.soundEnabled, controller.toggleSound),
                    _toggle('Vibration', Icons.vibration_rounded,
                        s.vibrationEnabled, controller.toggleVibration),
                  ]),
                  _group('STATISTICS', [
                    _row(
                        'Reset current mode stats', '', Icons.bar_chart_rounded,
                        () async {
                      if (await tactileConfirm(context,
                          title: 'RESET MODE STATS?',
                          message: 'This cannot be undone.',
                          action: 'RESET')) {
                        await controller.resetCurrentModeStats();
                      }
                    }),
                    _row('Reset all stats', '', Icons.delete_outline_rounded,
                        () async {
                      if (await tactileConfirm(context,
                          title: 'RESET ALL STATS?',
                          message:
                              'All game statistics and achievements will be cleared.',
                          action: 'RESET')) {
                        await controller.resetAllStats();
                      }
                    }),
                  ]),
                  TactileButton('RESTORE DEFAULTS', icon: Icons.restore_rounded,
                      onPressed: () async {
                    if (await tactileConfirm(context,
                        title: 'RESET SETTINGS?',
                        message: 'Restore the default game settings?',
                        action: 'RESTORE')) {
                      controller.resetToDefaults();
                    }
                  }),
                ]);
              }),
              const SizedBox(height: 20),
            ])));
  }

  Widget _group(String title, List<Widget> rows) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TactileSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: tttText(27, heavy: true)),
        const SizedBox(height: 8),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const Divider(color: Color(0xFFDDC6A2)),
          rows[i]
        ],
      ])));
  Widget _row(String label, String value, IconData icon, VoidCallback onTap) =>
      Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    Icon(icon, color: tttInk),
                    const SizedBox(width: 12),
                    Expanded(child: Text(label, style: tttText(16))),
                    if (value.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(value, style: tttText(14))
                    ],
                    const Icon(Icons.chevron_right_rounded, color: tttInk)
                  ]))));
  Widget _toggle(
          String label, IconData icon, bool value, VoidCallback onChanged) =>
      Row(children: [
        Icon(icon, color: tttInk),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: tttText(16))),
        Switch(
            value: value,
            activeThumbColor: tttCream,
            activeTrackColor: tttOrange,
            onChanged: (_) => onChanged()),
      ]);
}
