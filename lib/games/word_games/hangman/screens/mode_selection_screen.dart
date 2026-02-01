import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      backgroundColor: const Color(0xFFF8F9FE),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
           // Decorative Background
            Positioned(
              right: -100,
              top: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: 50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hangman',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2),
                  const SizedBox(height: 8),
                  const Text(
                    'Guess the word before it\'s too late!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                  const SizedBox(height: 48),

                  _buildModeButton(
                    context,
                    'Single Player',
                    Icons.person_rounded,
                    HangmanGameMode.singlePlayer,
                    'Play against the computer with various word categories',
                    Colors.indigo,
                    0,
                  ),
                  const SizedBox(height: 16),
                  _buildModeButton(
                    context,
                    'Two Players',
                    Icons.people_rounded,
                    HangmanGameMode.twoPlayers,
                    'Challenge a friend to guess your word',
                    Colors.purple,
                    1,
                  ),
                  const SizedBox(height: 16),
                  _buildModeButton(
                    context,
                    'Daily Challenge',
                    Icons.calendar_today_rounded,
                    HangmanGameMode.dailyChallenge,
                    'New word every day - compete globally!',
                    const Color(0xFFFFA502),
                    2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String title,
    IconData icon,
    HangmanGameMode mode,
    String description,
    Color color,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _onModeSelected(context, mode),
          borderRadius: BorderRadius.circular(24),
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (400 + (index * 100)).ms).fadeIn().slideX(begin: 0.2);
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
