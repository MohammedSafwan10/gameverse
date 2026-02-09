import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';
import 'package:gameverse/widgets/premium_background.dart';

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
        title: const Text('Connect Four Settings'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          const PremiumBackground(),
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
                        context, 'Danger Zone', Icons.dangerous_outlined),
                    _buildSettingsCard(
                      context,
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.refresh_rounded,
                                color: Colors.red),
                          ),
                          title: Text(
                            'Reset All Settings',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          onTap: () => _showResetConfirmation(
                              context,
                              'Settings',
                              () => settingsController.resetToDefaults()),
                        ),
                        _buildDivider(),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.analytics_outlined,
                                color: Colors.red),
                          ),
                          title: Text(
                            'Clear Statistics',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
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

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context,
      {required List<Widget> children}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
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
    final theme = Theme.of(context);
    return Obx(() => SwitchListTile(
          value: value.value,
          onChanged: (val) {
            onChanged(val);
          },
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall,
          ),
          activeThumbColor: theme.colorScheme.primary,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ));
  }

  Widget _buildDivider() {
    return const Divider(indent: 64, endIndent: 16);
  }

  void _showResetConfirmation(
      BuildContext context, String target, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Reset $target?'),
        content: Text(
            'Are you sure you want to reset all game $target? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              onConfirm();
              Get.back();
              Get.snackbar('Reset Complete', '$target have been cleared.',
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}
