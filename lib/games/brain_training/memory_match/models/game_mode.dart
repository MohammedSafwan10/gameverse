import 'package:flutter/material.dart';

enum MemoryMatchMode {
  classic,
  timeTrial,
  challenge;

  String get displayName {
    switch (this) {
      case MemoryMatchMode.classic:
        return 'Classic';
      case MemoryMatchMode.timeTrial:
        return 'Time Trial';
      case MemoryMatchMode.challenge:
        return 'Challenge';
    }
  }

  String get description {
    switch (this) {
      case MemoryMatchMode.classic:
        return 'Find all pairs at your own pace';
      case MemoryMatchMode.timeTrial:
        return 'Race against time to match pairs';
      case MemoryMatchMode.challenge:
        return 'Progressive difficulty levels';
    }
  }

  IconData get icon {
    switch (this) {
      case MemoryMatchMode.classic:
        return Icons.grid_view_rounded;
      case MemoryMatchMode.timeTrial:
        return Icons.timer;
      case MemoryMatchMode.challenge:
        return Icons.trending_up;
    }
  }

  Color get color {
    switch (this) {
      case MemoryMatchMode.classic:
        return Colors.blue;
      case MemoryMatchMode.timeTrial:
        return Colors.orange;
      case MemoryMatchMode.challenge:
        return Colors.purple;
    }
  }
} 