import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../bindings/game_binding.dart';
import '../widgets/arcade_ui.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

void startConnectFour(GameMode mode) {
  ensureConnectFourServices();
  Get.to(() => const ConnectFourGameScreen(),
          binding: ConnectFourBinding(gameMode: mode),
          transition: Transition.fadeIn)
      ?.then((_) {
    if (Get.isRegistered<ConnectFourController>()) {
      Get.delete<ConnectFourController>();
    }
  });
}

class ConnectFourModeScreen extends StatelessWidget {
  const ConnectFourModeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    ensureConnectFourServices();
    return CFPage(child: LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final gap = w * .035;
      return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(children: [
            Row(children: [
              CFIcon(
                  icon: Icons.arrow_back_rounded,
                  label: 'Back',
                  onTap: () => Get.back()),
              const Spacer(),
              CFIcon(
                  icon: Icons.bar_chart_rounded,
                  label: 'Statistics',
                  onTap: () => Get.to(() => const ConnectFourStatsScreen())),
              const SizedBox(width: 10),
              CFIcon(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  onTap: () => Get.to(() => ConnectFourSettingsScreen())),
            ]),
            const SizedBox(height: 4),
            const CFTitle(),
            Text('Choose your match', style: cfText(21, color: cfCream)),
            Image.asset('${cfAssets}hero.png',
                width: w,
                height: w * .66,
                fit: BoxFit.contain,
                excludeFromSemantics: true),
            _ModeCard(
                title: 'PLAY VS AI',
                subtitle: 'Challenge the computer',
                red: false,
                onTap: () => Get.to(() => const ConnectFourDifficultyScreen())),
            SizedBox(height: gap),
            _ModeCard(
                title: 'TWO PLAYERS',
                subtitle: 'Play with a friend',
                red: true,
                onTap: () => startConnectFour(GameMode.pvp)),
            SizedBox(height: gap * 1.4),
            CFButton(
                label: 'HOW TO PLAY',
                icon: Icons.menu_book_rounded,
                onTap: () => Get.to(() => const ConnectFourHelpScreen())),
          ]));
    }));
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard(
      {required this.title,
      required this.subtitle,
      required this.red,
      required this.onTap});
  final String title, subtitle;
  final bool red;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final small = box.maxWidth < 330;
        return Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(22),
                child: CFSurface(
                    color: red ? cfRed : cfCream,
                    padding: EdgeInsets.all(small ? 12 : 16),
                    child: Row(children: [
                      Expanded(
                          flex: 6,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    style: cfText(small ? 23 : 27,
                                        color: red ? cfCream : cfInk)),
                                const SizedBox(height: 6),
                                Text(subtitle,
                                    style: cfText(small ? 13 : 15,
                                        color: red ? cfCream : cfInk,
                                        weight: FontWeight.w600)),
                              ])),
                      Expanded(flex: 3, child: CFPair(height: small ? 65 : 78)),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: red ? cfCream : cfInk, size: 24),
                    ]))));
      });
}

class ConnectFourDifficultyScreen extends StatelessWidget {
  const ConnectFourDifficultyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    ensureConnectFourServices();
    final settings = Get.find<ConnectFourSettingsController>();
    return CFPage(
        child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 26),
            child: Column(children: [
              const CFHeading('PLAY VS AI'),
              const SizedBox(height: 20),
              Text('Choose your challenge', style: cfText(23, color: cfCream)),
              const CFPair(height: 160),
              for (final d in AIDifficulty.values)
                Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Obx(() => Semantics(
                        selected: settings.difficulty.value == d,
                        button: true,
                        child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => settings.setDifficulty(d),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                        color: settings.difficulty.value == d
                                            ? cfRed
                                            : Colors.transparent,
                                        width: 3)),
                                child: CFSurface(
                                    child: Row(children: [
                                  const CFPair(height: 52),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(d.name.toUpperCase(),
                                            style: cfText(25)),
                                        Text(
                                            switch (d) {
                                              AIDifficulty.easy =>
                                                'A relaxed start',
                                              AIDifficulty.medium =>
                                                'Plan your next move',
                                              AIDifficulty.hard =>
                                                'Think a few moves ahead'
                                            },
                                            style: cfText(14)),
                                      ])),
                                  if (settings.difficulty.value == d)
                                    const Icon(Icons.check_circle_rounded,
                                        color: cfRed, size: 28),
                                ]))))))),
              const SizedBox(height: 12),
              CFButton(
                  label: 'START GAME',
                  red: true,
                  onTap: () => startConnectFour(GameMode.vsAI)),
            ])));
  }
}

class ConnectFourHelpScreen extends StatelessWidget {
  const ConnectFourHelpScreen({super.key});
  @override
  Widget build(BuildContext context) => CFPage(
      child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 26),
          child: Column(children: [
            const CFHeading('HOW TO PLAY'),
            const CFPair(height: 105),
            _Rule(
                title: 'DROP A DISC',
                copy:
                    'Tap a column. Your disc falls into its lowest empty space.',
                diagram:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.arrow_downward_rounded,
                      color: cfInk, size: 36),
                  const SizedBox(width: 12),
                  const CFDisc(red: true, size: 48),
                ])),
            const SizedBox(height: 16),
            _Rule(
                title: 'CONNECT FOUR',
                copy:
                    'Connect four of your discs horizontally, vertically or diagonally.',
                diagram: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          4, (_) => const CFDisc(red: true, size: 40))),
                  const SizedBox(height: 10),
                  SizedBox(
                      width: 180,
                      height: 126,
                      child: Stack(children: [
                        for (var i = 0; i < 4; i++)
                          Positioned(
                              left: 20,
                              top: i * 30,
                              child: const CFDisc(red: true, size: 30)),
                        for (var i = 0; i < 4; i++)
                          Positioned(
                              left: 65 + i * 28,
                              top: 90 - i * 30,
                              child: const CFDisc(red: true, size: 30)),
                      ])),
                ])),
            const SizedBox(height: 16),
            _Rule(
                title: 'BLOCK YOUR RIVAL',
                copy:
                    'Watch for their next winning move and block it. A full board with no four in a row is a draw.',
                diagram:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < 4; i++) CFDisc(red: i == 3, size: 40),
                ])),
            const SizedBox(height: 22),
            CFButton(label: 'GOT IT', red: true, onTap: () => Get.back()),
          ])));
}

class _Rule extends StatelessWidget {
  const _Rule({required this.title, required this.copy, required this.diagram});
  final String title, copy;
  final Widget diagram;
  @override
  Widget build(BuildContext context) => CFSurface(
          child: Column(children: [
        Text(title, style: cfText(24)),
        const SizedBox(height: 10),
        Text(copy,
            textAlign: TextAlign.center,
            style: cfText(16, weight: FontWeight.w600)),
        const SizedBox(height: 16),
        diagram,
      ]));
}
