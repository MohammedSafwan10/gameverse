import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/word_service.dart';
import 'game_screen.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Select Category',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: WordCategory.values
            .where((category) => category != WordCategory.custom)
            .map((category) => _buildCategoryCard(context, category))
            .toList(),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, WordCategory category) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: category.color.withValues(
            red: category.color.r.toDouble(),
            green: category.color.g.toDouble(),
            blue: category.color.b.toDouble(),
            alpha: 0.3 * 255,
          ),
        ),
      ),
      child: InkWell(
        onTap: () => _onCategorySelected(context, category),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: category.color.withValues(
              red: category.color.r.toDouble(),
              green: category.color.g.toDouble(),
              blue: category.color.b.toDouble(),
              alpha: 0.1 * 255,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                size: 48,
                color: category.color,
              ),
              const SizedBox(height: 8),
              Text(
                category.displayName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCategorySelected(BuildContext context, WordCategory category) {
    final word = WordService.getRandomWord(category);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HangmanGameScreen(
          initialState: HangmanGameState(
            word: word,
            mode: HangmanGameMode.singlePlayer,
            category: category,
            startTime: DateTime.now(),
          ),
        ),
      ),
    );
  }
}
