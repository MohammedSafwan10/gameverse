import 'package:flutter/material.dart';

abstract final class ChessDesign {
  static const navy = Color(0xFF063B78);
  static const navyDeep = Color(0xFF022B5D);
  static const blue = Color(0xFF0C5EC4);
  static const ivory = Color(0xFFFFF8E8);
  static const ivoryDeep = Color(0xFFF1E3C4);
  static const ink = Color(0xFF17202B);
  static const gold = Color(0xFFF3B61F);
  static const orange = Color(0xFFFF5315);
  static const teal = Color(0xFF20BFA6);
  static const red = Color(0xFFE84747);

  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF083A70), Color(0xFF021A38), Color(0xFF010D20)],
    stops: [0, .58, 1],
  );

  static List<BoxShadow> get raisedShadow => const [
        BoxShadow(
            color: Color(0x55001A39), blurRadius: 16, offset: Offset(0, 8)),
        BoxShadow(
            color: Color(0x33FFFFFF), blurRadius: 1, offset: Offset(0, -1)),
      ];

  static BoxDecoration ivoryPanel({double radius = 28, Color? color}) =>
      BoxDecoration(
        color: color ?? ivory,
        borderRadius: BorderRadius.circular(radius),
        border:
            Border.all(color: Colors.white.withValues(alpha: .82), width: 1.5),
        boxShadow: raisedShadow,
      );
}

class ChessBoardPalette {
  const ChessBoardPalette({
    required this.name,
    required this.light,
    required this.dark,
    required this.frame,
    required this.frameEdge,
    required this.accent,
    required this.coordinate,
  });

  final String name;
  final Color light;
  final Color dark;
  final Color frame;
  final Color frameEdge;
  final Color accent;
  final Color coordinate;

  String get textureAsset =>
      'assets/images/games/chess/board_textures/${name.toLowerCase()}.webp';

  static ChessBoardPalette fromId(String id) => switch (id) {
        'modern' => const ChessBoardPalette(
            name: 'Modern',
            light: Color(0xFFE8EFF7),
            dark: Color(0xFF506B85),
            frame: Color(0xFF1C2B39),
            frameEdge: Color(0xFF91A8BC),
            accent: Color(0xFF3ED1FF),
            coordinate: Color(0xFFDBF6FF)),
        'forest' => const ChessBoardPalette(
            name: 'Forest',
            light: Color(0xFFF0E8C9),
            dark: Color(0xFF588052),
            frame: Color(0xFF24492F),
            frameEdge: Color(0xFF94B66F),
            accent: Color(0xFFF2C94C),
            coordinate: Color(0xFFE8F3D8)),
        'royal' => const ChessBoardPalette(
            name: 'Royal',
            light: Color(0xFFFFF4D8),
            dark: Color(0xFF073D7C),
            frame: Color(0xFF032A59),
            frameEdge: ChessDesign.gold,
            accent: ChessDesign.orange,
            coordinate: Color(0xFFFFE39A)),
        'ocean' => const ChessBoardPalette(
            name: 'Ocean',
            light: Color(0xFFF2E8D2),
            dark: Color(0xFF0A4664),
            frame: Color(0xFF021D3F),
            frameEdge: ChessDesign.gold,
            accent: Color(0xFFFFC857),
            coordinate: Color(0xFFFFD779)),
        'sunset' => const ChessBoardPalette(
            name: 'Sunset',
            light: Color(0xFFFFE7CA),
            dark: Color(0xFFC75A3A),
            frame: Color(0xFF6E2E37),
            frameEdge: Color(0xFFFFB35C),
            accent: Color(0xFF812B75),
            coordinate: Color(0xFFFFEDDB)),
        _ => const ChessBoardPalette(
            name: 'Classic',
            light: Color(0xFFF4D9B0),
            dark: Color(0xFFA86F46),
            frame: Color(0xFF5B321C),
            frameEdge: Color(0xFFD7A55A),
            accent: Color(0xFFFFC43D),
            coordinate: Color(0xFFFFE7C0)),
      };
}
