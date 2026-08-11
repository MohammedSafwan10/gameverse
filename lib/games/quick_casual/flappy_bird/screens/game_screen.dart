import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/bird_widget.dart';
import '../widgets/pipe_widget.dart';

class FlappyBirdGameScreen extends StatefulWidget {
  const FlappyBirdGameScreen({super.key});

  @override
  State<FlappyBirdGameScreen> createState() => _FlappyBirdGameScreenState();
}

class _FlappyBirdGameScreenState extends State<FlappyBirdGameScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  Timer? _inputGateTimer;
  bool _acceptsFlightInput = false;
  late final AnimationController _ambient;

  FlappyBirdGameController get _game => Get.find<FlappyBirdGameController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    _inputGateTimer = Timer(const Duration(milliseconds: 450), () {
      if (mounted) _acceptsFlightInput = true;
    });
  }

  @override
  void dispose() {
    _inputGateTimer?.cancel();
    _ambient.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleFlightTap() {
    if (_acceptsFlightInput) _game.jump();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _game.pauseGame();
    }
  }

  Future<bool> _confirmExit(
    BuildContext context,
    FlappyBirdGameController controller,
    _FlightPalette palette,
  ) async {
    if (controller.gameOver.value) return true;
    controller.pauseGame();
    final leave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: .62),
      builder: (dialogContext) => _FlightDialog(
        palette: palette,
        icon: Icons.logout_rounded,
        title: 'LEAVE FLIGHT?',
        message: 'Your current score will not be saved.',
        primaryLabel: 'KEEP FLYING',
        onPrimary: () => Navigator.pop(dialogContext, false),
        secondaryLabel: 'LEAVE',
        onSecondary: () => Navigator.pop(dialogContext, true),
      ),
    );
    if (leave != true) controller.resumeGame();
    return leave ?? false;
  }

  Future<void> _requestExit(
    BuildContext context,
    FlappyBirdGameController controller,
    _FlightPalette palette,
  ) async {
    if (!await _confirmExit(context, controller, palette)) return;
    controller.gameTimer?.cancel();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<FlappyBirdSettingsController>();
    return Obx(() {
      final cyber = settings.currentTheme.value == FlappyBirdTheme.cyberpunk;
      final palette = _FlightPalette(cyber);

      return GetBuilder<FlappyBirdGameController>(
        builder: (controller) => PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _requestExit(context, controller, palette);
          },
          child: Scaffold(
            backgroundColor: palette.background,
            body: Stack(
              fit: StackFit.expand,
              children: [
                _AmbientWorld(cyber: cyber, animation: _ambient),
                if (cyber)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x2200D9FF),
                          Colors.transparent,
                          Color(0x4404071B)
                        ],
                        stops: [0, .54, 1],
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _handleFlightTap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ...controller.pipes.map(
                          (pipe) => PipeWidget(pipe: pipe, isCyber: cyber),
                        ),
                        BirdWidget(bird: controller.bird, isCyber: cyber),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _GameHud(
                      controller: controller,
                      palette: palette,
                      onBack: () => _requestExit(context, controller, palette),
                    ),
                  ),
                ),
                if (!controller.gameRunning.value && !controller.gameOver.value)
                  _ReadyOverlay(palette: palette, onTap: _handleFlightTap),
                if (controller.isPaused.value && !controller.gameOver.value)
                  _PausedOverlay(
                    palette: palette,
                    onResume: controller.resumeGame,
                    onRestart: controller.restartGame,
                    onExit: () => _requestExit(context, controller, palette),
                  ),
                if (controller.gameOver.value)
                  _GameOverOverlay(
                    controller: controller,
                    palette: palette,
                    onMenu: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _AmbientWorld extends StatelessWidget {
  const _AmbientWorld({required this.cyber, required this.animation});

  final bool cyber;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final phase = animation.value * math.pi * 2;
          return Stack(
            fit: StackFit.expand,
            children: [
              Transform.translate(
                offset: Offset(math.sin(phase) * 5, math.cos(phase) * 3),
                child: Transform.scale(
                  scale: 1.035,
                  child: RepaintBoundary(
                    child: Image.asset(
                      cyber
                          ? 'assets/images/games/flappy_bird/game_cyber_background.png'
                          : 'assets/images/games/flappy_bird/game_classic_background.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.medium,
                      cacheWidth: 1024,
                    ),
                  ),
                ),
              ),
              if (cyber)
                CustomPaint(painter: _CyberDustPainter(animation.value))
              else ...[
                _DriftingCloud(
                  progress: animation.value,
                  viewportWidth: constraints.maxWidth,
                  top: constraints.maxHeight * .22,
                  width: constraints.maxWidth * .42,
                  start: .08,
                  speed: .62,
                  opacity: .34,
                ),
                _DriftingCloud(
                  progress: animation.value,
                  viewportWidth: constraints.maxWidth,
                  top: constraints.maxHeight * .56,
                  width: constraints.maxWidth * .3,
                  start: .64,
                  speed: .42,
                  opacity: .22,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DriftingCloud extends StatelessWidget {
  const _DriftingCloud({
    required this.progress,
    required this.viewportWidth,
    required this.top,
    required this.width,
    required this.start,
    required this.speed,
    required this.opacity,
  });

  final double progress;
  final double viewportWidth;
  final double top;
  final double width;
  final double start;
  final double speed;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final travel = viewportWidth + width;
    final x = ((start + progress * speed) % 1) * travel - width;
    return Positioned(
      left: x,
      top: top,
      width: width,
      child: Opacity(
        opacity: opacity,
        child: RepaintBoundary(
          child: Image.asset(
            'assets/images/games/flappy_bird/game_classic_cloud.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            cacheWidth: 384,
          ),
        ),
      ),
    );
  }
}

class _CyberDustPainter extends CustomPainter {
  const _CyberDustPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 22; i++) {
      final seed = i * 0.61803398875;
      final x = ((seed + progress * (.035 + (i % 4) * .008)) % 1) * size.width;
      final y =
          ((seed * 1.73 + progress * (.12 + (i % 5) * .018)) % 1) * size.height;
      final color =
          i.isEven ? const Color(0xFF27E8FF) : const Color(0xFFFF3ED1);
      final alpha = .12 + (i % 4) * .045;
      final radius = 1.1 + (i % 3) * .55;
      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }
  }

  @override
  bool shouldRepaint(_CyberDustPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _GameHud extends StatelessWidget {
  const _GameHud({
    required this.controller,
    required this.palette,
    required this.onBack,
  });

  final FlappyBirdGameController controller;
  final _FlightPalette palette;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    if (controller.gameOver.value || controller.isPaused.value) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RoundHudButton(
          icon: Icons.arrow_back_rounded,
          palette: palette,
          onTap: onBack,
          semanticLabel: 'Back',
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '${controller.score.value}',
                style: TextStyle(
                  color: palette.text,
                  fontSize: 56,
                  height: .92,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  shadows: palette.textShadows,
                ),
              ),
              const SizedBox(height: 5),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.pill,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: palette.border, width: 1.5),
                  boxShadow: palette.shadows,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Text(
                    'BEST  ${controller.highScore.value}',
                    style: TextStyle(
                      color: palette.pillText,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _RoundHudButton(
          icon: Icons.pause_rounded,
          palette: palette,
          onTap: controller.pauseGame,
          semanticLabel: 'Pause',
        ),
      ],
    );
  }
}

class _RoundHudButton extends StatelessWidget {
  const _RoundHudButton({
    required this.icon,
    required this.palette,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final _FlightPalette palette;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: palette.button,
        shape: CircleBorder(side: BorderSide(color: palette.border, width: 2)),
        elevation: palette.cyber ? 0 : 5,
        shadowColor: Colors.black45,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Icon(icon, color: palette.buttonIcon, size: 28),
          ),
        ),
      ),
    );
  }
}

class _ReadyOverlay extends StatelessWidget {
  const _ReadyOverlay({required this.palette, required this.onTap});

  final _FlightPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 110),
          child: GestureDetector(
            onTap: onTap,
            child: _FlightPanel(
              palette: palette,
              maxWidth: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded,
                      color: palette.accent, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    'TAP TO FLY',
                    style: TextStyle(
                      color: palette.panelText,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap anywhere to flap',
                    style: TextStyle(
                      color: palette.panelText.withValues(alpha: .68),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PausedOverlay extends StatelessWidget {
  const _PausedOverlay({
    required this.palette,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  final _FlightPalette palette;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return _DimmedOverlay(
      child: _FlightPanel(
        palette: palette,
        maxWidth: 326,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration:
                  BoxDecoration(color: palette.accent, shape: BoxShape.circle),
              child: Icon(Icons.pause_rounded,
                  color: palette.accentText, size: 36),
            ),
            const SizedBox(height: 16),
            Text('FLIGHT PAUSED', style: _panelTitle(palette)),
            const SizedBox(height: 22),
            _PrimaryFlightButton(
              palette: palette,
              label: 'RESUME',
              icon: Icons.play_arrow_rounded,
              onTap: onResume,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SecondaryFlightButton(
                    palette: palette,
                    label: 'RESTART',
                    icon: Icons.refresh_rounded,
                    onTap: onRestart,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SecondaryFlightButton(
                    palette: palette,
                    label: 'EXIT',
                    icon: Icons.logout_rounded,
                    onTap: onExit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  const _GameOverOverlay({
    required this.controller,
    required this.palette,
    required this.onMenu,
  });

  final FlappyBirdGameController controller;
  final _FlightPalette palette;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final isBest = controller.score.value > 0 &&
        controller.score.value >= controller.highScore.value;
    return _DimmedOverlay(
      child: _FlightPanel(
        palette: palette,
        maxWidth: 336,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBest ? Icons.emoji_events_rounded : Icons.flight_land_rounded,
              color: palette.accent,
              size: 52,
            ),
            const SizedBox(height: 8),
            Text(isBest ? 'NEW BEST!' : 'NICE FLIGHT!',
                style: _panelTitle(palette)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _ScoreTile(
                    palette: palette,
                    label: 'SCORE',
                    value: '${controller.score.value}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ScoreTile(
                    palette: palette,
                    label: 'BEST',
                    value: '${controller.highScore.value}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _PrimaryFlightButton(
              palette: palette,
              label: 'FLY AGAIN',
              icon: Icons.replay_rounded,
              onTap: controller.restartGame,
            ),
            const SizedBox(height: 10),
            _SecondaryFlightButton(
              palette: palette,
              label: 'BACK TO SKIES',
              icon: Icons.grid_view_rounded,
              onTap: onMenu,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({
    required this.palette,
    required this.label,
    required this.value,
  });

  final _FlightPalette palette;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: palette.tile,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border.withValues(alpha: .75)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: palette.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: palette.panelText,
                  fontSize: 30,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _DimmedOverlay extends StatelessWidget {
  const _DimmedOverlay({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: .5),
        child: SafeArea(
          minimum: const EdgeInsets.all(18),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _FlightPanel extends StatelessWidget {
  const _FlightPanel({
    required this.palette,
    required this.child,
    required this.maxWidth,
  });

  final _FlightPalette palette;
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: palette.panel,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: palette.border, width: 2),
            boxShadow: palette.panelShadows,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FlightDialog extends StatelessWidget {
  const _FlightDialog({
    required this.palette,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final _FlightPalette palette;
  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: _FlightPanel(
        palette: palette,
        maxWidth: 330,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: palette.accent, size: 44),
            const SizedBox(height: 10),
            Text(title, style: _panelTitle(palette)),
            const SizedBox(height: 7),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: palette.muted,
                    height: 1.35,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            _PrimaryFlightButton(
                palette: palette,
                label: primaryLabel,
                icon: Icons.play_arrow_rounded,
                onTap: onPrimary),
            const SizedBox(height: 8),
            TextButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel,
                    style: TextStyle(
                        color: palette.muted, fontWeight: FontWeight.w900))),
          ],
        ),
      ),
    );
  }
}

class _PrimaryFlightButton extends StatelessWidget {
  const _PrimaryFlightButton(
      {required this.palette,
      required this.label,
      required this.icon,
      required this.onTap});
  final _FlightPalette palette;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.accentText,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .6),
        ),
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _SecondaryFlightButton extends StatelessWidget {
  const _SecondaryFlightButton(
      {required this.palette,
      required this.label,
      required this.icon,
      required this.onTap});
  final _FlightPalette palette;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.panelText,
          side: BorderSide(color: palette.border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
        icon: Icon(icon, size: 19),
        label: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      ),
    );
  }
}

TextStyle _panelTitle(_FlightPalette palette) => TextStyle(
      color: palette.panelText,
      fontSize: 25,
      fontWeight: FontWeight.w900,
      letterSpacing: .5,
    );

class _FlightPalette {
  const _FlightPalette(this.cyber);
  final bool cyber;

  Color get background =>
      cyber ? const Color(0xFF03071E) : const Color(0xFF21BDE6);
  Color get text => Colors.white;
  Color get button => cyber ? const Color(0xD9141935) : const Color(0xFFFFF6DF);
  Color get buttonIcon =>
      cyber ? const Color(0xFF62F5FF) : const Color(0xFF07345D);
  Color get border => cyber ? const Color(0xFF40E8FF) : const Color(0xFFFFF2D0);
  Color get pill => cyber ? const Color(0xE3131834) : const Color(0xE9074569);
  Color get pillText => cyber ? const Color(0xFF67F4FF) : Colors.white;
  Color get panel => cyber ? const Color(0xEF090F2A) : const Color(0xF9FFF7E5);
  Color get panelText => cyber ? Colors.white : const Color(0xFF092E4D);
  Color get muted => cyber ? const Color(0xFF9EADD1) : const Color(0xFF587083);
  Color get tile => cyber ? const Color(0xFF111A3A) : const Color(0xFFFFEBC1);
  Color get accent => cyber ? const Color(0xFF20E7FF) : const Color(0xFFFFA800);
  Color get accentText =>
      cyber ? const Color(0xFF04101A) : const Color(0xFF102B42);

  List<Shadow> get textShadows => [
        Shadow(
            color: Colors.black.withValues(alpha: .55),
            blurRadius: 7,
            offset: const Offset(0, 2)),
        if (cyber) const Shadow(color: Color(0xFF00D9FF), blurRadius: 18),
      ];

  List<BoxShadow> get shadows => [
        BoxShadow(
            color: Colors.black.withValues(alpha: .22),
            blurRadius: 8,
            offset: const Offset(0, 4)),
      ];

  List<BoxShadow> get panelShadows => [
        BoxShadow(
            color: Colors.black.withValues(alpha: .38),
            blurRadius: 30,
            offset: const Offset(0, 15)),
        if (cyber)
          BoxShadow(
              color: const Color(0xFF00D9FF).withValues(alpha: .18),
              blurRadius: 26),
      ];
}
