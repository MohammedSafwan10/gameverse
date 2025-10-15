import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';

class FlappyBirdSettingsScreen extends StatelessWidget {
  const FlappyBirdSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<FlappyBirdSettingsController>();

    return PopScope(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF64B5F6),
                Color(0xFF1976D2),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      const Expanded(
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the header
                    ],
                  ),
                ),

                // Settings List
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(title: 'Audio'),
                        const SizedBox(height: 8),
                        Obx(() => _SettingsSwitch(
                              icon: Icons.volume_up,
                              title: 'Sound Effects',
                              value: settingsController.soundEnabled.value,
                              onChanged: (value) =>
                                  settingsController.toggleSound(),
                            )),
                        const SizedBox(height: 8),
                        Obx(() => _SettingsSwitch(
                              icon: Icons.music_note,
                              title: 'Background Music',
                              value: settingsController.musicEnabled.value,
                              onChanged: (value) =>
                                  settingsController.toggleMusic(),
                            )),
                        const SizedBox(height: 24),
                        const _SectionHeader(title: 'Feedback'),
                        const SizedBox(height: 8),
                        Obx(() => _SettingsSwitch(
                              icon: Icons.vibration,
                              title: 'Vibration',
                              value: settingsController.vibrationEnabled.value,
                              onChanged: (value) =>
                                  settingsController.toggleVibration(),
                            )),
                        const SizedBox(height: 32),
                        Center(
                          child: TextButton.icon(
                            onPressed: () async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Reset High Score'),
                                  content: const Text(
                                      'Are you sure you want to reset your high score? This cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Reset'),
                                    ),
                                  ],
                                ),
                              );
                              if (result == true) {
                                final gameController =
                                    Get.find<FlappyBirdGameController>();
                                await gameController.resetStats();
                                Get.snackbar(
                                  'Success',
                                  'High score has been reset',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            label: const Text(
                              'Reset High Score',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(
        red: Colors.white.r.toDouble(),
        green: Colors.white.g.toDouble(),
        blue: Colors.white.b.toDouble(),
        alpha: 0.1,
      ),
      borderRadius: BorderRadius.circular(12),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        activeThumbColor: Colors.white,
        activeTrackColor: Colors.green,
        inactiveThumbColor: Colors.white60,
        inactiveTrackColor: Colors.white24,
      ),
    );
  }
}
