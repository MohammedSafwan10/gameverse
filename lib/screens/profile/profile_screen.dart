import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/player_progress.dart';

import '../../widgets/gameverse_utility_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<PlayerProgress>(
        valueListenable: PlayerProgressStore.instance,
        builder: (context, progress, _) => _build(context, progress),
      );

  Widget _build(BuildContext context, PlayerProgress progress) {
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
              key: const Key('profile-scroll-view'),
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 32),
                  sliver: SliverList.list(
                    children: [
                      GameVerseUtilityHeader(
                        title: 'PROFILE',
                        trailing: GameVerseRoundButton(
                          key: const Key('profile-settings-button'),
                          icon: Icons.settings_rounded,
                          tooltip: 'Open settings',
                          onTap: () => Get.toNamed('/settings'),
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 18),
                      _ProfileHero(compact: compact),
                      SizedBox(height: compact ? 14 : 18),
                      _StatsRow(compact: compact, progress: progress),
                      SizedBox(height: compact ? 20 : 26),
                      const _SectionTitle('YOUR GAMEVERSE'),
                      const SizedBox(height: 10),
                      _ProfileMenu(compact: compact),
                      SizedBox(height: compact ? 16 : 22),
                      _LevelProgress(compact: compact, progress: progress),
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
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('profile-hero'),
      constraints: BoxConstraints(minHeight: compact ? 142 : 174),
      padding: EdgeInsets.all(compact ? 16 : 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x28624821), blurRadius: 22, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: compact ? 92 : 120,
                height: compact ? 92 : 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      GameVerseUtilityColors.cobalt,
                      GameVerseUtilityColors.cobaltDark
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x3A063B8E),
                        blurRadius: 14,
                        offset: Offset(0, 7)),
                  ],
                ),
                child: Icon(
                  Icons.face_rounded,
                  color: Colors.white,
                  size: compact ? 58 : 74,
                ),
              ),
              Positioned(
                right: -2,
                bottom: 2,
                child: Container(
                  width: compact ? 28 : 34,
                  height: compact ? 28 : 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF39C85A),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Icon(Icons.check_rounded,
                      size: compact ? 16 : 20, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(width: compact ? 14 : 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest Player',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: GameVerseUtilityColors.ink,
                        fontSize: compact ? 22 : 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Progress saved on this device',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            GameVerseUtilityColors.ink.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: compact ? 10 : 14),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(
                    color: GameVerseUtilityColors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    'LOCAL PLAYER',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: GameVerseUtilityColors.orange,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.compact, required this.progress});
  final PlayerProgress progress;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatTile(
                '${progress.wins}',
                'WINS',
                Icons.emoji_events_rounded,
                GameVerseUtilityColors.gold,
                compact)),
        SizedBox(width: compact ? 8 : 12),
        Expanded(
            child: _StatTile(
                '${progress.played}',
                'RECORDED',
                Icons.sports_esports_rounded,
                GameVerseUtilityColors.mint,
                compact)),
        SizedBox(width: compact ? 8 : 12),
        Expanded(
            child: _StatTile('${progress.games} / 7', 'GAMES',
                Icons.explore_rounded, GameVerseUtilityColors.orange, compact)),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(this.value, this.label, this.icon, this.color, this.compact);

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GameVerseSurface(
      padding: EdgeInsets.symmetric(vertical: compact ? 12 : 16, horizontal: 4),
      radius: compact ? 18 : 22,
      child: Column(
        children: [
          Icon(icon, color: color, size: compact ? 24 : 30),
          SizedBox(height: compact ? 5 : 8),
          FittedBox(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: GameVerseUtilityColors.cobalt,
                    fontSize: compact ? 20 : 25,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: GameVerseUtilityColors.ink,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .6,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded,
            color: GameVerseUtilityColors.cobalt, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: GameVerseUtilityColors.ink,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GameVerseSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _MenuRow(
            key: const Key('profile-achievements-row'),
            title: 'My Achievements',
            icon: Icons.workspace_premium_rounded,
            color: GameVerseUtilityColors.cobalt,
            compact: compact,
            onTap: () => Get.toNamed('/achievements'),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow(
      {super.key,
      required this.title,
      required this.icon,
      required this.color,
      required this.compact,
      required this.onTap});

  final String title;
  final IconData icon;
  final Color color;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16, vertical: compact ? 10 : 13),
          child: Row(
            children: [
              GameVerseIconTile(
                  icon: icon, color: color, size: compact ? 44 : 50),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: GameVerseUtilityColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: GameVerseUtilityColors.ink),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelProgress extends StatelessWidget {
  const _LevelProgress({required this.compact, required this.progress});
  final PlayerProgress progress;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14, vertical: compact ? 12 : 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          GameVerseUtilityColors.cobalt,
          GameVerseUtilityColors.cobaltDark
        ]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33063B8E), blurRadius: 14, offset: Offset(0, 7))
        ],
      ),
      child: Row(
        children: [
          Text(
            'BADGES',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress.unlocked / 9,
                minHeight: 9,
                backgroundColor: Color(0x44071A3D),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF29C8F5)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${progress.unlocked} / 9 UNLOCKED',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
