import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class WhackAMoleSettingsScreen extends GetView<WhackAMoleSettingsController> {
  const WhackAMoleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF0D47A1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Stats Section
                    _buildSection(
                      title: 'Statistics',
                      children: [
                        _buildStatTile(
                          icon: Icons.emoji_events,
                          title: 'High Score',
                          value: Obx(() => Text(
                                '${controller.highScore}',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        ),
                        _buildStatTile(
                          icon: Icons.sports_esports,
                          title: 'Games Played',
                          value: Obx(() => Text(
                                '${controller.gamesPlayed}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              )),
                        ),
                        _buildStatTile(
                          icon: Icons.flash_on,
                          title: 'Best Combo',
                          value: Obx(() => Text(
                                '${controller.bestCombo}x',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sound Settings Section
                    _buildSection(
                      title: 'Sound Settings',
                      children: [
                        _buildSwitchTile(
                          icon: Icons.volume_up,
                          title: 'Sound Effects',
                          value: controller.isSoundEnabled,
                          onChanged: controller.toggleSound,
                        ),
                        _buildSwitchTile(
                          icon: Icons.music_note,
                          title: 'Background Music',
                          value: controller.isMusicEnabled,
                          onChanged: controller.toggleMusic,
                        ),
                        _buildSwitchTile(
                          icon: Icons.vibration,
                          title: 'Haptic Feedback',
                          value: controller.isHapticEnabled,
                          onChanged: controller.toggleHaptic,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Difficulty Settings Section
                    _buildSection(
                      title: 'Difficulty Settings',
                      children: [
                        Obx(() => Column(
                              children: [
                                _buildDifficultyOption(
                                  'Easy',
                                  'Slower moles, fewer bombs',
                                  Icons.sentiment_satisfied,
                                  controller.difficulty.value == 'easy',
                                  () => controller.setDifficulty('easy'),
                                ),
                                _buildDifficultyOption(
                                  'Medium',
                                  'Balanced gameplay',
                                  Icons.sentiment_neutral,
                                  controller.difficulty.value == 'medium',
                                  () => controller.setDifficulty('medium'),
                                ),
                                _buildDifficultyOption(
                                  'Hard',
                                  'Faster moles, more bombs',
                                  Icons.sentiment_very_dissatisfied,
                                  controller.difficulty.value == 'hard',
                                  () => controller.setDifficulty('hard'),
                                ),
                              ],
                            )),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Reset Stats Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _showResetConfirmation(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Reset Statistics',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              red: Colors.white.r.toDouble(),
              green: Colors.white.g.toDouble(),
              blue: Colors.white.b.toDouble(),
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String title,
    required Widget value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          value,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Obx(() => Switch(
                value: value.value,
                onChanged: onChanged,
                activeThumbColor: Colors.greenAccent,
                activeTrackColor: Colors.greenAccent.withValues(
                  red: Colors.greenAccent.r.toDouble(),
                  green: Colors.greenAccent.g.toDouble(),
                  blue: Colors.greenAccent.b.toDouble(),
                  alpha: 0.5,
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _showResetConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Reset Statistics',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to reset all statistics? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Reset',
                  style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      controller.resetStats();
      Get.snackbar(
        'Statistics Reset',
        'All statistics have been reset successfully.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Widget _buildDifficultyOption(
    String title,
    String description,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(
                red: Colors.white.r.toDouble(),
                green: Colors.white.g.toDouble(),
                blue: Colors.white.b.toDouble(),
                alpha: 0.1,
              ),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.greenAccent : Colors.white70,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.greenAccent : Colors.white70,
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(
                        red: Colors.white.r.toDouble(),
                        green: Colors.white.g.toDouble(),
                        blue: Colors.white.b.toDouble(),
                        alpha: 0.5,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
