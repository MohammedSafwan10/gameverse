import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/block.dart';
import '../controllers/settings_controller.dart';
import '../models/merge_engine.dart';

const resinInk = Color(0xFF063A43),
    resinCoral = Color(0xFFE66B60),
    resinMint = Color(0xFFBFE4DA),
    resinLilac = Color(0xFFD4C5EC);
String modeName(BlockMergeMode mode) => switch (mode) {
      BlockMergeMode.classic => 'CLASSIC',
      BlockMergeMode.timeChallenge => 'TIME CHALLENGE',
      BlockMergeMode.zen => 'ZEN',
    };
String clockText(int s) =>
    '${'${s ~/ 60}'.padLeft(2, '0')}:${'${s % 60}'.padLeft(2, '0')}';
TextStyle resinText(double size,
        {Color color = resinInk, FontWeight weight = FontWeight.w800}) =>
    TextStyle(
        fontFamily: 'BlockResin',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.08);

class ResinArt extends StatelessWidget {
  final String name;
  final double? height;
  const ResinArt(this.name, {super.key, this.height});
  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/images/games/block_merge/$name.png',
          height: height,
          cacheWidth: name == 'hero' ? 1024 : 512,
          fit: BoxFit.contain,
          excludeFromSemantics: true);
}

class ResinPage extends StatelessWidget {
  final Widget child;
  const ResinPage({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Theme(
      data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: resinInk, brightness: Brightness.light),
          textTheme: Theme.of(context)
              .textTheme
              .apply(bodyColor: resinInk, displayColor: resinInk)),
      child: Scaffold(
          body: Stack(fit: StackFit.expand, children: [
        Image.asset('assets/images/games/block_merge/room.png',
            cacheWidth: 1080, fit: BoxFit.cover, excludeFromSemantics: true),
        SafeArea(
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: child))),
      ])));
}

/// Normal phone layouts are one-page. Accessibility text can scroll instead
/// of shrinking labels or clipping actions; decorative art yields first.
class ResinViewport extends StatelessWidget {
  final LayoutWidgetBuilder builder;
  const ResinViewport({super.key, required this.builder});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        if (MediaQuery.textScalerOf(context).scale(1) <= 1.2) {
          return builder(context, box);
        }
        return SingleChildScrollView(
            child: SizedBox(
                height: math.max(box.maxHeight, 900),
                child: LayoutBuilder(builder: builder)));
      });
}

class ResinSurface extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final double radius;
  const ResinSurface(
      {super.key,
      required this.child,
      this.color = const Color(0xFFF7F4E9),
      this.padding = const EdgeInsets.all(16),
      this.radius = 24});
  @override
  Widget build(BuildContext context) => Container(
      padding: padding,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(color, Colors.white, .36)!,
                color,
                Color.lerp(color, resinInk, .08)!
              ]),
          border:
              Border.all(color: Colors.white.withValues(alpha: .8), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: resinInk.withValues(alpha: .15),
                blurRadius: 12,
                offset: const Offset(0, 5))
          ]),
      child: child);
}

class ResinIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const ResinIcon(this.icon,
      {super.key, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Tooltip(
      message: label,
      child: Semantics(
          button: true,
          label: label,
          child: SizedBox(
              width: 48,
              height: 48,
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onTap,
                      child: ResinSurface(
                          radius: 50,
                          padding: EdgeInsets.zero,
                          child: Icon(icon, color: resinInk, size: 25)))))));
}

class ResinButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final IconData? icon;
  const ResinButton(this.label,
      {super.key, this.onTap, this.color = resinCoral, this.icon});
  @override
  Widget build(BuildContext context) => Opacity(
      opacity: onTap == null ? .45 : 1,
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: ResinSurface(
                  color: color,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: resinInk, size: 20),
                          const SizedBox(width: 8)
                        ],
                        Flexible(
                            child: Text(label,
                                textAlign: TextAlign.center,
                                style: resinText(17))),
                      ])))));
}

class ResinHeader extends StatelessWidget {
  final String title;
  final VoidCallback back;
  final List<Widget> actions;
  const ResinHeader(this.title,
      {super.key, required this.back, this.actions = const []});
  @override
  Widget build(BuildContext context) => Row(children: [
        ResinIcon(Icons.arrow_back_rounded, label: 'Back', onTap: back),
        const SizedBox(width: 8),
        Expanded(
            child:
                Text(title, style: resinText(23), textAlign: TextAlign.center)),
        ...actions,
      ]);
}

class ResinStat extends StatelessWidget {
  final String label, value;
  const ResinStat(this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => ResinSurface(
      padding: const EdgeInsets.all(12),
      radius: 18,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: resinText(12, weight: FontWeight.w600)),
        const SizedBox(height: 4),
        FittedBox(
            fit: BoxFit.scaleDown, child: Text(value, style: resinText(27))),
      ]));
}

