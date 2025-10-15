import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/category/category_screen.dart';
import '../games/word_games/hangman/screens/mode_selection_screen.dart';
import '../games/classic_board/connect_four/screens/mode_selection_screen.dart'
    as connect_four;
import '../games/classic_board/tic_tac_toe/screens/mode_selection_screen.dart'
    as tic_tac_toe;
import '../games/classic_board/chess/screens/mode_selection_screen.dart'
    as chess;
import '../games/brain_training/memory_match/screens/mode_selection_screen.dart'
    as memory_match;
import '../games/quick_casual/flappy_bird/screens/mode_selection_screen.dart'
    as flappy_bird;
import '../games/puzzle/block_merge/screens/mode_selection_screen.dart'
    as block_merge;
import '../games/reaction/whack_a_mole/screens/mode_selection_screen.dart'
    as whack_a_mole;
import '../games/educational/quiz_master/screens/mode_selection_screen.dart'
    as quiz_master;

class GameCategory {
  final String title;
  final IconData icon;
  final Color color;
  final int gamesCount;
  final List<GameInfo> games;

  GameCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.gamesCount,
    required this.games,
  });
}

class HomeController extends GetxController {
  final categories = [
    GameCategory(
      title: 'Arcade',
      icon: Icons.sports_esports,
      color: Colors.deepPurple,
      gamesCount: 8,
      games: [
        GameInfo(
          name: 'Pac-Maze',
          description:
              'Classic maze chase game with modern twists! Navigate through mazes, avoid ghosts, and collect power pellets.',
          icon: Icons.catching_pokemon,
          isAvailable: false,
          screen: () => const Placeholder(),
        ),
      ],
    ),
    GameCategory(
      title: 'Classic Board',
      icon: Icons.grid_on,
      color: Colors.blue,
      gamesCount: 6,
      games: [
        GameInfo(
          name: 'Tic Tac Toe',
          description:
              'Classic X and O game. Challenge your friends or play against AI!',
          icon: Icons.grid_3x3,
          screen: () => tic_tac_toe.ModeSelectionScreen(),
        ),
        GameInfo(
          name: 'Connect Four',
          description:
              'Drop discs to connect 4 in a row! Strategic gameplay with smooth animations.',
          icon: Icons.circle,
          screen: () => const connect_four.ConnectFourModeScreen(),
          isAvailable: true,
        ),
        GameInfo(
          name: 'Chess',
          description:
              'The ultimate strategy board game with full rule implementation.',
          icon: Icons.extension,
          isAvailable: true,
          screen: () => const chess.ChessModeSelectionScreen(),
        ),
      ],
    ),
    GameCategory(
      title: 'Word Games',
      icon: Icons.text_fields,
      color: Colors.red,
      gamesCount: 4,
      games: [
        GameInfo(
          name: 'Hangman',
          description:
              'Classic word guessing game with multiple categories and daily challenges.',
          icon: Icons.psychology,
          isAvailable: true,
          screen: () => const HangmanModeSelectionScreen(),
        ),
        GameInfo(
          name: 'Word Search',
          description: 'Find hidden words in a grid of letters.',
          icon: Icons.search,
          isAvailable: false,
          screen: () => const Placeholder(),
        ),
        GameInfo(
          name: 'Crossword',
          description: 'Classic crossword puzzles with various themes.',
          icon: Icons.grid_4x4,
          isAvailable: false,
          screen: () => const Placeholder(),
        ),
        GameInfo(
          name: 'Anagrams',
          description: 'Rearrange letters to form as many words as possible.',
          icon: Icons.shuffle,
          isAvailable: false,
          screen: () => const Placeholder(),
        ),
      ],
    ),
    GameCategory(
      title: 'Brain Training',
      icon: Icons.psychology,
      color: Colors.purple,
      gamesCount: 8,
      games: [
        GameInfo(
          name: 'Memory Match',
          description: 'Test your memory by matching pairs of cards!',
          icon: Icons.grid_view,
          isAvailable: true,
          screen: () => const memory_match.MemoryMatchModeSelectionScreen(),
        ),
      ],
    ),
    GameCategory(
      title: 'Puzzle',
      icon: Icons.extension,
      color: Colors.orange,
      gamesCount: 8,
      games: [
        GameInfo(
          name: 'Block Merge',
          description:
              'Merge blocks to reach 2048! Strategic puzzle game with simple swipe controls.',
          icon: Icons.grid_4x4,
          isAvailable: true,
          screen: () => const block_merge.BlockMergeModeSelectionScreen(),
        ),
      ],
    ),
    GameCategory(
      title: 'Quick Casual',
      icon: Icons.sports_esports,
      color: Colors.green,
      gamesCount: 8,
      games: [
        GameInfo(
          name: 'Flappy Bird',
          description:
              'Classic one-touch gameplay! Navigate through pipes and set high scores in this addictive casual game.',
          icon: Icons.flutter_dash,
          isAvailable: true,
          screen: () => const flappy_bird.FlappyBirdModeSelectionScreen(),
        ),
      ],
    ),
    GameCategory(
      title: 'Strategy',
      icon: Icons.psychology_outlined,
      color: Colors.teal,
      gamesCount: 5,
      games: [],
    ),
    GameCategory(
      title: 'Reaction',
      icon: Icons.bolt,
      color: Colors.amber,
      gamesCount: 5,
      games: [
        GameInfo(
          name: 'Whack-A-Mole',
          description:
              'Test your reflexes! Whack moles as they pop up, but watch out for traps!',
          icon: Icons.gavel,
          isAvailable: true,
          screen: () => const whack_a_mole.WhackAMoleModeSelectionScreen(),
        ),
      ],
    ),
    GameCategory(
      title: 'Educational',
      icon: Icons.school,
      color: Colors.indigo,
      gamesCount: 5,
      games: [
        GameInfo(
          name: 'Quiz Master',
          description:
              'Challenge yourself with various topics! From science to history, test your knowledge in this engaging quiz game.',
          icon: Icons.quiz_rounded,
          isAvailable: true,
          screen: () => const quiz_master.QuizMasterModeSelectionScreen(),
        ),
      ],
    ),
  ];

  void onCategoryTap(int index) {
    final category = categories[index];
    Get.to(
      () => CategoryScreen(
        title: category.title,
        color: category.color,
        games: category.games,
      ),
    );
  }
}
