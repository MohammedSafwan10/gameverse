import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../bindings/chess_binding.dart';
import '../controllers/game_controller.dart';
import '../services/sound_service.dart';
import '../theme/chess_design.dart';
import '../widgets/game_options_dialog.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';

class ChessModeSelectionScreen extends StatelessWidget {
  const ChessModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ChessBinding().dependencies();
    return Scaffold(
      backgroundColor: const Color(0xFF031B3C),
      body: Stack(children: [
        const Positioned.fill(child: _RoyalBackground()),
        SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            // Real devices lose height to status/navigation insets. Switch to the
            // compact composition early enough that the full menu remains visible.
            final compact = constraints.maxHeight < 820;
            final veryCompact = constraints.maxHeight < 620;
            final width = constraints.maxWidth.clamp(0.0, 500.0);
            return Center(
              child: SizedBox(
                width: width,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    compact ? 12 : 16,
                    compact ? 6 : 10,
                    compact ? 12 : 16,
                    18,
                  ),
                  child: Column(children: [
                    _RoyalHero(compact: compact, veryCompact: veryCompact),
                    SizedBox(height: compact ? 8 : 12),
                    _ClassicFeature(compact: compact),
                    SizedBox(height: compact ? 8 : 12),
                    _ModePair(compact: compact),
                    SizedBox(height: compact ? 10 : 14),
                    const _HowToPlayButton(),
                  ]),
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }
}

class _RoyalHero extends StatelessWidget {
  const _RoyalHero({required this.compact, required this.veryCompact});
  final bool compact;
  final bool veryCompact;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChessGameController>();
    final height = veryCompact ? 228.0 : (compact ? 270.0 : 342.0);
    return RepaintBoundary(
      child: SizedBox(
        height: height,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(compact ? 28 : 34),
                border: Border.all(
                  color: const Color(0xFF174B86).withValues(alpha: .72),
                  width: 1.4,
                ),
                gradient: const RadialGradient(
                  center: Alignment(0, -.24),
                  radius: 1.05,
                  colors: [Color(0xFF0B4383), Color(0xFF032653)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x7700081A),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: compact ? 10 : 14,
            top: compact ? 8 : 12,
            child: _RoyalRoundButton(
              icon: Icons.arrow_back_rounded,
              onTap: Get.back,
              size: compact ? 46 : 52,
            ),
          ),
          Positioned(
            top: compact ? 1 : 5,
            left: 64,
            right: 64,
            child: Column(children: [
              Text(
                '♛',
                style: TextStyle(
                  color: const Color(0xFFFFC84A),
                  fontSize: compact ? 30 : 42,
                  height: 1,
                  shadows: const [
                    Shadow(
                        color: Colors.black87,
                        blurRadius: 8,
                        offset: Offset(0, 4)),
                  ],
                ),
              ),
              _GoldRule(width: compact ? 170 : 220),
              SizedBox(
                width: veryCompact ? 180 : (compact ? 218 : 270),
                child: Center(
                  child: Text(
                    'CHESS',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontFamily: 'BarlowCondensed',
                      color: const Color(0xFFFFE8B2),
                      fontSize: veryCompact ? 54 : (compact ? 66 : 86),
                      height: .9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      shadows: const [
                        Shadow(
                            color: Color(0xDD000A18),
                            blurRadius: 8,
                            offset: Offset(0, 6)),
                        Shadow(
                            color: Color(0xFF9D6B27),
                            blurRadius: 1,
                            offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: compact ? 2 : 5),
              Text(
                'Choose your match',
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontFamily: 'BarlowCondensed',
                  color: const Color(0xFFFFC957),
                  fontSize: compact ? 18 : 22,
                  fontWeight: FontWeight.w600,
                  shadows: const [
                    Shadow(
                        color: Colors.black87,
                        blurRadius: 5,
                        offset: Offset(0, 2))
                  ],
                ),
              ),
              const SizedBox(height: 2),
              _GoldRule(width: compact ? 132 : 165, diamond: true),
            ]),
          ),
          Positioned(
            left: veryCompact ? 44 : 30,
            right: veryCompact ? 44 : 30,
            bottom: veryCompact ? -3 : -7,
            height: veryCompact ? 112 : (compact ? 144 : 190),
            child: Image.asset(
              'assets/images/games/chess/mode_hero_v1.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned(
            right: 12,
            bottom: 10,
            child: Obx(
              () => IgnorePointer(
                ignoring: !controller.hasSavedMatch.value,
                child: AnimatedOpacity(
                  opacity: controller.hasSavedMatch.value ? 1 : 0,
                  duration: const Duration(milliseconds: 120),
                  child: _ContinuePill(controller: controller),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ClassicFeature extends StatelessWidget {
  const _ClassicFeature({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) => _RoyalSurface(
        key: const Key('chess-classic-mode'),
        height: compact ? 132 : 154,
        color: const Color(0xFFF26A0A),
        radius: compact ? 22 : 27,
        onTap: _startClassic,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: compact ? 16 : 22,
            top: compact ? 15 : 22,
            width: compact ? 150 : 190,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CLASSIC',
                  style: _display(
                    color: Colors.white,
                    size: compact ? 31 : 42,
                    shadows: true,
                  ),
                ),
                Text(
                  'Play at your own pace',
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .95),
                    fontSize: compact ? 11 : 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: compact ? 16 : 22,
            bottom: compact ? 12 : 16,
            child: _ArrowMedallion(size: compact ? 35 : 45),
          ),
          Positioned(
            right: compact ? -12 : -20,
            top: compact ? 4 : -3,
            bottom: compact ? -8 : -15,
            width: compact ? 190 : 218,
            child: Image.asset(
              'assets/images/games/chess/classic_board_v1.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
              filterQuality: FilterQuality.high,
            ),
          ),
        ]),
      ).animate().fadeIn(delay: 80.ms).slideY(begin: .04);

  Future<void> _startClassic() async {
    final controller = Get.find<ChessGameController>();
    unawaited(controller.soundService.playMenuSelectionSound());
    controller.timerEnabled.value = false;
    unawaited(controller.storageService.updateTimerEnabled(false));
    controller.startNewGame(ChessGameMode.local);
    unawaited(controller.soundService.playGameStartSound());
    await Get.to(
      () => const ChessGameScreen(),
      transition: Transition.noTransition,
    );
  }
}

class _ModePair extends StatelessWidget {
  const _ModePair({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: compact ? 190 : 220,
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _AiModeCard(compact: compact)),
          SizedBox(width: compact ? 8 : 12),
          Expanded(child: _LocalModeCard(compact: compact)),
        ]),
      ).animate().fadeIn(delay: 140.ms).slideY(begin: .035);
}

class _AiModeCard extends StatelessWidget {
  const _AiModeCard({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChessGameController>();
    return _RoyalSurface(
      key: const Key('chess-ai-mode'),
      color: const Color(0xFFFFF5DF),
      radius: compact ? 20 : 24,
      onTap: () => _ModeLauncher.open(ChessGameMode.ai),
      child: Stack(children: [
        Positioned(
          top: compact ? 10 : 13,
          left: 8,
          right: 8,
          child: Column(children: [
            Text('VS AI',
                style: _display(
                    color: ChessDesign.navyDeep, size: compact ? 27 : 36)),
            Text(
              'Challenge the computer',
              maxLines: 1,
              style: TextStyle(
                color: ChessDesign.ink.withValues(alpha: .82),
                fontSize: compact ? 9 : 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const _MiniDivider(),
          ]),
        ),
        Positioned(
          left: compact ? 24 : 28,
          right: compact ? 24 : 28,
          top: compact ? 50 : 65,
          bottom: compact ? 32 : 43,
          child: Image.asset(
            'assets/images/games/chess/ai_robot_knight_v2.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        Positioned(
          left: 6,
          right: 6,
          bottom: 6,
          child: Obx(() => _DifficultyStrip(
                selected: controller.aiDifficulty.value,
                compact: compact,
                onSelected: (level) {
                  controller.aiDifficulty.value = level;
                  controller.aiService.setDifficulty(level);
                  unawaited(
                      controller.storageService.updateAiDifficulty(level));
                  unawaited(controller.soundService.playMenuSelectionSound());
                },
              )),
        ),
      ]),
    );
  }
}

class _LocalModeCard extends StatelessWidget {
  const _LocalModeCard({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) => _RoyalSurface(
        key: const Key('chess-local-mode'),
        color: const Color(0xFFFFF5DF),
        radius: compact ? 20 : 24,
        onTap: () => _ModeLauncher.open(ChessGameMode.local),
        child: Stack(children: [
          Positioned(
            top: compact ? 10 : 13,
            left: 6,
            right: 6,
            child: Column(children: [
              FittedBox(
                child: Text(
                  'TWO PLAYER',
                  style: _display(
                    color: ChessDesign.navyDeep,
                    size: compact ? 25 : 33,
                  ),
                ),
              ),
              Text(
                'Play together',
                style: TextStyle(
                  color: ChessDesign.ink.withValues(alpha: .82),
                  fontSize: compact ? 9 : 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const _MiniDivider(),
            ]),
          ),
          Positioned(
            left: compact ? 9 : 12,
            right: compact ? 9 : 12,
            top: compact ? 55 : 72,
            bottom: compact ? 5 : 8,
            child: Image.asset(
              'assets/images/games/chess/local_kings_v1.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              filterQuality: FilterQuality.high,
            ),
          ),
        ]),
      );
}

class _DifficultyStrip extends StatelessWidget {
  const _DifficultyStrip({
    required this.selected,
    required this.compact,
    required this.onSelected,
  });
  final int selected;
  final bool compact;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(
        height: compact ? 27 : 34,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xFFFFECCC),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFB67B1D), width: 1.2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Row(children: [
          for (var i = 1; i <= 3; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == i
                        ? const Color(0xFFF17808)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: selected == i
                        ? const [
                            BoxShadow(
                                color: Color(0x55000000),
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ]
                        : null,
                  ),
                  child: Text(
                    const ['EASY', 'MEDIUM', 'HARD'][i - 1],
                    style: TextStyle(
                      fontFamily: 'BarlowCondensed',
                      color: selected == i ? Colors.white : ChessDesign.ink,
                      fontSize: compact ? 8 : 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ]),
      );
}

class _HowToPlayButton extends StatelessWidget {
  const _HowToPlayButton();

  @override
  Widget build(BuildContext context) => Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('chess-how-to-play'),
            borderRadius: BorderRadius.circular(40),
            onTap: () {
              unawaited(Get.find<ChessSoundService>().playMenuSelectionSound());
              Get.to(() => const ChessHowToPlayScreen());
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 310),
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF0D407A), Color(0xFF031E43)]),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: const Color(0xFFFFC64C), width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x88000718),
                      blurRadius: 10,
                      offset: Offset(0, 6))
                ],
              ),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0B3262),
                    border: Border.all(color: const Color(0xFFFFC64C)),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: Color(0xFFFFD56E), size: 22),
                ),
                const SizedBox(width: 11),
                const Text('✦',
                    style: TextStyle(color: Color(0xFFFFC64C), fontSize: 10)),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'HOW TO PLAY',
                      style: _display(color: const Color(0xFFFFE9B9), size: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('✦',
                    style: TextStyle(color: Color(0xFFFFC64C), fontSize: 10)),
              ]),
            ),
          ),
        ),
      );
}

class _ContinuePill extends StatelessWidget {
  const _ContinuePill({required this.controller});
  final ChessGameController controller;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFFFFBF24),
        borderRadius: BorderRadius.circular(28),
        elevation: 7,
        child: InkWell(
          key: const Key('chess-continue-match'),
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            unawaited(controller.soundService.playMenuSelectionSound());
            controller.continueSavedGame();
            Get.to(
              () => const ChessGameScreen(),
              transition: Transition.noTransition,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.play_arrow_rounded,
                  color: ChessDesign.navyDeep, size: 18),
              const SizedBox(width: 4),
              Text(
                'CONTINUE',
                style: const TextStyle(
                  fontFamily: 'BarlowCondensed',
                  color: ChessDesign.navyDeep,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ]),
          ),
        ),
      );
}

