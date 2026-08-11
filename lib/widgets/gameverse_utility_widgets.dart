import 'package:flutter/material.dart';

abstract final class GameVerseUtilityColors {
  static const cream = Color(0xFFFFF7E7);
  static const creamDeep = Color(0xFFF4E8CF);
  static const ink = Color(0xFF071A3D);
  static const cobalt = Color(0xFF0959C7);
  static const cobaltDark = Color(0xFF063B8E);
  static const orange = Color(0xFFFF5418);
  static const mint = Color(0xFF27BE95);
  static const pink = Color(0xFFF04F72);
  static const gold = Color(0xFFFFBD23);
}

class GameVerseUtilityBackground extends StatelessWidget {
  const GameVerseUtilityBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: GameVerseUtilityColors.cream),
          Positioned(
            top: -150,
            right: -110,
            child: _orb(270, GameVerseUtilityColors.cobalt),
          ),
          Positioned(
            bottom: -190,
            left: -135,
            child: _orb(310, GameVerseUtilityColors.cobalt),
          ),
          const Positioned(
            top: 118,
            left: 28,
            child: _BackgroundMark(Icons.star_rounded, 24),
          ),
          const Positioned(
            top: 84,
            right: 76,
            child: _BackgroundMark(Icons.sports_esports_rounded, 34),
          ),
          const Positioned(
            bottom: 70,
            right: 28,
            child: _BackgroundMark(Icons.casino_rounded, 36),
          ),
        ],
      ),
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 30,
          ),
        ],
      ),
    );
  }
}

class _BackgroundMark extends StatelessWidget {
  const _BackgroundMark(this.icon, this.size);

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: GameVerseUtilityColors.ink.withValues(alpha: 0.045),
    );
  }
}

class GameVerseUtilityHeader extends StatelessWidget {
  const GameVerseUtilityHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          GameVerseRoundButton(
            key: const Key('utility-back-button'),
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onTap: onBack ?? () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: GameVerseUtilityColors.ink,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
            ),
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: trailing,
          ),
        ],
      ),
    );
  }
}

class GameVerseRoundButton extends StatelessWidget {
  const GameVerseRoundButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.9),
        shape: const CircleBorder(
          side: BorderSide(color: Colors.white, width: 2),
        ),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Icon(icon, color: GameVerseUtilityColors.ink, size: 27),
          ),
        ),
      ),
    );
  }
}

class GameVerseSurface extends StatelessWidget {
  const GameVerseSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(radius),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1D624821),
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
          BoxShadow(
            color: Color(0x33FFFFFF),
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GameVerseIconTile extends StatelessWidget {
  const GameVerseIconTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.72), color],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 9,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.52),
    );
  }
}
