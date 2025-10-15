import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/word_service.dart';
import 'category_selection_screen.dart';
import 'game_screen.dart';
import 'word_input_screen.dart';

class HangmanModeSelectionScreen extends StatelessWidget {
  const HangmanModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hangman'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select Game Mode',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              _buildModeButton(
                context,
                'Single Player',
                Icons.person,
                HangmanGameMode.singlePlayer,
                'Play against the computer with various word categories',
              ),
              const SizedBox(height: 20),
              _buildModeButton(
                context,
                'Two Players',
                Icons.people,
                HangmanGameMode.twoPlayers,
                'Challenge a friend to guess your word',
              ),
              const SizedBox(height: 20),
              _buildModeButton(
                context,
                'Daily Challenge',
                Icons.calendar_today,
                HangmanGameMode.dailyChallenge,
                'New word every day - compete globally!',
                Colors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String title,
    IconData icon,
    HangmanGameMode mode,
    String description, [
    Color? specialColor,
  ]) {
    return Container(
      width: double.infinity,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: specialColor ??
              Colors.white.withValues(
                red: Colors.white.r.toDouble(),
                green: Colors.white.g.toDouble(),
                blue: Colors.white.b.toDouble(),
                alpha: 0.9 * 255,
              ),
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16),
        ),
        onPressed: () => _onModeSelected(context, mode),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _onModeSelected(BuildContext context, HangmanGameMode mode) {
    switch (mode) {
      case HangmanGameMode.singlePlayer:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CategorySelectionScreen(),
          ),
        );
        break;

      case HangmanGameMode.twoPlayers:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const WordInputScreen(),
          ),
        );
        break;

      case HangmanGameMode.dailyChallenge:
        final word = WordService.getDailyWord();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HangmanGameScreen(
              initialState: HangmanGameState(
                word: word,
                mode: HangmanGameMode.dailyChallenge,
                category: WordCategory
                    .custom, // Daily challenge uses mixed categories
                startTime: DateTime.now(),
              ),
            ),
          ),
        );
        break;
    }
  }
}