class _RoyalSurface extends StatelessWidget {
  const _RoyalSurface({
    super.key,
    required this.color,
    required this.radius,
    required this.child,
    required this.onTap,
    this.height,
  });
  final Color color;
  final double radius;
  final Widget child;
  final VoidCallback onTap;
  final double? height;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: const Color(0xFFFFD878), width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x9900081A),
                    blurRadius: 12,
                    offset: Offset(0, 7)),
                BoxShadow(
                    color: Color(0x66FFFFFF),
                    blurRadius: 1,
                    offset: Offset(0, -1)),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(radius - 2), child: child),
          ),
        ),
      );
}

class _RoyalRoundButton extends StatelessWidget {
  const _RoyalRoundButton(
      {required this.icon, required this.onTap, required this.size});
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size),
          onTap: () {
            unawaited(Get.find<ChessSoundService>().playMenuSelectionSound());
            onTap();
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                  colors: [Color(0xFF174E89), Color(0xFF031D42)]),
              border: Border.all(color: const Color(0xFFFFD06A), width: 2.2),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 8,
                    offset: Offset(0, 4))
              ],
            ),
            child: Icon(icon, color: const Color(0xFFFFE4A1), size: size * .58),
          ),
        ),
      );
}

class _ArrowMedallion extends StatelessWidget {
  const _ArrowMedallion({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF07808),
          border: Border.all(color: const Color(0xFFFFE09A), width: 2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Icon(Icons.arrow_forward_rounded,
            color: Colors.white, size: size * .62),
      );
}

class _GoldRule extends StatelessWidget {
  const _GoldRule({required this.width, this.diamond = false});
  final double width;
  final bool diamond;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: 8,
        child: Row(children: [
          const Expanded(
              child: Divider(color: Color(0xFFDC9F31), thickness: 1.2)),
          if (diamond) ...[
            const SizedBox(width: 6),
            Transform.rotate(
              angle: .785,
              child: Container(
                  width: 7, height: 7, color: const Color(0xFFFFC64C)),
            ),
            const SizedBox(width: 6),
          ],
          if (diamond)
            const Expanded(
                child: Divider(color: Color(0xFFDC9F31), thickness: 1.2)),
        ]),
      );
}

