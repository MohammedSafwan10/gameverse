import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/game_controller.dart';
import '../controllers/stats_controller.dart';

class ConnectFourSettingsScreen extends StatelessWidget {
  // Lazy initialize controllers
  late final settingsController = Get.find<ConnectFourSettingsController>();
  late final statsController = Get.isRegistered<ConnectFourStatsController>()
      ? Get.find<ConnectFourStatsController>()
      : Get.put(ConnectFourStatsController());

  ConnectFourSettingsScreen({super.key}) {
    // Ensure controllers are initialized
    if (!Get.isRegistered<ConnectFourStatsController>()) {
      Get.put(ConnectFourStatsController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Get.theme.colorScheme.primary,
        foregroundColor: Get.theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Get.theme.colorScheme.primary.withValues(
                red: Get.theme.colorScheme.primary.r.toDouble(),
                green: Get.theme.colorScheme.primary.g.toDouble(),
                blue: Get.theme.colorScheme.primary.b.toDouble(),
                alpha: 0.9,
              ),
              Get.theme.colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildGameplaySection(),
              const SizedBox(height: 16),
              _buildSoundSection(),
              const SizedBox(height: 16),
              _buildResetSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameplaySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Gameplay',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Obx(() => ListTile(
                title: const Text('Game Mode'),
                subtitle: Text(
                  settingsController.gameMode.value == GameMode.pvp
                      ? 'Player vs Player'
                      : 'Player vs AI',
                ),
                trailing: SegmentedButton<GameMode>(
                  segments: const [
                    ButtonSegment<GameMode>(
                      value: GameMode.pvp,
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('PvP'),
                      ),
                    ),
                    ButtonSegment<GameMode>(
                      value: GameMode.vsAI,
                      label: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('vs AI'),
                      ),
                    ),
                  ],
                  selected: {settingsController.gameMode.value},
                  onSelectionChanged: (Set<GameMode> selected) {
                    settingsController.setGameMode(selected.first);
                  },
                  style: ButtonStyle(
                    maximumSize: WidgetStateProperty.all(const Size(200, 40)),
                  ),
                ),
              )),
          Obx(() => AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState:
                    settingsController.gameMode.value == GameMode.vsAI
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      title: Text('AI Difficulty'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SegmentedButton<AIDifficulty>(
                        segments: [
                          ButtonSegment<AIDifficulty>(
                            value: AIDifficulty.easy,
                            label: Text('Easy', textAlign: TextAlign.center),
                            icon: const Icon(Icons.sentiment_satisfied),
                          ),
                          ButtonSegment<AIDifficulty>(
                            value: AIDifficulty.medium,
                            label: Text('Medium', textAlign: TextAlign.center),
                            icon: const Icon(Icons.sentiment_neutral),
                          ),
                          ButtonSegment<AIDifficulty>(
                            value: AIDifficulty.hard,
                            label: Text('Hard', textAlign: TextAlign.center),
                            icon: const Icon(Icons.sentiment_very_dissatisfied),
                          ),
                        ],
                        selected: {settingsController.difficulty.value},
                        onSelectionChanged: (Set<AIDifficulty> selected) {
                          settingsController.setDifficulty(selected.first);
                        },
                        showSelectedIcon: false,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                secondChild: const SizedBox(height: 0),
              )),
          Obx(() => SwitchListTile(
                title: const Text('Auto Restart Game'),
                subtitle: const Text(
                  'Automatically start a new game after the current one ends',
                ),
                value: settingsController.isAutoRestartEnabled.value,
                onChanged: (value) {
                  settingsController.toggleAutoRestart();
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSoundSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Sound & Haptics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Obx(() => SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Play sounds during gameplay'),
                value: settingsController.isSoundEnabled.value,
                onChanged: (value) {
                  settingsController.toggleSound();
                },
              )),
          Obx(() => SwitchListTile(
                title: const Text('Vibration'),
                subtitle: const Text('Vibrate on moves and game events'),
                value: settingsController.isVibrationEnabled.value,
                onChanged: (value) {
                  settingsController.toggleVibration();
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildResetSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Reset Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Builder(
            builder: (context) => ListTile(
              title: const Text('Reset All Settings'),
              subtitle: const Text('Restore default game settings'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _showResetConfirmationDialog(
                    context,
                    'Reset Settings',
                    'Are you sure you want to reset all settings to default values?',
                    () {
                      settingsController.resetToDefaults();
                      Get.back();
                    },
                  );
                },
                child: const Text('Reset'),
              ),
            ),
          ),
          Builder(
            builder: (context) => ListTile(
              title: const Text('Reset Statistics'),
              subtitle: const Text('Clear all game statistics'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _showResetConfirmationDialog(
                    context,
                    'Reset Statistics',
                    'Are you sure you want to reset all statistics? This cannot be undone.',
                    () {
                      statsController.resetAllStats();
                      Get.back();
                    },
                  );
                },
                child: const Text('Reset'),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _showResetConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: onConfirm,
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
