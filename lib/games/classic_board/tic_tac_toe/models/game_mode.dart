import 'package:flutter/material.dart';

enum GameMode {
  singlePlayer,
  multiPlayer;

  String get displayName {
    switch (this) {
      case GameMode.singlePlayer:
        return 'Single Player';
      case GameMode.multiPlayer:
        return 'Two Players';
    }
  }

  String get description {
    switch (this) {
      case GameMode.singlePlayer:
        return 'Play against AI with different difficulty levels';
      case GameMode.multiPlayer:
        return 'Play with a friend on the same device';
    }
  }

  IconData get icon {
    switch (this) {
      case GameMode.singlePlayer:
        return Icons.person;
      case GameMode.multiPlayer:
        return Icons.people;
    }
  }
}
