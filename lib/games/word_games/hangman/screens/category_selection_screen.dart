import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_state.dart';
import '../services/word_service.dart';
import '../../../../widgets/premium_background.dart';
import 'game_screen.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'CATEGORIES',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: Colors.cyanAccent,
                blurRadius: 10,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const PremiumBackground(),
          SafeArea(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(24),
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              children: WordCategory.values
                  .where((category) => category != WordCategory.custom)
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) => _buildCategoryCard(
                        context,
                        entry.value,
                        entry.key,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, WordCategory category, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: category.color.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: category.color.withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.black.withValues(alpha: 0.3),
            child: InkWell(
              onTap: () => _onCategorySelected(context, category),
              splashColor: category.color.withValues(alpha: 0.3),
              highlightColor: category.color.withValues(alpha: 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: category.color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      category.icon,
                      size: 40,
                      color: category.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    category.displayName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(delay: (100 * index).ms, duration: 500.ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }

  void _onCategorySelected(BuildContext context, WordCategory category) {
    final word = WordService.getRandomWord(category);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HangmanGameScreen(
          initialState: HangmanGameState(
            word: word,
            mode: HangmanGameMode.singlePlayer,
            category: category,
            startTime: DateTime.now(),
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
