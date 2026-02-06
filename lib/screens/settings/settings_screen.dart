import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // App Info Section
            _buildSectionHeader('System'),
            _buildSettingsGroup([
              _buildSettingTile(
                'Version',
                '1.0.0',
                Icons.info_outline,
                Colors.blue,
              ),
              _buildDivider(),
              _buildSettingTile(
                'Storage',
                '12.4 MB used',
                Icons.storage_rounded,
                Colors.orange,
              ),
            ]),

            const SizedBox(height: 32),

            // Community & Social
            _buildSectionHeader('Support'),
            _buildSettingsGroup([
              _buildSettingTile(
                'Contact Us',
                'itzmesafwan1@gmail.com',
                Icons.email_outlined,
                Colors.teal,
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingTile(
                'Developer',
                'NEXDARK TEAM',
                Icons.code_rounded,
                Colors.indigo,
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingTile(
                'Rate Game',
                'Enjoying GameVerse?',
                Icons.star_outline_rounded,
                Colors.amber,
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 32),

            // Legal
            _buildSectionHeader('Legal'),
            _buildSettingsGroup([
              _buildSettingTile(
                'Privacy Policy',
                'How we handle your data',
                Icons.security_rounded,
                Colors.green,
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingTile(
                'Terms of Service',
                'Usage rules and info',
                Icons.description_outlined,
                Colors.grey,
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 48),

            // App Footer
            Center(
              child: Column(
                children: [
                  const Text(
                    'GameVerse',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Built with ❤️ by NEXDARK',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[400],
          letterSpacing: 2,
        ),
      ).animate().fadeIn().slideX(begin: -0.2),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildSettingTile(
      String title, String subtitle, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1, indent: 68, endIndent: 20, color: Colors.grey[50]);
  }
}
