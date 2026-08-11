import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../bindings/chess_binding.dart';
import '../controllers/game_controller.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';
import '../theme/chess_design.dart';
import '../widgets/game_options_dialog.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';
import 'settings_screen.dart';

class ChessModeSelectionScreen extends StatelessWidget {
  const ChessModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ChessBinding().dependencies();
    final shortest = MediaQuery.sizeOf(context).height;
    final compact = shortest < 700;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: ChessDesign.background),
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth.clamp(0, 520).toDouble();
            return Center(
              child: SizedBox(
                width: width,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, compact ? 8 : 14, 16, 24),
                  child: Column(children: [
                    _TopBar(compact: compact),
                    SizedBox(height: compact ? 10 : 18),
                    _Hero(compact: compact),
                    SizedBox(height: compact ? 12 : 18),
                    _ModeCard(
                      key: const Key('chess-ai-mode'),
                      title: 'PLAY VS AI',
                      subtitle: 'Challenge a clever rival',
                      image: 'assets/images/games/chess/ai_knight_v1.png',
                      accent: ChessDesign.orange,
                      mode: ChessGameMode.ai,
                      compact: compact,
                    ),
                    const SizedBox(height: 12),
                    _ModeCard(
                      key: const Key('chess-local-mode'),
                      title: 'TWO PLAYERS',
                      subtitle: 'Share the board with a friend',
                      image: 'assets/images/games/chess/local_kings_v1.png',
                      accent: ChessDesign.teal,
                      mode: ChessGameMode.local,
                      compact: compact,
                    ),
                    const SizedBox(height: 14),
                    const _StatsStrip(),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: () =>
                            Get.to(() => const ChessHowToPlayScreen()),
                        icon: const Icon(Icons.menu_book_rounded),
                        label: const Text('HOW TO PLAY'),
                        style: FilledButton.styleFrom(
                          foregroundColor: ChessDesign.ink,
                          backgroundColor: ChessDesign.ivory,
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w900, letterSpacing: 1.2),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.compact});
  final bool compact;
  @override
  Widget build(BuildContext context) => Row(children: [
        _RoundButton(icon: Icons.arrow_back_rounded, onTap: Get.back),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Text('CHESS',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2)),
          if (!compact)
            Text('THINK • PLAN • WIN',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: .62),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5)),
        ]),
        const SizedBox(width: 12),
        _RoundButton(
            icon: Icons.settings_rounded,
            onTap: () => Get.to(() => const ChessSettingsScreen())),
      ]);
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: ChessDesign.ivory,
        shape: const CircleBorder(),
        elevation: 7,
        shadowColor: Colors.black45,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            Get.find<ChessSoundService>().playMenuSelectionSound();
            onTap();
          },
          child: SizedBox(
              width: 48, height: 48, child: Icon(icon, color: ChessDesign.ink)),
        ),
      );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.compact});
  final bool compact;
  @override
  Widget build(BuildContext context) => Container(
        height: compact ? 132 : 172,
        padding: const EdgeInsets.only(left: 20),
        decoration: ChessDesign.ivoryPanel(radius: 28),
        child: Row(children: [
          const Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('CHESS',
                    style: TextStyle(
                        color: ChessDesign.orange,
                        fontSize: 35,
                        height: .92,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.8)),
                SizedBox(height: 10),
                Text('Choose your match',
                    style: TextStyle(
                        color: ChessDesign.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
              ])),
          Expanded(
            child: Image.asset('assets/images/games/chess/mode_hero_v1.png',
                fit: BoxFit.contain),
          ),
        ]),
      ).animate().fadeIn(duration: 350.ms).slideY(begin: .06);
}

class _ModeCard extends StatelessWidget {
  const _ModeCard(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.image,
      required this.accent,
      required this.mode,
      required this.compact});
  final String title;
  final String subtitle;
  final String image;
  final Color accent;
  final ChessGameMode mode;
  final bool compact;

  @override
  Widget build(BuildContext context) => Material(
        color: accent,
        borderRadius: BorderRadius.circular(26),
        elevation: 8,
        shadowColor: Colors.black38,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: _start,
          child: SizedBox(
            height: compact ? 104 : 124,
            child: Row(children: [
              const SizedBox(width: 18),
              Expanded(
                  child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.4)),
                      const SizedBox(height: 5),
                      Text(subtitle,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: .9),
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Icon(Icons.arrow_circle_right_rounded,
                          color: Colors.white, size: 28),
                    ]),
              )),
              SizedBox(
                  width: compact ? 118 : 145,
                  child: Image.asset(image, fit: BoxFit.contain)),
              const SizedBox(width: 6),
            ]),
          ),
        ),
      );

  Future<void> _start() async {
    Get.find<ChessSoundService>().playMenuSelectionSound();
    final result = await Get.dialog<Map<String, dynamic>>(
        GameOptionsDialog(mode: mode),
        barrierDismissible: false);
    if (result == null) return;
    final controller = Get.find<ChessGameController>();
    controller.timerEnabled.value = result['timerEnabled'] as bool? ?? false;
    controller.timePerPlayer.value = result['timePerPlayer'] as int? ?? 10;
    controller.storageService.updateTimerEnabled(controller.timerEnabled.value);
    controller.storageService
        .updateTimePerPlayer(controller.timePerPlayer.value);
    if (mode == ChessGameMode.ai) {
      controller.aiDifficulty.value = result['difficulty'] as int? ?? 2;
      controller.aiService.setDifficulty(controller.aiDifficulty.value);
      controller.storageService
          .updateAiDifficulty(controller.aiDifficulty.value);
    }
    controller.startNewGame(mode);
    controller.soundService.playGameStartSound();
    Get.to(() => const ChessGameScreen(), transition: Transition.fadeIn);
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip();
  @override
  Widget build(BuildContext context) {
    final storage = Get.find<ChessStorageService>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: ChessDesign.ivoryPanel(radius: 22),
      child: Obx(() =>
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _stat('PLAYED', storage.gamesPlayed, ChessDesign.navy),
            _stat('WON', storage.gamesWon, const Color(0xFF138A65)),
            _stat('LOST', storage.gamesLost, ChessDesign.red),
          ])),
    );
  }

  Widget _stat(String label, int value, Color color) => Column(children: [
        Text('$value',
            style: TextStyle(
                color: color, fontSize: 21, fontWeight: FontWeight.w900)),
        Text(label,
            style: const TextStyle(
                color: ChessDesign.ink,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1)),
      ]);
}
