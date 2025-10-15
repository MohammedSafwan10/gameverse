import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class BlockMergeSettingsScreen extends StatelessWidget {
  const BlockMergeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BlockMergeSettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade200,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSettingsSection(
              title: 'Game Settings',
              children: [
                Obx(() => SwitchListTile(
                      title: const Text('Sound Effects'),
                      subtitle:
                          const Text('Play sound effects during gameplay'),
                      value: controller.soundEnabled.value,
                      onChanged: controller.setSoundEnabled,
                      activeThumbColor: Colors.orange.shade800,
                    )),
                Obx(() => SwitchListTile(
                      title: const Text('Vibration'),
                      subtitle: const Text('Vibrate on merges and moves'),
                      value: controller.vibrationEnabled.value,
                      onChanged: controller.setVibrationEnabled,
                      activeThumbColor: Colors.orange.shade800,
                    )),
                Obx(() => SwitchListTile(
                      title: const Text('Show Tutorial'),
                      subtitle: const Text('Show tutorial on game start'),
                      value: controller.showTutorial.value,
                      onChanged: controller.setShowTutorial,
                      activeThumbColor: Colors.orange.shade800,
                    )),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingsSection(
              title: 'Statistics',
              children: [
                Obx(() => ListTile(
                      title: const Text('Best Score'),
                      trailing: Text(
                        controller.bestScore.value.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                Obx(() => ListTile(
                      title: const Text('Games Played'),
                      trailing: Text(
                        controller.gamesPlayed.value.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                Obx(() => ListTile(
                      title: const Text('Games Won'),
                      trailing: Text(
                        controller.gamesWon.value.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                Obx(() => ListTile(
                      title: const Text('Win Rate'),
                      trailing: Text(
                        controller.getWinRate(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                Obx(() => ListTile(
                      title: const Text('Highest Tile'),
                      trailing: Text(
                        controller.highestTile.value.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        const Text('Reset Statistics'),
                      ],
                    ),
                    content: const Text(
                        'Are you sure you want to reset all statistics? This cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.orange.shade800),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.resetStatistics();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade800,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Reset Statistics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
