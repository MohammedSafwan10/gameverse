import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:gameverse/widgets/guarded_exit.dart';

import '../bindings/game_binding.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

const _classicHero = 'assets/images/games/flappy_bird/mode_classic_hero.png';
const _cyberHero = 'assets/images/games/flappy_bird/mode_cyber_hero.png';
const _classicTitle = 'assets/images/games/flappy_bird/title_classic.png';
const _cyberTitle = 'assets/images/games/flappy_bird/title_cyber.png';

class FlappyBirdModeSelectionScreen extends StatefulWidget {
  const FlappyBirdModeSelectionScreen({super.key});

  @override
  State<FlappyBirdModeSelectionScreen> createState() =>
      _FlappyBirdModeSelectionScreenState();
}

class _FlappyBirdModeSelectionScreenState
    extends State<FlappyBirdModeSelectionScreen> {
  late final FlappyBirdGameController gameController;
  late final FlappyBirdSettingsController settingsController;

  @override
  void initState() {
    super.initState();
    FlappyBirdBinding().dependencies();
    gameController = Get.find<FlappyBirdGameController>();
    settingsController = Get.find<FlappyBirdSettingsController>();
    gameController.loadHighScore();
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final cyber =
        settingsController.currentTheme.value == FlappyBirdTheme.cyberpunk;
    final palette = _FlightPalette(cyber);
    return await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: .66),
          builder: (dialogContext) => _FlightDialog(
            palette: palette,
            icon: Icons.flight_land_rounded,
            title: 'LEAVE THE HANGAR?',
            message: 'Your best score and flight history are already safe.',
            primaryLabel: 'LEAVE',
            onPrimary: () => Navigator.pop(dialogContext, true),
          ),
        ) ??
        false;
  }

  void _startFlight() {
    gameController.initGame();
    Get.to(
      () => const FlappyBirdGameScreen(),
      binding: FlappyBirdBinding(),
      transition: Transition.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _confirmExit(context);
        if (!shouldPop || !context.mounted) return;
        Get.delete<FlappyBirdGameController>();
        await popAfterConfirmation(context, confirmExit: () async => true);
      },
      child: Obx(() {
        final cyber =
            settingsController.currentTheme.value == FlappyBirdTheme.cyberpunk;
        final palette = _FlightPalette(cyber);
        return Scaffold(
          backgroundColor: palette.background,
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(gradient: palette.pageGradient),
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 700;
                  final veryCompact = constraints.maxHeight < 610;
                  final heroHeight = veryCompact
                      ? 292.0
                      : compact
                          ? (constraints.maxHeight * .53).clamp(330.0, 390.0)
                          : (constraints.maxHeight * .56).clamp(420.0, 500.0);
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        children: [
                          _HeroPanel(
                            cyber: cyber,
                            palette: palette,
                            height: heroHeight,
                            compact: compact,
                            onBack: () => popAfterConfirmation(
                              context,
                              confirmExit: () => _confirmExit(context),
                            ),
                            onSettings: () => Get.to(
                              () => const FlappyBirdSettingsScreen(),
                              transition: Transition.fadeIn,
                            ),
                            best: gameController.gameStats.value.highScore,
                          ),
                          _ControlDeck(
                            cyber: cyber,
                            palette: palette,
                            compact: compact,
                            veryCompact: veryCompact,
                            minimumHeight: constraints.maxHeight - heroHeight,
                            settingsController: settingsController,
                            onPlay: _startFlight,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.cyber,
    required this.palette,
    required this.height,
    required this.compact,
    required this.onBack,
    required this.onSettings,
    required this.best,
  });

  final bool cyber;
  final _FlightPalette palette;
  final double height;
  final bool compact;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final int best;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 480),
            switchInCurve: Curves.easeOut,
            child: SizedBox.expand(
              key: ValueKey(cyber),
              child: Image.asset(
                cyber ? _cyberHero : _classicHero,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -.18),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, .22, .73, 1],
                colors: cyber
                    ? const [
                        Color(0x9E000617),
                        Color(0x16000617),
                        Colors.transparent,
                        Color(0xFF0A1028),
                      ]
                    : [
                        const Color(0x2E66D9FA),
                        Colors.transparent,
                        Colors.transparent,
                        palette.deck,
                      ],
              ),
            ),
          ),
          Positioned(
            top: compact ? 32 : 42,
            left: compact ? 68 : 72,
            right: compact ? 68 : 72,
            height: compact ? 105 : 126,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              child: Image.asset(
                cyber ? _cyberTitle : _classicTitle,
                key: ValueKey('title-$cyber'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 16,
            child: _RoundAction(
              icon: Icons.arrow_back_rounded,
              onTap: onBack,
              palette: palette,
            ),
          ),
          Positioned(
            top: 14,
            right: 16,
            child: _RoundAction(
              icon: Icons.settings_rounded,
              onTap: onSettings,
              palette: palette,
            ),
          ),
          Positioned(
            top: compact ? 137 : 164,
            left: 0,
            right: 0,
            child: Center(child: _BestBadge(best: best, palette: palette)),
          ),
        ],
      ),
    );
  }
}

