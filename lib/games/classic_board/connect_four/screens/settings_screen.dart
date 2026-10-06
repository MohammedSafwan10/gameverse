import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';
import '../widgets/arcade_ui.dart';

class ConnectFourSettingsScreen extends StatelessWidget {
  const ConnectFourSettingsScreen({super.key});
  Future<void> _choose<T>(BuildContext context, String title, List<T> values,
      T selected, String Function(T) label, void Function(T) change) async {
    final value = await showDialog<T>(
        context: context,
        builder: (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            child: CFSurface(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(title, style: cfText(25)),
              const SizedBox(height: 14),
              for (final item in values)
                Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CFButton(
                        label: label(item),
                        red: item == selected,
                        onTap: () => Navigator.pop(dialogContext, item))),
            ]))));
    if (value != null) change(value);
  }

  @override
  Widget build(BuildContext context) {
    ensureConnectFourServices();
    final s = Get.find<ConnectFourSettingsController>();
    return CFPage(
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            child: Column(children: [
              const CFHeading('SETTINGS'),
              const CFPair(height: 115),
              Obx(() => _Section(title: 'GAMEPLAY', children: [
                    _Choice(
                        label: 'Mode',
                        value: s.gameMode.value == GameMode.vsAI
                            ? 'VS AI'
                            : 'Two players',
                        onTap: () => _choose(
                            context,
                            'MODE',
                            GameMode.values,
                            s.gameMode.value,
                            (m) => m == GameMode.vsAI ? 'VS AI' : 'TWO PLAYERS',
                            s.setGameMode)),
                    _Choice(
                        label: 'AI difficulty',
                        value: s.difficulty.value.name.toUpperCase(),
                        onTap: () => _choose(
                            context,
                            'DIFFICULTY',
                            AIDifficulty.values,
                            s.difficulty.value,
                            (d) => d.name.toUpperCase(),
                            s.setDifficulty)),
                    _Toggle(
                        label: 'Auto restart',
                        value: s.isAutoRestartEnabled.value,
                        onTap: s.toggleAutoRestart),
                  ])),
              const SizedBox(height: 18),
              Obx(() => _Section(title: 'SOUND & HAPTICS', children: [
                    _Toggle(
                        label: 'Sound effects',
                        value: s.isSoundEnabled.value,
                        onTap: s.toggleSound),
                    _Toggle(
                        label: 'Haptic feedback',
                        value: s.isVibrationEnabled.value,
                        onTap: s.toggleVibration),
                  ])),
              const SizedBox(height: 18),
              _Section(title: 'STATISTICS', children: [
                _Choice(
                    label: 'Reset all statistics',
                    value: '',
                    onTap: () async {
                      if (await cfConfirm(context,
                          title: 'RESET STATISTICS?',
                          message:
                              'All Connect Four results and streaks will be cleared.',
                          action: 'RESET STATISTICS')) {
                        Get.find<ConnectFourStatsController>().resetAllStats();
                      }
                    })
              ]),
              const SizedBox(height: 24),
              CFButton(
                  label: 'RESTORE DEFAULTS',
                  onTap: () async {
                    if (await cfConfirm(context,
                        title: 'RESTORE DEFAULTS?',
                        message: 'Reset your Connect Four preferences?',
                        action: 'RESTORE')) {
                      s.resetToDefaults();
                    }
                  }),
            ])));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => CFSurface(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: cfText(23)),
        const SizedBox(height: 12),
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1)
            const Divider(color: Color(0xFFD9C8AA), height: 16)
        ],
      ]));
}

class _Choice extends StatelessWidget {
  const _Choice(
      {required this.label, required this.value, required this.onTap});
  final String label, value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(children: [
            Expanded(child: Text(label, style: cfText(17))),
            const SizedBox(width: 8),
            Text(value, style: cfText(14)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: cfInk),
          ])));
}

class _Toggle extends StatelessWidget {
  const _Toggle(
      {required this.label, required this.value, required this.onTap});
  final String label;
  final bool value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(label, style: cfText(17))),
        Switch(
            value: value,
            onChanged: (_) => onTap(),
            activeThumbColor: cfCream,
            activeTrackColor: cfRed,
            inactiveThumbColor: cfCream,
            inactiveTrackColor: const Color(0xFFACABAD)),
      ]);
}
