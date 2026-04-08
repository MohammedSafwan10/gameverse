import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gameverse/theme/app_theme.dart';
import 'package:gameverse/widgets/premium_background.dart';
import '../controllers/settings_controller.dart';
import '../models/game_mode.dart';
import '../models/game_difficulty.dart';
import '../utils/animations.dart';
import '../theme/game_theme.dart';

class TicTacToeSettingsScreen extends StatefulWidget {
  const TicTacToeSettingsScreen({super.key});

  @override
  State<TicTacToeSettingsScreen> createState() =>
      _TicTacToeSettingsScreenState();
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const PremiumBackground(),
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/games/tic_tac_toe.png',
                  fit: BoxFit.cover,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.22),
                        const Color(0xFF0F172A).withValues(alpha: 0.94),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildGameplaySection(context),
                  const SizedBox(height: 18),
                  _buildSoundSection(context),
                  const SizedBox(height: 18),
                  _buildStatsSection(context),
                  const SizedBox(height: 18),
                  _buildResetSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Get.back(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Game Settings',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Tic Tac Toe',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Statistics',
      index: 2,
      children: [
        ListTile(
          title: const Text('Reset Current Mode Stats'),
          subtitle: const Text('Clear stats for the current game mode'),
          trailing: const Icon(Icons.refresh),
          onTap: () => _showStatsResetConfirmation(context, false),
        ),
        ListTile(
          title: const Text('Reset All Stats'),
          subtitle: const Text('Clear all statistics and achievements'),
          trailing: const Icon(Icons.delete_forever),
          onTap: () => _showStatsResetConfirmation(context, true),
        ),
      ],
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
        color: Colors.white.withValues(alpha: 0.06),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 16),
              ...children.map((child) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        listTileTheme: ListTileThemeData(
                          iconColor: Colors.white70,
                          textColor: Colors.white,
                          subtitleTextStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white.withValues(alpha: 0.65)),
                        ),
                        switchTheme: SwitchThemeData(
                          thumbColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? AppTheme.primaryColor
                                : Colors.white70,
                          ),
                          trackColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? AppTheme.primaryColor.withValues(alpha: 0.4)
                                : Colors.white24,
                          ),
                        ),
                      ),
                      child: child,
                    ),
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
              subtitle:
                  Text(settingsController.settings.difficulty.displayName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDifficultySelection(context),
            );
          }
          return const SizedBox.shrink();
        }),
        Obx(() => SwitchListTile(
              title: const Text('Auto Restart'),
              subtitle:
                  const Text('Start a new game automatically after each game'),
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Game Mode',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 24),
            ...GameMode.values.map((mode) {
              final isSelected = settingsController.settings.gameMode == mode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    settingsController.updateGameMode(mode);
                    Get.back();
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TicTacToeTheme.primaryColor.withValues(alpha: 0.16)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? TicTacToeTheme.primaryColor.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? TicTacToeTheme.primaryColor.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            mode.icon,
                            color: isSelected
                                ? TicTacToeTheme.primaryColor
                                : Colors.white70,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mode.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mode.description,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: TicTacToeTheme.primaryColor,
                            size: 28,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDifficultySelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 8),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          child: BackdropFilter(
            filter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.1),
              BlendMode.darken,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 40,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Colors.white70],
                    ).createShader(bounds),
                    child: Text(
                      'AI Challenge',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how smart the AI should be',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...GameDifficulty.values.map((difficulty) {
                    final isSelected =
                        settingsController.settings.difficulty == difficulty;
                    final diffColor = _getDifficultyColor(difficulty);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          settingsController.updateDifficulty(difficulty);
                          Get.back();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      diffColor.withValues(alpha: 0.25),
                                      diffColor.withValues(alpha: 0.08),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.06),
                                      Colors.white.withValues(alpha: 0.02),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isSelected
                                  ? diffColor.withValues(alpha: 0.6)
                                  : Colors.white.withValues(alpha: 0.08),
                              width: isSelected ? 2 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: diffColor.withValues(alpha: 0.15),
                                      blurRadius: 20,
                                      spreadRadius: -2,
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? diffColor.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: diffColor.withValues(alpha: 0.1),
                                            blurRadius: 10,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Icon(
                                  _getDifficultyIcon(difficulty),
                                  color: isSelected ? diffColor : Colors.white60,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      difficulty.displayName,
                                      style: TextStyle(
                                        color: isSelected ? diffColor : Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getDifficultyDescription(difficulty),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.45),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: diffColor,
                                    size: 16,
                                    weight: 800,
                                  ),
                                ).animate().scale(duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return Colors.greenAccent;
      case GameDifficulty.medium:
        return Colors.amberAccent;
      case GameDifficulty.hard:
        return Colors.orangeAccent;
      case GameDifficulty.impossible:
        return Colors.redAccent;
    }
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

  void _showStatsResetConfirmation(BuildContext context, bool allStats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        surfaceTintColor: Colors.transparent,
        title: Text(allStats ? 'Reset All Stats?' : 'Reset Mode Stats?'),
        content: Text(allStats
            ? 'This will permanentely delete all your game statistics and achievements. This action cannot be undone.'
            : 'This will reset statistics for the current game mode. This action cannot be undone.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.72))),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (allStats) {
                await settingsController.resetAllStats();
              } else {
                await settingsController.resetCurrentModeStats();
              }
              Get.back();
              Get.snackbar(
                'Stats Reset',
                'Statistics have been cleared.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.white,
                colorText: Colors.black,
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        surfaceTintColor: Colors.transparent,
        title: const Text('Reset Settings'),
        content: const Text(
            'Are you sure you want to reset all settings to their default values?'),
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
