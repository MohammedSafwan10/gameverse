import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_state.dart';
import '../services/storage_service.dart';
import '../services/word_service.dart';
import '../../../../widgets/premium_background.dart';
import 'category_selection_screen.dart';
import 'game_screen.dart';
import 'word_input_screen.dart';

class HangmanModeSelectionScreen extends StatelessWidget {
  const HangmanModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'HANGMAN',
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
          // Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SELECT MODE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                    const SizedBox(height: 50),
                    _buildModeCard(
                      context: context,
                      title: 'SINGLE PLAYER',
                      icon: Icons.person_outline,
                      mode: HangmanGameMode.singlePlayer,
                      glowColor: Colors.cyanAccent,
                      delay: 100,
                    ),
                    const SizedBox(height: 24),
                    _buildModeCard(
                      context: context,
                      title: 'TWO PLAYERS',
                      icon: Icons.people_outline,
                      mode: HangmanGameMode.twoPlayers,
                      glowColor: Colors.pinkAccent,
                      delay: 300,
                    ),
                    const SizedBox(height: 24),
                    _buildModeCard(
                      context: context,
                      title: 'DAILY CHALLENGE',
                      icon: Icons.calendar_today_outlined,
                      mode: HangmanGameMode.dailyChallenge,
                      glowColor: Colors.amberAccent,
                      delay: 500,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required HangmanGameMode mode,
    required Color glowColor,
    required int delay,
  }) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: glowColor.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.15),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.black.withValues(alpha: 0.3),
            child: InkWell(
              onTap: () => _onModeSelected(context, mode),
              splashColor: glowColor.withValues(alpha: 0.3),
              highlightColor: glowColor.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: glowColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: glowColor.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Icon(
                        icon,
                        size: 32,
                        color: glowColor,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: glowColor.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(delay: delay.ms, duration: 600.ms)
        .slideX(begin: 0.2, curve: Curves.easeOutQuad);
  }

  Future<void> _onModeSelected(
      BuildContext context, HangmanGameMode mode) async {
    switch (mode) {
      case HangmanGameMode.singlePlayer:
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CategorySelectionScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutBack;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
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
        final storageService = HangmanStorageService();
        await storageService.init();
        if (!storageService.canPlayDailyChallenge()) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
              content: const Text(
                'You already played today\'s daily challenge. Come back tomorrow.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          return;
        }

        final category = WordService.getDailyCategory();
        final word = WordService.getDailyWord();
        if (!context.mounted) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HangmanGameScreen(
              initialState: HangmanGameState(
                word: word,
                mode: HangmanGameMode.dailyChallenge,
                category: category,
                startTime: DateTime.now(),
              ),
            ),
          ),
        );
        break;
    }
  }
}
