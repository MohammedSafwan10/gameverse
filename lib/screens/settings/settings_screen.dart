import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Get.theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
          color: Get.theme.colorScheme.primary,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            _buildSection(
              'About',
              [
                Container(
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withValues(
                        red: 0,
                        green: 0,
                        blue: 0,
                        alpha: 0.1 * 255,
                      ),
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      _buildSettingTile(
                        'Version',
                        '1.0.0',
                        leading: const Icon(Icons.info_outline),
                      ),
                      const Divider(height: 1),
                      _buildSettingTile(
                        'Developer',
                        'NEXDARK TEAM',
                        leading: const Icon(Icons.code),
                      ),
                      const Divider(height: 1),
                      _buildSettingTile(
                        'Contact Us',
                        'itzmesafwan1@gmail.com',
                        leading: const Icon(Icons.email_outlined),
                        onTap: () {
                          // Launch email client
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
          child: Text(
            title.toUpperCase(),
            style: Get.textTheme.titleMedium?.copyWith(
              color: Get.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle, {
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: Get.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Get.textTheme.bodyMedium?.copyWith(
          color: Get.theme.colorScheme.onSurface.withValues(
            red: Get.theme.colorScheme.onSurface.r.toDouble(),
            green: Get.theme.colorScheme.onSurface.g.toDouble(),
            blue: Get.theme.colorScheme.onSurface.b.toDouble(),
            alpha: 0.7 * 255,
          ),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
