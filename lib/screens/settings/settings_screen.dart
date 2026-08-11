import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/gameverse_utility_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 700 || size.width <= 330;
    final horizontal = size.width <= 330 ? 14.0 : 20.0;

    return Scaffold(
      backgroundColor: GameVerseUtilityColors.cream,
      body: Stack(
        children: [
          const GameVerseUtilityBackground(),
          SafeArea(
            child: CustomScrollView(
              key: const Key('settings-scroll-view'),
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 32),
                  sliver: SliverList.list(
                    children: [
                      const GameVerseUtilityHeader(title: 'SETTINGS'),
                      SizedBox(height: compact ? 12 : 18),
                      _SettingsHero(compact: compact),
                      SizedBox(height: compact ? 18 : 24),
                      _SettingsSection(
                        title: 'SYSTEM',
                        icon: Icons.settings_rounded,
                        rows: const [
                          _SettingData('Version', '1.0.0', Icons.info_rounded,
                              GameVerseUtilityColors.cobalt),
                          _SettingData(
                              'Storage',
                              '12.4 MB used',
                              Icons.storage_rounded,
                              GameVerseUtilityColors.mint),
                        ],
                        compact: compact,
                      ),
                      SizedBox(height: compact ? 18 : 24),
                      _SettingsSection(
                        title: 'SUPPORT',
                        icon: Icons.headset_mic_rounded,
                        rows: [
                          _SettingData(
                            'Contact Us',
                            'itzmesafwan1@gmail.com',
                            Icons.email_rounded,
                            GameVerseUtilityColors.pink,
                            onTap: () => launchUrl(
                                Uri.parse('mailto:itzmesafwan1@gmail.com')),
                          ),
                          _SettingData(
                            'Rate Game',
                            'Enjoying GameVerse?',
                            Icons.star_rounded,
                            GameVerseUtilityColors.gold,
                            onTap: () => _showThanks(context),
                          ),
                        ],
                        compact: compact,
                      ),
                      SizedBox(height: compact ? 18 : 24),
                      _SettingsSection(
                        title: 'LEGAL',
                        icon: Icons.balance_rounded,
                        rows: [
                          _SettingData(
                            'Privacy Policy',
                            'How we handle your data',
                            Icons.shield_rounded,
                            GameVerseUtilityColors.cobalt,
                            onTap: () => _showInfo(context, 'Privacy Policy',
                                'GameVerse stores game progress locally on your device. A complete published privacy policy will be available before release.'),
                          ),
                          _SettingData(
                            'Terms of Service',
                            'Usage rules and info',
                            Icons.description_rounded,
                            GameVerseUtilityColors.mint,
                            onTap: () => _showInfo(context, 'Terms of Service',
                                'Use GameVerse fairly, respect other players, and enjoy the games. Full release terms will be available before publication.'),
                          ),
                        ],
                        compact: compact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showThanks(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks for playing GameVerse!')),
    );
  }

  Future<void> _showInfo(BuildContext context, String title, String body) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameVerseUtilityColors.cream,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('settings-hero'),
      height: compact ? 104 : 126,
      padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            GameVerseUtilityColors.cobalt,
            GameVerseUtilityColors.cobaltDark
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF3E8BF2), width: 2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x38063B8E), blurRadius: 18, offset: Offset(0, 9))
        ],
      ),
      child: Row(
        children: [
          GameVerseIconTile(
            icon: Icons.sports_esports_rounded,
            color: GameVerseUtilityColors.orange,
            size: compact ? 62 : 76,
          ),
          SizedBox(width: compact ? 14 : 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MAKE IT YOURS',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontSize: compact ? 21 : 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.3,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Everything about your GameVerse app',
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.star_rounded,
              color: GameVerseUtilityColors.gold, size: 28),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection(
      {required this.title,
      required this.icon,
      required this.rows,
      required this.compact});

  final String title;
  final IconData icon;
  final List<_SettingData> rows;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                  color: GameVerseUtilityColors.creamDeep,
                  shape: BoxShape.circle),
              child: Icon(icon, size: 19, color: const Color(0xFF9A6B16)),
            ),
            const SizedBox(width: 9),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: GameVerseUtilityColors.ink,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .4,
                  ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Divider(color: Color(0x55B98C3D))),
          ],
        ),
        const SizedBox(height: 9),
        GameVerseSurface(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < rows.length; index++) ...[
                _SettingRow(data: rows[index], compact: compact),
                if (index != rows.length - 1)
                  const Divider(
                      height: 1,
                      indent: 76,
                      endIndent: 16,
                      color: Color(0x1A071A3D)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.data, required this.compact});

  final _SettingData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16, vertical: compact ? 10 : 13),
          child: Row(
            children: [
              GameVerseIconTile(
                  icon: data.icon, color: data.color, size: compact ? 44 : 50),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: GameVerseUtilityColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: GameVerseUtilityColors.ink
                                .withValues(alpha: 0.64),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              if (data.onTap != null)
                const Icon(Icons.chevron_right_rounded,
                    color: GameVerseUtilityColors.ink),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingData {
  const _SettingData(this.title, this.subtitle, this.icon, this.color,
      {this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
}
