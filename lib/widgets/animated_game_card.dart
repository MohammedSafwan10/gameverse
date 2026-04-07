import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedGameCard extends StatelessWidget {
  final String title;
  final Color color;
  final int gamesCount;
  final bool isNew;
  final bool isComingSoon;
  final String? backgroundImage;
  final VoidCallback? onTap;
  final int index;

  const AnimatedGameCard({
    super.key,
    required this.title,
    required this.color,
    required this.gamesCount,
    this.isNew = false,
    this.isComingSoon = false,
    this.backgroundImage,
    this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      delay: Duration(milliseconds: 100 * index),
      effects: [
        FadeEffect(duration: 600.ms),
        SlideEffect(
          begin: const Offset(0, 0.2),
          duration: 600.ms,
          curve: Curves.easeOutQuint,
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isComingSoon ? null : onTap,
              splashColor: color.withValues(alpha: 0.2),
              highlightColor: color.withValues(alpha: 0.1),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image with Gradient Overlay
                  if (backgroundImage != null) ...[
                    Image.asset(
                      backgroundImage!,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.06),
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ] else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withValues(alpha: 0.3),
                            color.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                    ),

                  // Glassmorphic Border and Content
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              isComingSoon ? 'COMMING SOON' : '$gamesCount GAMES',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (isNew) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Lock overlay for coming soon
                  if (isComingSoon)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
