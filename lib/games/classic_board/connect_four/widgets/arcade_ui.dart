import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';
import '../services/sound_service.dart';

const cfCream = Color(0xFFFFF0D5);
const cfInk = Color(0xFF061C51);
const cfRed = Color(0xFFE72C18);
const cfAssets = 'assets/images/games/connect_four/';

void ensureConnectFourServices() {
  if (!Get.isRegistered<ConnectFourSettingsController>()) {
    Get.put(ConnectFourSettingsController(), permanent: true);
  }
  if (!Get.isRegistered<ConnectFourStatsController>()) {
    Get.put(ConnectFourStatsController(), permanent: true);
  }
  if (!Get.isRegistered<SoundService>()) {
    Get.put(SoundService(), permanent: true);
  }
  Get.find<SoundService>().preload();
}

TextStyle cfText(double size,
        {Color color = cfInk, FontWeight weight = FontWeight.w700}) =>
    TextStyle(
        fontFamily: 'Barlow',
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.15);

class CFPage extends StatelessWidget {
  const CFPage({super.key, required this.child, this.overlay});
  final Widget child;
  final Widget? overlay;
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
          backgroundColor: const Color(0xFF034CB9),
          body: Stack(children: [
            Positioned.fill(
                child: Image.asset('${cfAssets}backdrop.png',
                    fit: BoxFit.cover, excludeFromSemantics: true)),
            Positioned.fill(
                child: ColoredBox(color: cfInk.withValues(alpha: .15))),
            SafeArea(
                child: Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 540),
                        child: child))),
            if (overlay != null) Positioned.fill(child: overlay!),
          ])));
}

class CFSurface extends StatelessWidget {
  const CFSurface(
      {super.key,
      required this.child,
      this.color = cfCream,
      this.padding = const EdgeInsets.all(16),
      this.radius = 22});
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
      padding: padding,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(color, Colors.white, .18)!,
                color,
                Color.lerp(color, Colors.black, .05)!
              ]),
          border: Border.all(
              color: Color.lerp(color, Colors.white, .7)!, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: .3),
                blurRadius: 9,
                offset: const Offset(0, 5)),
            BoxShadow(
                color: Color.lerp(color, Colors.black, .3)!,
                offset: const Offset(0, 3))
          ]),
      child: child);
}

class CFIcon extends StatelessWidget {
  const CFIcon(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Tooltip(
      message: label,
      child: SizedBox(
          width: 46,
          height: 46,
          child: CFSurface(
              radius: 50,
              padding: EdgeInsets.zero,
              child: IconButton(
                  onPressed: onTap,
                  icon: Icon(icon, color: cfInk, size: 24),
                  tooltip: label))));
}

class CFButton extends StatelessWidget {
  const CFButton(
      {super.key,
      required this.label,
      required this.onTap,
      this.red = false,
      this.icon});
  final String label;
  final VoidCallback onTap;
  final bool red;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Semantics(
      button: true,
      child: Material(
          color: Colors.transparent,
          child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onTap,
              child: CFSurface(
                  color: red ? cfRed : cfCream,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  radius: 25,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: red ? cfCream : cfInk, size: 25),
                          const SizedBox(width: 12)
                        ],
                        Flexible(
                            child: Text(label,
                                textAlign: TextAlign.center,
                                style:
                                    cfText(20, color: red ? cfCream : cfInk))),
                      ])))));
}

class CFTitle extends StatelessWidget {
  const CFTitle({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final size = (box.maxWidth * (compact ? .11 : .17)).clamp(30.0, 78.0);
        return Column(children: [
          FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('CONNECT',
                  style: TextStyle(
                      fontFamily: 'Barlow',
                      fontSize: size,
                      fontWeight: FontWeight.w900,
                      color: cfCream,
                      height: .95,
                      shadows: const [
                        Shadow(
                            color: cfInk, offset: Offset(0, 4), blurRadius: 1),
                        Shadow(color: Color(0xFFAD8551), offset: Offset(0, 2))
                      ]))),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('F',
                style: TextStyle(
                    fontFamily: 'Barlow',
                    fontSize: size,
                    fontWeight: FontWeight.w900,
                    color: cfCream,
                    height: 1)),
            CFDisc(red: true, size: size * .76),
            Text('UR',
                style: TextStyle(
                    fontFamily: 'Barlow',
                    fontSize: size,
                    fontWeight: FontWeight.w900,
                    color: cfCream,
                    height: 1,
                    shadows: const [
                      Shadow(color: cfInk, offset: Offset(0, 4), blurRadius: 1)
                    ])),
          ]),
        ]);
      });
}

class CFDisc extends StatelessWidget {
  const CFDisc({super.key, required this.red, this.size = 40});
  final bool red;
  final double size;
  @override
  Widget build(BuildContext context) =>
      Image.asset('$cfAssets${red ? 'red' : 'yellow'}-disc.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          excludeFromSemantics: true);
}

class CFPair extends StatelessWidget {
  const CFPair({super.key, this.height = 110});
  final double height;
  @override
  Widget build(BuildContext context) => Image.asset('${cfAssets}pair.png',
      height: height, fit: BoxFit.contain, excludeFromSemantics: true);
}

class CFHeading extends StatelessWidget {
  const CFHeading(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Row(children: [
        CFIcon(
            icon: Icons.arrow_back_rounded,
            label: 'Back',
            onTap: () => Get.back()),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: cfText(27, color: cfCream))),
      ]);
}

Future<bool> cfConfirm(BuildContext context,
        {required String title,
        required String message,
        required String action}) async =>
    await showDialog<bool>(
        context: context,
        builder: (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: CFSurface(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const CFPair(height: 70),
                  const SizedBox(height: 8),
                  Text(title, textAlign: TextAlign.center, style: cfText(26)),
                  const SizedBox(height: 10),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: cfText(16, weight: FontWeight.w600)),
                  const SizedBox(height: 22),
                  CFButton(
                      label: 'KEEP PLAYING',
                      onTap: () => Navigator.pop(dialogContext, false)),
                  const SizedBox(height: 12),
                  CFButton(
                      label: action,
                      red: true,
                      onTap: () => Navigator.pop(dialogContext, true)),
                ]))))) ??
    false;
