import 'package:flutter/material.dart';

enum GameMode {
  singlePlayer,
  multiPlayer,
  online;

  String get displayName {
    switch (this) {
      case GameMode.singlePlayer:
        return 'Single Player';
      case GameMode.multiPlayer:
        return 'Two Players';
      case GameMode.online:
        return 'Online';
    }
  }

  String get description {
    switch (this) {
      case GameMode.singlePlayer:
        return 'Play against AI with different difficulty levels';
      case GameMode.multiPlayer:
        return 'Play with a friend on the same device';
      case GameMode.online:
        return 'Challenge players online';
    }
  }

  IconData get icon {
    switch (this) {
      case GameMode.singlePlayer:
        return Icons.person;
      case GameMode.multiPlayer:
        return Icons.people;
      case GameMode.online:
        return Icons.public;
    }
  }
}