class ResinTile extends StatelessWidget {
  final int value;
  const ResinTile(this.value, {super.key});
  static Color tileColor(int value) => switch (value) {
        2 => const Color(0xFF74D9D6),
        4 => const Color(0xFFB0DACC),
        8 => const Color(0xFFF4B078),
        16 => const Color(0xFFF0847F),
        32 => const Color(0xFFC3A2E0),
        64 => const Color(0xFF28AAA6),
        128 => const Color(0xFFF4BC58),
        256 => const Color(0xFF9054B7),
        512 => const Color(0xFFCC5A6B),
        1024 => const Color(0xFF4C89B4),
        2048 => const Color(0xFFE9B744),
        _ => const Color(0xFF235E66),
      };
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final color = value == 0 ? const Color(0xFFE1E4DA) : tileColor(value);
        final edge = box.maxWidth * .13;
        return Semantics(
            label: value == 0 ? 'Empty cell' : 'Tile $value',
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(edge),
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: value == 0
                            ? [const Color(0xFFDADDD4), const Color(0xFFEDEFE7)]
                            : [
                                Color.lerp(color, Colors.white, .55)!,
                                color,
                                Color.lerp(color, resinInk, .13)!,
                                color
                              ]),
                    border: Border.all(
                        color: value == 0
                            ? const Color(0xFFC8D4CB)
                            : Color.lerp(color, Colors.white, .6)!,
                        width: 1.8),
                    boxShadow: value == 0
                        ? null
                        : [
                            BoxShadow(
                                color: resinInk.withValues(alpha: .2),
                                blurRadius: 3,
                                offset: const Offset(0, 3))
                          ]),
                child: Stack(children: [
                  if (value != 0)
                    Positioned.fill(
                        child: ClipRect(
                            child: Transform.scale(
                                scale: 1.12,
                                child: Image.asset(
                                    'assets/images/games/block_merge/tile.png',
                                    color: Color.lerp(color, Colors.white, .28),
                                    colorBlendMode: BlendMode.modulate,
                                    fit: BoxFit.fill,
                                    cacheWidth: 256,
                                    excludeFromSemantics: true)))),
                  if (value != 0)
                    Positioned.fill(
                        child: Padding(
                            padding: EdgeInsets.all(box.maxWidth * .065),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(edge * .7),
                                    border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: .52),
                                        width: 1.2),
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withValues(alpha: .32),
                                          Colors.transparent,
                                          Colors.white.withValues(alpha: .08)
                                        ]))))),
                  if (value != 0)
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('$value',
                                    style: resinText(box.maxWidth * .43,
                                        color: value == 64 ||
                                                value >= 256 && value != 2048
                                            ? Colors.white
                                            : resinInk))))),
                ])));
      });
}

class ResinBoard extends StatefulWidget {
  final List<List<Block?>> grid;
  final MergeResult? motion;
  const ResinBoard(this.grid, {super.key, this.motion});
  @override
  State<ResinBoard> createState() => _ResinBoardState();
}

class _ResinBoardState extends State<ResinBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));
  @override
  void didUpdateWidget(covariant ResinBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.motion == null) {
      animation.stop();
      animation.value = 1;
    }
    if (widget.motion != null &&
        !identical(oldWidget.motion, widget.motion) &&
        !MediaQuery.disableAnimationsOf(context)) {
      animation.forward(from: 0);
    }
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
      aspectRatio: 1,
      child: ResinSurface(
          padding: const EdgeInsets.all(12),
          radius: 22,
          child: LayoutBuilder(builder: (context, box) {
            final gap = box.maxWidth * .025;
            final size = (box.maxWidth - gap * 3) / 4;
            Widget tile(int value, double x, double y, {double scale = 1}) =>
                Positioned(
                    left: x * (size + gap),
                    top: y * (size + gap),
                    width: size,
                    height: size,
                    child:
                        Transform.scale(scale: scale, child: ResinTile(value)));
            return AnimatedBuilder(
                animation: animation,
                builder: (_, _) {
                  final moving = animation.isAnimating &&
                      widget.motion != null &&
                      animation.value < .72;
                  final progress = Curves.easeOutCubic
                      .transform((animation.value / .72).clamp(0, 1));
                  return Stack(clipBehavior: Clip.none, children: [
                    for (var y = 0; y < 4; y++)
                      for (var x = 0; x < 4; x++)
                        tile(0, x.toDouble(), y.toDouble()),
                    if (moving)
                      for (final m in widget.motion!.motions)
                        tile(m.value, m.fromX + (m.toX - m.fromX) * progress,
                            m.fromY + (m.toY - m.fromY) * progress)
                    else
                      for (var y = 0; y < 4; y++)
                        for (var x = 0; x < 4; x++)
                          if (widget.grid[y][x] != null)
                            tile(widget.grid[y][x]!.value, x.toDouble(),
                                y.toDouble(),
                                scale: animation.isAnimating &&
                                        widget.grid[y][x]!.isNew
                                    ? .75 +
                                        .25 *
                                            ((animation.value - .72) / .28)
                                                .clamp(0, 1)
                                    : 1),
                  ]);
                });
          })));
}

Future<bool> resinConfirm(
        BuildContext context, String title, String message, String action,
        {IconData icon = Icons.restart_alt,
        Color color = resinCoral,
        String? art,
        String cancelLabel = 'KEEP PLAYING'}) async =>
    await showDialog<bool>(
        context: context,
        builder: (c) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: ResinSurface(
                    child: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                  if (art != null)
                    ResinArt(art, height: 100)
                  else
                    Icon(icon, size: 58, color: resinInk),
                  const SizedBox(height: 12),
                  Text(title,
                      style: resinText(27), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(message,
                      style: resinText(16, weight: FontWeight.w600),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ResinButton(action,
                      color: color, onTap: () => Navigator.pop(c, true)),
                  const SizedBox(height: 10),
                  ResinButton(cancelLabel,
                      color: resinMint, onTap: () => Navigator.pop(c, false)),
                ])))))) ??
    false;
