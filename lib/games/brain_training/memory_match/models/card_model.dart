import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MemoryCard extends Equatable {
  final int id;
  final String emoji;
  final bool isFlipped;
  final bool isMatched;
  final Color backgroundColor;

  const MemoryCard({
    required this.id,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
    required this.backgroundColor,
  });

  MemoryCard copyWith({
    int? id,
    String? emoji,
    bool? isFlipped,
    bool? isMatched,
    Color? backgroundColor,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  List<Object?> get props => [id, emoji, isFlipped, isMatched, backgroundColor];
}

/// Card themes with enough unique emojis for all grid sizes.
/// Easy = 4x3 = 6 pairs, Medium = 4x4 = 8 pairs, Hard = 5x4 = 10 pairs
class CardThemes {
  static const List<String> animals = [
    '\u{1F981}',
    '\u{1F42F}',
    '\u{1F43C}',
    '\u{1F428}',
    '\u{1F435}',
    '\u{1F98A}',
    '\u{1F430}',
    '\u{1F438}',
    '\u{1F989}',
    '\u{1F419}',
    '\u{1F98B}',
    '\u{1F42C}',
    '\u{1F99C}',
    '\u{1F422}',
    '\u{1F418}',
  ];
  static const List<String> nature = [
    '\u{1F31F}',
    '\u{1F319}',
    '\u{2B50}',
    '\u{2600}\u{FE0F}',
    '\u{26A1}',
    '\u{1F308}',
    '\u{2744}\u{FE0F}',
    '\u{1F525}',
    '\u{1F338}',
    '\u{1F340}',
    '\u{1F33B}',
    '\u{1F341}',
    '\u{1F4A7}',
    '\u{1F30D}',
    '\u{2601}\u{FE0F}',
  ];
  static const List<String> food = [
    '\u{1F34E}',
    '\u{1F355}',
    '\u{1F366}',
    '\u{1F369}',
    '\u{1F36A}',
    '\u{1F36B}',
    '\u{1F36D}',
    '\u{1F354}',
    '\u{1F353}',
    '\u{1F951}',
    '\u{1F347}',
    '\u{1F9C1}',
    '\u{1F32E}',
    '\u{1F37F}',
    '\u{1F950}',
  ];
  static const List<String> sports = [
    '\u{26BD}',
    '\u{1F3C0}',
    '\u{1F3BE}',
    '\u{1F3C8}',
    '\u{26BE}',
    '\u{1F3D0}',
    '\u{1F3B1}',
    '\u{1F3D3}',
    '\u{1F94A}',
    '\u{1F3AF}',
    '\u{1F3C6}',
    '\u{1F3B3}',
    '\u{1F3CA}',
    '\u{26F7}\u{FE0F}',
    '\u{1F6B4}',
  ];
  static const List<String> travel = [
    '\u{2708}\u{FE0F}',
    '\u{1F680}',
    '\u{1F682}',
    '\u{26F5}',
    '\u{1F3D4}\u{FE0F}',
    '\u{1F5FD}',
    '\u{1F3A1}',
    '\u{1F3D6}\u{FE0F}',
    '\u{1F30B}',
    '\u{1F5FF}',
    '\u{1F3F0}',
    '\u{1F3A2}',
    '\u{1F681}',
    '\u{26E9}\u{FE0F}',
    '\u{1F309}',
  ];

  /// All themes grouped for random selection
  static const List<List<String>> allThemes = [
    animals,
    nature,
    food,
    sports,
    travel,
  ];

  /// Legacy accessor - flattened list of all emojis
  static List<String> get emojis => allThemes.expand((t) => t).toSet().toList();

  static const List<Color> cardColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF2ED573),
    Color(0xFF70A1FF),
    Color(0xFFFF7F50),
    Color(0xFFA29BFE),
    Color(0xFFECCC68),
    Color(0xFF1DD1A1),
    Color(0xFFFF6B6B),
    Color(0xFF48DBFB),
    Color(0xFFFFA502),
    Color(0xFFFF4757),
    Color(0xFF2E86DE),
    Color(0xFF7C4DFF),
    Color(0xFF00D2D3),
  ];

  static Color getColorForIndex(int index) {
    return cardColors[index % cardColors.length];
  }

  static Color getRandomBackgroundColor() {
    return cardColors[DateTime.now().microsecond % cardColors.length];
  }
}
