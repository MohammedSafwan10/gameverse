import 'package:flutter/material.dart';

import '../../widgets/gameverse_utility_widgets.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const _groups = [
    _AchievementGroup(
      title: 'BEGINNER',
      color: GameVerseUtilityColors.mint,
      icon: Icons.star_rounded,
      achievements: [
        _Achievement(
            'First Win', 'Win your first game', 1, Icons.emoji_events_rounded),
        _Achievement('Game Explorer', 'Play three different games', 1,
            Icons.explore_rounded),
        _Achievement('Quick Learner', 'Finish a how-to-play guide', 1,
            Icons.school_rounded),
      ],
    ),
    _AchievementGroup(
      title: 'INTERMEDIATE',
      color: GameVerseUtilityColors.orange,
      icon: Icons.local_fire_department_rounded,
      achievements: [
        _Achievement('Winning Streak', 'Win 5 games in a row', .6,
            Icons.local_fire_department_rounded),
        _Achievement('Sharp Mind', 'Complete 10 brain games', .3,
            Icons.psychology_rounded),
        _Achievement('High Scorer', 'Reach 5,000 total points', 0,
            Icons.trending_up_rounded),
      ],
    ),
    _AchievementGroup(
      title: 'EXPERT',
      color: Color(0xFF9A7B4F),
      icon: Icons.workspace_premium_rounded,
      achievements: [
        _Achievement('GameVerse Legend', 'Master every game', .2,
            Icons.workspace_premium_rounded),
        _Achievement('Unbeatable', 'Win 50 matches', 0, Icons.shield_rounded),
        _Achievement('Perfect Player', 'Unlock every achievement', 0,
            Icons.auto_awesome_rounded),
      ],
    ),
  ];

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
              key: const Key('achievements-scroll-view'),
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 28),
                  sliver: SliverList.list(
                    children: [
                      const GameVerseUtilityHeader(title: 'ACHIEVEMENTS'),
                      SizedBox(height: compact ? 12 : 18),
                      _AchievementSummary(compact: compact),
                      SizedBox(height: compact ? 18 : 24),
                      for (var index = 0; index < _groups.length; index++) ...[
                        _AchievementSection(
                            group: _groups[index], compact: compact),
                        if (index != _groups.length - 1)
                          SizedBox(height: compact ? 18 : 24),
                      ],
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

class _AchievementSummary extends StatelessWidget {
  const _AchievementSummary({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('achievements-summary'),
      height: compact ? 132 : 158,
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
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF3E8BF2), width: 2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x42063B8E), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3 / 9',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize: compact ? 34 : 42,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  'UNLOCKED',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: compact ? 15 : 17,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Your next badge is close!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: compact ? 10 : 11,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: compact ? 100 : 126,
            height: compact ? 100 : 126,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.square(
                  dimension: compact ? 94 : 116,
                  child: CircularProgressIndicator(
                    value: 1 / 3,
                    strokeWidth: compact ? 10 : 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    valueColor: const AlwaysStoppedAnimation(
                        GameVerseUtilityColors.gold),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Image.asset(
                  'assets/images/games/memory_match/trophy_v1.png',
                  width: compact ? 64 : 78,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementSection extends StatelessWidget {
  const _AchievementSection({required this.group, required this.compact});

  final _AchievementGroup group;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: group.color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(color: group.color.withValues(alpha: 0.4)),
              ),
              child: Icon(group.icon, size: 20, color: group.color),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  group.title,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: GameVerseUtilityColors.ink,
                        fontSize: compact ? 17 : 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .4,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Divider(color: group.color.withValues(alpha: 0.5))),
          ],
        ),
        const SizedBox(height: 10),
        GameVerseSurface(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0;
                  index < group.achievements.length;
                  index++) ...[
                _AchievementRow(
                  achievement: group.achievements[index],
                  color: group.color,
                  compact: compact,
                ),
                if (index != group.achievements.length - 1)
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

class _AchievementRow extends StatelessWidget {
  const _AchievementRow(
      {required this.achievement, required this.color, required this.compact});

  final _Achievement achievement;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.progress >= 1;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16, vertical: compact ? 11 : 14),
      child: Row(
        children: [
          GameVerseIconTile(
            icon: unlocked ? achievement.icon : Icons.lock_rounded,
            color: unlocked ? color : const Color(0xFFAA9C83),
            size: compact ? 46 : 52,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: GameVerseUtilityColors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            GameVerseUtilityColors.ink.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: achievement.progress,
                    backgroundColor: GameVerseUtilityColors.creamDeep,
                    valueColor: AlwaysStoppedAnimation(
                        unlocked ? GameVerseUtilityColors.mint : color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${(achievement.progress * 100).round()}%',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: unlocked ? GameVerseUtilityColors.mint : color,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _AchievementGroup {
  const _AchievementGroup(
      {required this.title,
      required this.color,
      required this.icon,
      required this.achievements});

  final String title;
  final Color color;
  final IconData icon;
  final List<_Achievement> achievements;
}

class _Achievement {
  const _Achievement(this.title, this.description, this.progress, this.icon);

  final String title;
  final String description;
  final double progress;
  final IconData icon;
}
