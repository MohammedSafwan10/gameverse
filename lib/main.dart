import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'theme/app_theme.dart';
import 'controllers/theme_controller.dart';
import 'games/classic_board/tic_tac_toe/screens/game_screen.dart';
import 'games/classic_board/tic_tac_toe/screens/mode_selection_screen.dart';
import 'games/classic_board/tic_tac_toe/screens/stats_screen.dart';
import 'games/classic_board/tic_tac_toe/screens/settings_screen.dart';
import 'games/classic_board/tic_tac_toe/bindings/game_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize core controllers
  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'GameVerse',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      initialBinding: TicTacToeBinding(),
      getPages: [
        GetPage(
          name: '/',
          page: () => MainNavigationScreen(),
          binding: TicTacToeBinding(),
        ),
        GetPage(
          name: '/settings',
          page: () => const SettingsScreen(),
        ),
        // Tic Tac Toe Routes
        GetPage(
          name: '/tic-tac-toe',
          page: () => ModeSelectionScreen(),
          binding: TicTacToeBinding(),
          children: [
            GetPage(
              name: '/game',
              page: () => const TicTacToeGameScreen(),
              binding: TicTacToeBinding(),
            ),
            GetPage(
              name: '/stats',
              page: () => const TicTacToeStatsScreen(),
              binding: TicTacToeBinding(),
            ),
            GetPage(
              name: '/settings',
              page: () => const TicTacToeSettingsScreen(),
              binding: TicTacToeBinding(),
            ),
          ],
        ),
      ],
    );
  }
}
