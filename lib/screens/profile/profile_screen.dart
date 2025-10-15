import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[100]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildStats(),
                  const SizedBox(height: 32),
                  _buildActions(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'profile_avatar',
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    red: 0,
                    green: 0,
                    blue: 0,
                    alpha: 0.1 * 255,
                  ),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Get.theme.primaryColor.withValues(
                red: Get.theme.primaryColor.r.toDouble(),
                green: Get.theme.primaryColor.g.toDouble(),
                blue: Get.theme.primaryColor.b.toDouble(),
                alpha: 0.1 * 255,
              ),
              child: Text(
                'P',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Get.theme.primaryColor,
                ),
              ),
            ),
          ),
        ).animate().fadeIn().scale(),
        const SizedBox(height: 16),
        Text(
          'Player',
          style: Get.textTheme.headlineMedium?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn().moveY(begin: 10, end: 0),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              red: 0,
              green: 0,
              blue: 0,
              alpha: 0.05 * 255,
            ),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              'Level',
              '1',
              Icons.star_rounded,
            ),
            VerticalDivider(
              color: Colors.grey.withValues(
                red: Colors.grey.r.toDouble(),
                green: Colors.grey.g.toDouble(),
                blue: Colors.grey.b.toDouble(),
                alpha: 0.2 * 255,
              ),
              thickness: 1,
            ),
            _buildStatItem(
              'Games',
              '0',
              Icons.sports_esports_rounded,
            ),
            VerticalDivider(
              color: Colors.grey.withValues(
                red: Colors.grey.r.toDouble(),
                green: Colors.grey.g.toDouble(),
                blue: Colors.grey.b.toDouble(),
                alpha: 0.2 * 255,
              ),
              thickness: 1,
            ),
            _buildStatItem(
              'Wins',
              '0',
              Icons.emoji_events_rounded,
            ),
          ],
        ),
      ),
    ).animate().fadeIn().moveY(begin: 20, end: 0);
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor.withValues(
                red: Get.theme.primaryColor.r.toDouble(),
                green: Get.theme.primaryColor.g.toDouble(),
                blue: Get.theme.primaryColor.b.toDouble(),
                alpha: 0.1 * 255,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Get.theme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              red: 0,
              green: 0,
              blue: 0,
              alpha: 0.05 * 255,
            ),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.settings_rounded,
            title: 'Settings',
            onTap: () => Get.toNamed('/settings'),
          ),
          Divider(
            color: Colors.grey.withValues(
              red: Colors.grey.r.toDouble(),
              green: Colors.grey.g.toDouble(),
              blue: Colors.grey.b.toDouble(),
              alpha: 0.2 * 255,
            ),
            height: 1,
          ),
          _buildActionTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () => _showHelpSupportDialog(context),
          ),
        ],
      ),
    ).animate().fadeIn().moveY(begin: 30, end: 0);
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: color ?? Colors.black87,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: Get.textTheme.titleMedium?.copyWith(
                  color: color ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (color == null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black54,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showHelpSupportDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSupportOption(
              icon: Icons.email_rounded,
              title: 'Email Support',
              subtitle: 'support@.com',
              onTap: () => launchUrl(Uri.parse('mailto:support@.com')),
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              icon: Icons.chat_rounded,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              onTap: () => launchUrl(Uri.parse('https://.com/chat')),
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              icon: Icons.help_rounded,
              title: 'FAQs',
              subtitle: 'View frequently asked questions',
              onTap: () => launchUrl(Uri.parse('https://.com/faq')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withValues(
                    red: Get.theme.primaryColor.r.toDouble(),
                    green: Get.theme.primaryColor.g.toDouble(),
                    blue: Get.theme.primaryColor.b.toDouble(),
                    alpha: 0.1 * 255,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Get.theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
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


}
