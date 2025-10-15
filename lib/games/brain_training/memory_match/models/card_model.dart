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

// Card themes for different difficulty levels
class CardThemes {
  static const List<String> emojis = [
    '🦁', '🐯', '🐼', '🐨', '🐵', '🐸', '🦊', '🐰',  // Animals
    '🌟', '🌙', '⭐', '☀️', '⚡', '🌈', '☁️', '��️',    // Nature
    '🎮', '🎲', '🎯', '🎪', '🎨', '🎭', '🎪', '🎯',  // Activities
    '🍎', '🍕', '🍦', '🍩', '🍪', '🍫', '🍭', '🍔',  // Food
  ];

  static List<Color> get cardColors => [
    Colors.blue.shade300,
    Colors.green.shade300,
    Colors.orange.shade300,
    Colors.purple.shade300,
    Colors.red.shade300,
    Colors.teal.shade300,
    Colors.pink.shade300,
    Colors.indigo.shade300,
  ];

  static Color getRandomBackgroundColor() {
    return cardColors[DateTime.now().millisecond % cardColors.length];
  }
} 