class _MiniDivider extends StatelessWidget {
  const _MiniDivider();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 92,
        child: Row(children: [
          const Expanded(
              child: Divider(color: Color(0xFFC88B2B), thickness: 1)),
          const SizedBox(width: 5),
          Transform.rotate(
            angle: .785,
            child:
                Container(width: 6, height: 6, color: const Color(0xFFD9A13B)),
          ),
          const SizedBox(width: 5),
          const Expanded(
              child: Divider(color: Color(0xFFC88B2B), thickness: 1)),
        ]),
      );
}

class _RoyalBackground extends StatelessWidget {
  const _RoyalBackground();

  @override
  Widget build(BuildContext context) => CustomPaint(
        foregroundPainter: _RoyalPatternPainter(),
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -.3),
              radius: 1.15,
              colors: [Color(0xFF0B4485), Color(0xFF031C3E), Color(0xFF010E21)],
              stops: [0, .7, 1],
            ),
          ),
        ),
      );
}

class _RoyalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF78A1CC).withValues(alpha: .045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 34.0;
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        final path = Path()
          ..moveTo(x, y + step / 2)
          ..lineTo(x + step / 2, y)
          ..lineTo(x + step, y + step / 2)
          ..lineTo(x + step / 2, y + step)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

abstract final class _ModeLauncher {
  static Future<void> open(ChessGameMode mode) async {
    final sound = Get.find<ChessSoundService>();
    unawaited(sound.playMenuSelectionSound());
    final result = await Get.dialog<Map<String, dynamic>>(
      GameOptionsDialog(mode: mode),
      barrierDismissible: false,
    );
    if (result == null) return;
    final controller = Get.find<ChessGameController>();
    controller.timerEnabled.value = result['timerEnabled'] as bool? ?? false;
    controller.timePerPlayer.value = result['timePerPlayer'] as int? ?? 10;
    unawaited(controller.storageService
        .updateTimerEnabled(controller.timerEnabled.value));
    unawaited(controller.storageService
        .updateTimePerPlayer(controller.timePerPlayer.value));
    if (mode == ChessGameMode.ai) {
      controller.aiDifficulty.value =
          result['difficulty'] as int? ?? controller.aiDifficulty.value;
      controller.aiService.setDifficulty(controller.aiDifficulty.value);
      unawaited(controller.storageService
          .updateAiDifficulty(controller.aiDifficulty.value));
    }
    controller.startNewGame(mode);
    unawaited(controller.soundService.playGameStartSound());
    await Get.to(
      () => const ChessGameScreen(),
      transition: Transition.noTransition,
    );
  }
}

TextStyle _display({
  required Color color,
  required double size,
  bool shadows = false,
}) =>
    TextStyle(
      fontFamily: 'BarlowCondensed',
      color: color,
      fontSize: size,
      height: .98,
      fontWeight: FontWeight.w800,
      letterSpacing: .3,
      shadows: shadows
          ? const [
              Shadow(
                  color: Color(0x66000000), blurRadius: 5, offset: Offset(0, 3))
            ]
          : null,
    );
