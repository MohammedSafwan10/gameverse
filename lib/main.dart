import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/achievements/achievements_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'theme/app_theme.dart';
import 'games/classic_board/tic_tac_toe/screens/game_screen.dart'
    as tic_tac_toe;
import 'games/classic_board/tic_tac_toe/screens/mode_selection_screen.dart'
    as tic_tac_toe;
import 'games/classic_board/tic_tac_toe/screens/stats_screen.dart'
    as tic_tac_toe;
import 'games/classic_board/tic_tac_toe/screens/settings_screen.dart'
    as tic_tac_toe;
import 'games/classic_board/tic_tac_toe/bindings/game_binding.dart'
    as tic_tac_toe;
import 'games/classic_board/chess/bindings/chess_binding.dart';
import 'games/classic_board/chess/screens/mode_selection_screen.dart' as chess;
import 'games/classic_board/connect_four/bindings/game_binding.dart'
    as connect_four;
import 'games/classic_board/connect_four/controllers/game_controller.dart'
    as connect_four;
import 'games/classic_board/connect_four/screens/mode_selection_screen.dart'
    as connect_four;
import 'games/brain_training/memory_match/bindings/game_binding.dart';
import 'games/brain_training/memory_match/screens/mode_selection_screen.dart'
    as memory_match;
import 'games/puzzle/block_merge/bindings/game_binding.dart';
import 'games/puzzle/block_merge/screens/mode_selection_screen.dart'
    as block_merge;
import 'games/quick_casual/flappy_bird/bindings/game_binding.dart';
import 'games/quick_casual/flappy_bird/screens/mode_selection_screen.dart'
    as flappy_bird;
import 'games/educational/quiz_master/bindings/quiz_binding.dart';
import 'games/educational/quiz_master/screens/mode_selection_screen.dart'
    as quiz_master;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GameVerse',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomeScreen(),
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileScreen(),
        ),
        GetPage(
          name: '/settings',
          page: () => const SettingsScreen(),
        ),
        GetPage(
          name: '/achievements',
          page: () => const AchievementsScreen(),
        ),
        GetPage(
          name: '/leaderboard',
          page: () => const LeaderboardScreen(),
        ),
        // Tic Tac Toe Routes
        GetPage(
          name: '/tic-tac-toe',
          page: () => tic_tac_toe.ModeSelectionScreen(),
          binding: tic_tac_toe.TicTacToeBinding(),
          children: [
            GetPage(
              name: '/game',
              page: () => const tic_tac_toe.TicTacToeGameScreen(),
            ),
            GetPage(
              name: '/stats',
              page: () => const tic_tac_toe.TicTacToeStatsScreen(),
            ),
            GetPage(
              name: '/settings',
              page: () => const tic_tac_toe.TicTacToeSettingsScreen(),
            ),
          ],
        ),
        GetPage(
          name: '/chess',
          page: () => const chess.ChessModeSelectionScreen(),
          binding: ChessBinding(),
        ),
        GetPage(
          name: '/connect-four',
          page: () => const connect_four.ConnectFourModeScreen(),
          binding: const connect_four.ConnectFourBinding(
            gameMode: connect_four.GameMode.vsAI,
          ),
        ),
        GetPage(
          name: '/memory-match',
          page: () => const memory_match.MemoryMatchModeSelectionScreen(),
          binding: MemoryMatchBinding(),
        ),
        GetPage(
          name: '/block-merge',
          page: () => const block_merge.BlockMergeModeSelectionScreen(),
          binding: BlockMergeBinding(),
        ),
        GetPage(
          name: '/flappy-bird',
          page: () => const flappy_bird.FlappyBirdModeSelectionScreen(),
          binding: FlappyBirdBinding(),
        ),
        GetPage(
          name: '/quiz-master',
          page: () => const quiz_master.QuizMasterModeSelectionScreen(),
          binding: QuizMasterBinding(),
        ),
      ],
    );
  }
}