class _ControlDeck extends StatelessWidget {
  const _ControlDeck({
    required this.cyber,
    required this.palette,
    required this.compact,
    required this.veryCompact,
    required this.minimumHeight,
    required this.settingsController,
    required this.onPlay,
  });

  final bool cyber;
  final _FlightPalette palette;
  final bool compact;
  final bool veryCompact;
  final double minimumHeight;
  final FlappyBirdSettingsController settingsController;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.sizeOf(context).width < 360 ? 12.0 : 16.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      constraints: BoxConstraints(minHeight: minimumHeight),
      padding: EdgeInsets.fromLTRB(
        horizontal,
        compact ? 4 : 6,
        horizontal,
        MediaQuery.paddingOf(context).bottom + (compact ? 12 : 18),
      ),
      decoration: BoxDecoration(
        color: palette.deck,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OrnamentHeading(
            title: cyber ? 'SELECT YOUR WORLD' : 'CHOOSE YOUR SKY',
            palette: palette,
            compact: compact,
          ),
          SizedBox(height: compact ? 6 : 9),
          Row(
            children: [
              Expanded(
                child: _ThemeCard(
                  key: const Key('flappy-theme-classic'),
                  selected: !cyber,
                  title: 'CLASSIC',
                  subtitle: 'SUNNY SKIES',
                  asset: _classicHero,
                  palette: palette,
                  compact: compact,
                  onTap: () =>
                      settingsController.setTheme(FlappyBirdTheme.classic),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ThemeCard(
                  key: const Key('flappy-theme-cyber'),
                  selected: cyber,
                  title: 'CYBER',
                  subtitle: 'NEON CITY',
                  asset: _cyberHero,
                  palette: palette,
                  compact: compact,
                  onTap: () =>
                      settingsController.setTheme(FlappyBirdTheme.cyberpunk),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 13 : 18),
          _LaunchButton(
            cyber: cyber,
            palette: palette,
            compact: veryCompact,
            onTap: onPlay,
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    super.key,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.palette,
    required this.compact,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String asset;
  final _FlightPalette palette;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$title theme',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          height: compact ? 112 : 146,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? palette.accent : palette.cardBorder,
              width: selected ? 2.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: palette.accent.withValues(alpha: .25),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                bottom: compact ? 39 : 48,
                child: Image.asset(
                  asset,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -.1),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: compact ? 40 : 49,
                  width: double.infinity,
                  color: title == 'CLASSIC'
                      ? (selected
                          ? const Color(0xFFFFB516)
                          : const Color(0xFFFFE8A1))
                      : (selected && palette.cyber
                          ? const Color(0xFFDB1E9D)
                          : const Color(0xFF11183B)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: title == 'CLASSIC'
                              ? const Color(0xFF092A48)
                              : Colors.white,
                          fontFamily: 'BarlowCondensed',
                          fontSize: compact ? 19 : 23,
                          fontWeight: FontWeight.w800,
                          height: .9,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: title == 'CLASSIC'
                              ? const Color(0xFF29435B)
                              : const Color(0xFFD5D8F4),
                          fontSize: compact ? 7 : 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .65,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  left: 7,
                  top: 7,
                  child: Container(
                    width: compact ? 24 : 29,
                    height: compact ? 24 : 29,
                    decoration: BoxDecoration(
                      color: palette.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        size: compact ? 17 : 20, color: palette.onAccent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LaunchButton extends StatelessWidget {
  const _LaunchButton({
    required this.cyber,
    required this.palette,
    required this.compact,
    required this.onTap,
  });

  final bool cyber;
  final _FlightPalette palette;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: palette.accent.withValues(alpha: cyber ? .4 : .25),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: compact ? 52 : 58,
          decoration: BoxDecoration(
            gradient: palette.buttonGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.buttonBorder, width: 1.4),
          ),
          child: InkWell(
            key: const Key('flappy-launch'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: palette.onAccent.withValues(alpha: .18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cyber ? Icons.rocket_launch_rounded : Icons.flight_rounded,
                    color: palette.onAccent,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      cyber ? 'LAUNCH FLIGHT' : 'TAP TO FLY',
                      maxLines: 1,
                      style: TextStyle(
                        color: palette.onAccent,
                        fontFamily: 'BarlowCondensed',
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    color: palette.onAccent, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BestBadge extends StatelessWidget {
  const _BestBadge({required this.best, required this.palette});
  final int best;
  final _FlightPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: const Color(0xE8083857),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x4D001B2B), blurRadius: 8, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'BEST',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'BarlowCondensed',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$best',
            style: TextStyle(
              color: palette.cyber
                  ? const Color(0xFF25E6FF)
                  : const Color(0xFFFFD426),
              fontFamily: 'BarlowCondensed',
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrnamentHeading extends StatelessWidget {
  const _OrnamentHeading({
    required this.title,
    required this.palette,
    required this.compact,
  });
  final String title;
  final _FlightPalette palette;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
              height: 1.5, color: palette.heading.withValues(alpha: .55)),
        ),
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(left: 5),
          decoration:
              BoxDecoration(color: palette.heading, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: palette.heading,
            fontFamily: 'BarlowCondensed',
            fontSize: compact ? 20 : 24,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 5),
          decoration:
              BoxDecoration(color: palette.heading, shape: BoxShape.circle),
        ),
        Expanded(
          child: Container(
              height: 1.5, color: palette.heading.withValues(alpha: .55)),
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.onTap,
    required this.palette,
  });
  final IconData icon;
  final VoidCallback onTap;
  final _FlightPalette palette;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.action,
      shape: CircleBorder(side: BorderSide(color: palette.actionBorder)),
      elevation: 4,
      shadowColor: Colors.black45,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: palette.actionIcon, size: 22),
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
  });
  final _FlightPalette palette;
  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final primary = palette.accent;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: palette.deck,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: palette.cardBorder, width: 1.3),
          boxShadow: [
            BoxShadow(color: palette.shadow, blurRadius: 30, spreadRadius: 6),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .14),
                shape: BoxShape.circle,
                border: Border.all(color: primary.withValues(alpha: .5)),
              ),
              child: Icon(icon, color: primary, size: 27),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.heading,
                fontFamily: 'BarlowCondensed',
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.muted, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.heading,
                      side: BorderSide(color: palette.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('STAY'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onPrimary,
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: palette.onAccent,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(primaryLabel,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
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

class _FlightPalette {
  _FlightPalette(this.cyber);
  final bool cyber;

  Color get background =>
      cyber ? const Color(0xFF030717) : const Color(0xFFD8F6E7);
  Color get heroFallback =>
      cyber ? const Color(0xFF05091D) : const Color(0xFF40C6F1);
  Color get deck => cyber ? const Color(0xF20A1028) : const Color(0xFFFFFBED);
  Color get card => cyber ? const Color(0xFF121A38) : const Color(0xFFFFFFFF);
  Color get heading =>
      cyber ? const Color(0xFFF6FAFF) : const Color(0xFF092A48);
  Color get muted => cyber ? const Color(0xFF91A1C8) : const Color(0xFF66798A);
  Color get accent => cyber ? const Color(0xFFFF2CAB) : const Color(0xFFFF7B22);
  Color get secondaryAccent =>
      cyber ? const Color(0xFF25E6FF) : const Color(0xFF1AAE82);
  Color get onAccent => Colors.white;
  Color get heroBorder =>
      cyber ? const Color(0xFF25E6FF) : const Color(0xFFFFF3C9);
  Color get deckBorder =>
      cyber ? const Color(0xFF293C71) : const Color(0xFFE7DDBE);
  Color get cardBorder =>
      cyber ? const Color(0xFF334674) : const Color(0xFFDDE7DC);
  Color get action => cyber ? const Color(0xD90C1534) : const Color(0xFFFFF8E8);
  Color get actionBorder =>
      cyber ? const Color(0xFF25E6FF) : const Color(0xFFFFFFFF);
  Color get actionIcon =>
      cyber ? const Color(0xFF25E6FF) : const Color(0xFF092A48);
  Color get stats => cyber ? const Color(0xE80A1029) : const Color(0xEFFFFBF0);
  Color get statsBorder =>
      cyber ? const Color(0xFF2B4B7A) : const Color(0xCCFFFFFF);
  Color get buttonBorder =>
      cyber ? const Color(0xFF25E6FF) : const Color(0xFFFFA064);
  Color get shadow => cyber ? const Color(0x99000000) : const Color(0x3D123A48);

  LinearGradient get pageGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: cyber
            ? const [Color(0xFF020515), Color(0xFF071536), Color(0xFF030717)]
            : const [Color(0xFF58D1F3), Color(0xFFD6F6E7), Color(0xFFFFFBED)],
      );

  LinearGradient get buttonGradient => LinearGradient(
        colors: cyber
            ? const [Color(0xFFEE179D), Color(0xFF9D2FFF)]
            : const [Color(0xFFFF8C2A), Color(0xFFFF5E2C)],
      );
}
