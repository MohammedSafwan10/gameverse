import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withValues(
                  red: Theme.of(context).primaryColor.r.toDouble(),
                  green: Theme.of(context).primaryColor.g.toDouble(),
                  blue: Theme.of(context).primaryColor.b.toDouble(),
                  alpha: 0.8 * 255,
                ),
            Theme.of(context).primaryColor.withValues(
                  red: Theme.of(context).primaryColor.r.toDouble(),
                  green: Theme.of(context).primaryColor.g.toDouble(),
                  blue: Theme.of(context).primaryColor.b.toDouble(),
                  alpha: 0.2 * 255,
                ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Achievements',
                style: Get.textTheme.headlineLarge,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildAchievementCategory('Beginner Achievements'),
                  _buildAchievementList(true),
                  _buildAchievementCategory('Intermediate Achievements'),
                  _buildAchievementList(false),
                  _buildAchievementCategory('Expert Achievements'),
                  _buildAchievementList(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCategory(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Get.textTheme.titleLarge?.copyWith(
          color: Get.theme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildAchievementList(bool isUnlocked) {
    return Card(
      child: Column(
        children: List.generate(
          3,
          (index) => _buildAchievementItem(
            title: 'Achievement ${index + 1}',
            description: 'Complete this task to earn the achievement',
            isUnlocked: isUnlocked,
            progress: isUnlocked ? 1.0 : (index * 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementItem({
    required String title,
    required String description,
    required bool isUnlocked,
    required double progress,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isUnlocked ? Colors.amber : Colors.grey.shade300,
        child: Icon(
          isUnlocked ? Icons.emoji_events : Icons.lock,
          color: isUnlocked ? Colors.white : Colors.grey,
        ),
      ),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              isUnlocked ? Colors.amber : Get.theme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}% Complete',
            style: Get.textTheme.bodySmall,
          ),
        ],
      ),
      isThreeLine: true,
    );
  }
}
