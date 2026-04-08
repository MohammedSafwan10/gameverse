import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class FlappyBirdSettingsScreen extends StatelessWidget {
  const FlappyBirdSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<FlappyBirdSettingsController>();
    final isCompact = MediaQuery.of(context).size.width < 380;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'SETTINGS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 16 : 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('AUDIO PREFERENCES',
                          Icons.graphic_eq_rounded, Colors.white70),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1.5),
                            ),
                            child: Column(
                              children: [
                                Obx(() => _buildSettingsSwitch(
                                      icon: Icons.volume_up_rounded,
                                      title: 'Sound Effects',
                                      subtitle: 'Jump, score, and crash sounds',
                                      value:
                                          settingsController.soundEnabled.value,
                                      onChanged: (_) =>
                                          settingsController.toggleSound(),
                                      activeColor: Colors.blueAccent,
                                    )),
                                Divider(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    height: 1),
                                Obx(() => _buildSettingsSwitch(
                                      icon: Icons.vibration_rounded,
                                      title: 'Haptic Feedback',
                                      subtitle: 'Vibrate on impact',
                                      value: settingsController
                                          .vibrationEnabled.value,
                                      onChanged: (_) =>
                                          settingsController.toggleVibration(),
                                      activeColor: Colors.blueAccent,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildSectionHeader(
                          'ABOUT', Icons.info_outline_rounded, Colors.white70),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1.5),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.flight_takeoff_rounded,
                                    size: 64, color: Colors.blueAccent),
                                const SizedBox(height: 16),
                                const Text(
                                  'FLAPPY BIRD',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'v2.0.0',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 14,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Tap the screen to fly and avoid the pipes. Try to get the highest score possible!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color activeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value
                  ? activeColor.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: value ? activeColor : Colors.white54, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: activeColor,
            activeTrackColor: activeColor.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}
