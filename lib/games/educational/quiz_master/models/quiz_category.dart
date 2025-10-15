import 'package:flutter/material.dart';

class QuizCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> difficulties;
  final int questionCount;

  const QuizCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.difficulties,
    required this.questionCount,
  });
}
