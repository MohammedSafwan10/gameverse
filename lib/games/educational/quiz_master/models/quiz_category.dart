import 'package:flutter/material.dart';

class QuizCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int questionCount;

  const QuizCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.questionCount,
  });
}
