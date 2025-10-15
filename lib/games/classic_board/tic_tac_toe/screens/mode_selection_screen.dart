import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/game_mode.dart';
import '../controllers/settings_controller.dart';
import '../theme/game_theme.dart';
import '../screens/game_screen.dart';
import '../bindings/game_binding.dart';

class ModeSelectionScreen extends StatelessWidget {
  final _settingsController = Get.find<TicTacToeSettingsController>();

  ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Game Mode'),
        backgroundColor: TicTacToeTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeCard(
              icon: Icons.person,
              title: 'Single Player',
              subtitle: 'Play against AI',
              mode: GameMode.singlePlayer,
            ),
            const SizedBox(height: 16),
            _buildModeCard(
              icon: Icons.people,
              title: 'Two Players',
              subtitle: 'Play with a friend',
              mode: GameMode.multiPlayer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required GameMode mode,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _handleModeSelection(mode),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TicTacToeTheme.primaryColor.withValues(
                    red: TicTacToeTheme.primaryColor.r.toDouble(),
                    green: TicTacToeTheme.primaryColor.g.toDouble(),
                    blue: TicTacToeTheme.primaryColor.b.toDouble(),
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: TicTacToeTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleModeSelection(GameMode mode) {
    _settingsController.updateGameMode(mode);

    Get.to(
      () => const TicTacToeGameScreen(),
      binding: TicTacToeBinding(),
      transition: Transition.rightToLeft,
    );
  }
}
