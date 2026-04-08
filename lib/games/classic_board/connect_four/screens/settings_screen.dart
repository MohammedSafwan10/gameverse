import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';
import 'package:gameverse/theme/app_theme.dart';

class ConnectFourSettingsScreen extends StatelessWidget {
  late final settingsController = Get.find<ConnectFourSettingsController>();
  late final statsController = Get.isRegistered<ConnectFourStatsController>()
      ? Get.find<ConnectFourStatsController>()
      : Get.put(ConnectFourStatsController());

  ConnectFourSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(40)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Colors.white),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Connect Four specific animated/gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E3A8A), // Deep blue
                  Color(0xFF0F172A),
                ],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withAlpha(38),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withAlpha(50),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withAlpha(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withAlpha(38),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Game Preferences', Icons.tune),
                    _buildSettingsCard(
                      context,
                      children: [
                        _buildSwitchTile(
                          context,
                          title: 'Auto Restart',
                          subtitle: 'New match starts automatically',
                          icon: Icons.replay_rounded,
                          value: settingsController.isAutoRestartEnabled,
                          onChanged: (_) =>
                              settingsController.toggleAutoRestart(),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          context,
                          title: 'Sound Effects',
                          subtitle: 'Play audio during game',
                          icon: Icons.volume_up_outlined,
                          value: settingsController.isSoundEnabled,
                          onChanged: (_) => settingsController.toggleSound(),
                        ),
                        _buildDivider(),
                        _buildSwitchTile(
                          context,
                          title: 'Haptic Feedback',
                          subtitle: 'Vibrate on moves',
                          icon: Icons.vibration_rounded,
                          value: settingsController.isVibrationEnabled,
                          onChanged: (_) =>
                              settingsController.toggleVibration(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle(
                        context, 'Danger Zone', Icons.dangerous_outlined,
                        isDanger: true),
                    _buildSettingsCard(
                      context,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withAlpha(38),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.redAccent.withAlpha(60)),
                            ),
                            child: const Icon(Icons.refresh_rounded,
                                color: Colors.redAccent, size: 20),
                          ),
                          title: const Text(
                            'Reset All Settings',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                          ),
                          onTap: () => _showResetConfirmation(
                              context,
                              'Settings',
                              () => settingsController.resetToDefaults()),
                        ),
                        _buildDivider(),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withAlpha(38),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.redAccent.withAlpha(60)),
                            ),
                            child: const Icon(Icons.analytics_outlined,
                                color: Colors.redAccent, size: 20),
                          ),
                          title: const Text(
                            'Clear Statistics',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16),
                          ),
                          onTap: () => _showResetConfirmation(
                              context,
                              'Statistics',
                              () => statsController.resetAllStats()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon,
      {bool isDanger = false}) {
    final color = isDanger ? Colors.redAccent : Colors.blueAccent;
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
              color: color.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required List<Widget> children}) {
    return Container(
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white.withAlpha(10),
        borderColor: Colors.white.withAlpha(20),
        borderRadius: 24,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Obx(() => SwitchListTile(
          value: value.value,
          onChanged: (val) {
            onChanged(val);
          },
          secondary: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withAlpha(38),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent.withAlpha(60)),
            ),
            child: Icon(icon, color: Colors.blueAccent, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12),
          ),
          activeThumbColor: Colors.blueAccent,
          activeTrackColor: Colors.blueAccent.withAlpha(60),
          inactiveThumbColor: Colors.white.withAlpha(60),
          inactiveTrackColor: Colors.white.withAlpha(20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ));
  }

  Widget _buildDivider() {
    return Divider(
        indent: 64,
        endIndent: 16,
        color: Colors.white.withAlpha(20),
        height: 1);
  }

  void _showResetConfirmation(
      BuildContext context, String target, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        title: Text('Reset $target?',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to reset all game $target? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('CANCEL',
                  style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () {
              onConfirm();
              Get.back();
              Get.snackbar(
                'Reset Complete',
                '$target have been cleared.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.shade800,
                colorText: Colors.white,
                borderRadius: 16,
                margin: const EdgeInsets.all(16),
              );
            },
            child: const Text('RESET',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
