import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../models/game_mode.dart';
import '../models/game_difficulty.dart';
import '../utils/animations.dart';
import '../theme/game_theme.dart';

class TicTacToeSettingsScreen extends StatefulWidget {
  const TicTacToeSettingsScreen({super.key});

  @override
  State<TicTacToeSettingsScreen> createState() => _TicTacToeSettingsScreenState();
}

class _TicTacToeSettingsScreenState extends State<TicTacToeSettingsScreen> {
  final settingsController = Get.find<TicTacToeSettingsController>();
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _showContent = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TicTacToeTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: TicTacToeTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Game Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGameplaySection(context),
              const SizedBox(height: 24),
              _buildSoundSection(context),
              const SizedBox(height: 24),
              _buildResetSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    int index = 0,
  }) {
    return TicTacToeAnimations.fadeSlide(
      show: _showContent,
      offset: const Offset(0.2, 0),
      duration: TicTacToeAnimations.defaultDuration +
          Duration(milliseconds: index * 100),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: TicTacToeTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              ...children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: child,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameplaySection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Gameplay',
      index: 0,
      children: [
        Obx(() => ListTile(
          title: const Text('Game Mode'),
          subtitle: Text(settingsController.settings.gameMode.displayName),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showModeSelection(context),
        )),
        Obx(() {
          if (settingsController.settings.gameMode == GameMode.singlePlayer) {
            return ListTile(
              title: const Text('Difficulty'),
              subtitle: Text(settingsController.settings.difficulty.displayName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDifficultySelection(context),
            );
          }
          return const SizedBox.shrink();
        }),
        Obx(() => SwitchListTile(
          title: const Text('Auto Restart'),
          subtitle: const Text('Start a new game automatically after each game'),
          value: settingsController.settings.autoRestart,
          onChanged: (value) => settingsController.toggleAutoRestart(),
        )),
      ],
    );
  }

  Widget _buildSoundSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Sound & Haptics',
      index: 1,
      children: [
        Obx(() => SwitchListTile(
          title: const Text('Sound Effects'),
          value: settingsController.settings.soundEnabled,
          onChanged: (value) => settingsController.toggleSound(),
        )),
        Obx(() => SwitchListTile(
          title: const Text('Vibration'),
          value: settingsController.settings.vibrationEnabled,
          onChanged: (value) => settingsController.toggleVibration(),
        )),
      ],
    );
  }

  Widget _buildResetSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Reset',
      index: 3,
      children: [
        ListTile(
          title: const Text('Reset to Defaults'),
          subtitle: const Text('Restore all settings to their default values'),
          trailing: const Icon(Icons.restore),
          onTap: () => _showResetConfirmation(context),
        ),
      ],
    );
  }

  void _showModeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Game Mode',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TicTacToeTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          ...GameMode.values.map((mode) => ListTile(
            leading: Icon(mode.icon, color: TicTacToeTheme.primaryColor),
            title: Text(mode.displayName),
            subtitle: Text(mode.description),
            trailing: Obx(() => settingsController.settings.gameMode == mode
              ? const Icon(Icons.check, color: TicTacToeTheme.primaryColor)
              : const SizedBox.shrink()),
            onTap: () {
              settingsController.updateGameMode(mode);
              Get.back();
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDifficultySelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Difficulty',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: TicTacToeTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          ...GameDifficulty.values.map((difficulty) => ListTile(
            leading: Icon(_getDifficultyIcon(difficulty), color: TicTacToeTheme.primaryColor),
            title: Text(difficulty.displayName),
            subtitle: Text(_getDifficultyDescription(difficulty)),
            trailing: Obx(() => settingsController.settings.difficulty == difficulty
              ? const Icon(Icons.check, color: TicTacToeTheme.primaryColor)
              : const SizedBox.shrink()),
            onTap: () {
              settingsController.updateDifficulty(difficulty);
              Get.back();
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getDifficultyIcon(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return Icons.sentiment_satisfied;
      case GameDifficulty.medium:
        return Icons.sentiment_neutral;
      case GameDifficulty.hard:
        return Icons.sentiment_dissatisfied;
      case GameDifficulty.impossible:
        return Icons.psychology;
    }
  }

  String _getDifficultyDescription(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'Perfect for beginners';
      case GameDifficulty.medium:
        return 'Balanced challenge';
      case GameDifficulty.hard:
        return 'For experienced players';
      case GameDifficulty.impossible:
        return 'Unbeatable AI';
    }
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              settingsController.resetToDefaults();
              Get.back();
              Get.snackbar(
                'Settings Reset',
                'All settings have been restored to their default values.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.white,
                colorText: Colors.black,
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
