import 'package:flutter/material.dart';

const quizNavy = Color(0xFF09285D);
const quizBlue = Color(0xFF0758DD);
const quizOrange = Color(0xFFFF730E);
const quizMuted = Color(0xFF476382);
TextStyle quizText(double size,
        {Color color = quizNavy, bool display = false}) =>
    TextStyle(
        fontFamily: display ? 'QuizDisplay' : 'BlockResin',
        fontSize: size,
        color: color,
        height: 1.12);

class GalleryPage extends StatelessWidget {
  const GalleryPage(
      {super.key, required this.child, this.backgroundArt = 'room'});
  final Widget child;
  final String? backgroundArt;
  @override
  Widget build(BuildContext context) => Theme(
      data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
              primary: quizBlue, secondary: quizOrange, surface: Colors.white),
          textTheme: ThemeData.light().textTheme.apply(
              fontFamily: 'BlockResin',
              bodyColor: quizNavy,
              displayColor: quizNavy)),
      child: Scaffold(
          backgroundColor: const Color(0xFFF3F6F7),
          body: Stack(children: [
            if (backgroundArt != null)
              Positioned.fill(
                  child: Image.asset(
                      'assets/images/games/quiz_master/$backgroundArt.png',
                      fit: BoxFit.cover,
                      cacheWidth: 1080,
                      excludeFromSemantics: true)),
            SafeArea(
                child: Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 540),
                        child: Padding(
                            padding: const EdgeInsets.all(14), child: child)))),
          ])));
}

class GalleryPanel extends StatelessWidget {
  const GalleryPanel(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(12),
      this.color = Colors.white,
      this.border,
      this.radius = 22});
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color? border;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
      padding: padding,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, Color.lerp(color, const Color(0xFFE9EDF0), .2)!]),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
              color: border ?? Colors.white, width: border == null ? 2 : 1.5),
          boxShadow: const [
            BoxShadow(
                color: Color(0x19334662), blurRadius: 14, offset: Offset(0, 6))
          ]),
      child: child);
}

class GalleryArt extends StatelessWidget {
  const GalleryArt(this.name, {super.key, this.fit = BoxFit.contain});
  final String name;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/images/games/quiz_master/$name.png',
          fit: fit, cacheWidth: 720, excludeFromSemantics: true);
}

class GalleryIcon extends StatelessWidget {
  const GalleryIcon(
      {super.key,
      required this.icon,
      required this.onTap,
      required this.label});
  final IconData icon;
  final VoidCallback onTap;
  final String label;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 44,
      height: 44,
      child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 3,
          shadowColor: const Color(0x22476382),
          child: IconButton(
              tooltip: label,
              onPressed: onTap,
              icon: Icon(icon, color: quizBlue, size: 25))));
}

class GalleryButton extends StatelessWidget {
  const GalleryButton(this.label,
      {super.key,
      required this.onTap,
      this.orange = false,
      this.icon,
      this.outline = false});
  final String label;
  final VoidCallback? onTap;
  final bool orange, outline;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final color = orange ? quizOrange : quizBlue;
    return DecoratedBox(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: outline || onTap == null
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                        Color.lerp(color, Colors.white, .2)!,
                        color,
                        Color.lerp(color, Colors.black, .18)!
                      ]),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: .18),
                  blurRadius: 12,
                  offset: const Offset(0, 5))
            ]),
        child: SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                    backgroundColor: outline
                        ? Colors.white
                        : onTap == null
                            ? null
                            : Colors.transparent,
                    foregroundColor: outline ? color : Colors.white,
                    disabledBackgroundColor: const Color(0xFFE1E8EF),
                    disabledForegroundColor: quizMuted,
                    minimumSize: const Size(44, 48),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(
                            color: outline ? color : Colors.white, width: 1.5)),
                    elevation: 0,
                    shadowColor: color.withValues(alpha: .25)),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (icon != null) ...[
                    Icon(icon, size: 25),
                    const SizedBox(width: 12)
                  ],
                  Flexible(
                      child: Text(label,
                          textAlign: TextAlign.center,
                          style: quizText(16,
                              color: onTap == null
                                  ? quizMuted
                                  : outline
                                      ? color
                                      : Colors.white)))
                ]))));
  }
}

class GalleryStat extends StatelessWidget {
  const GalleryStat(this.label, this.value, this.icon,
      {super.key, this.iconColor = quizOrange});
  final String label, value;
  final IconData icon;
  final Color iconColor;
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Flexible(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(label, style: quizText(10, color: quizMuted)),
              Text(value, style: quizText(25, display: true)),
            ])),
      ]);
}

/// Normal menus fit available height. Accessibility layouts intentionally scroll.
class GalleryViewport extends StatelessWidget {
  const GalleryViewport({super.key, required this.builder});
  final Widget Function(BuildContext, double) builder;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        if (MediaQuery.textScalerOf(context).scale(1) > 1.2) {
          return SingleChildScrollView(
              child: SizedBox(
                  height: box.maxHeight < 950 ? 950 : box.maxHeight,
                  child: builder(
                      context, box.maxHeight < 950 ? 950 : box.maxHeight)));
        }
        return builder(context, box.maxHeight);
      });
}
