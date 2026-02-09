import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withValues(
                  alpha: 0.8,
                ),
            Theme.of(context).primaryColor.withValues(
                  alpha: 0.2,
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
                'Leaderboard',
                style: Get.textTheme.headlineLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return _buildLeaderboardItem(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Get.theme.primaryColor,
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text('Player ${index + 1}'),
        subtitle: Text('Score: ${1000 - (index * 50)}'),
        trailing: Icon(
          index == 0 ? Icons.emoji_events : Icons.stars,
          color: index == 0 ? Colors.amber : Colors.grey,
        ),
      ),
    );
  }
}
