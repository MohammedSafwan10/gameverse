import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChessSquareWidget extends StatelessWidget {
  final Color color;
  final Widget? child;
  final bool isHighlighted;
  final bool isLastMove;
  final bool isLegalMove;
  final bool isCheck;
  final VoidCallback? onTap;

  const ChessSquareWidget({
    super.key,
    required this.color,
    this.child,
    this.isHighlighted = false,
    this.isLastMove = false,
    this.isLegalMove = false,
    this.isCheck = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base square with subtle gradient
          Container(
            decoration: BoxDecoration(
              color: color,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(
                    red: color.r.toDouble(),
                    green: color.g.toDouble(),
                    blue: color.b.toDouble(),
                    alpha: 1.0,
                  ),
                  color.withValues(
                    red: color.r.toDouble(),
                    green: color.g.toDouble(),
                    blue: color.b.toDouble(),
                    alpha: 0.9,
                  ),
                ],
              ),
            ),
          ),

          // Last move indicator
          if (isLastMove)
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(
                    red: theme.colorScheme.primary.r.toDouble(),
                    green: theme.colorScheme.primary.g.toDouble(),
                    blue: theme.colorScheme.primary.b.toDouble(),
                    alpha: 0.7,
                  ),
                  width: 2.5,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),

          // Highlight overlay with shimmer effect
          if (isHighlighted)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    theme.colorScheme.primary.withValues(
                      red: theme.colorScheme.primary.r.toDouble(),
                      green: theme.colorScheme.primary.g.toDouble(),
                      blue: theme.colorScheme.primary.b.toDouble(),
                      alpha: 0.3,
                    ),
                    theme.colorScheme.primary.withValues(
                      red: theme.colorScheme.primary.r.toDouble(),
                      green: theme.colorScheme.primary.g.toDouble(),
                      blue: theme.colorScheme.primary.b.toDouble(),
                      alpha: 0.1,
                    ),
                  ],
                ),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .shimmer(
                  duration: 1500.ms,
                  color: Colors.white24,
                ),

          // Legal move indicator with pulsing effect
          if (isLegalMove)
            Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(
                    red: theme.colorScheme.primary.r.toDouble(),
                    green: theme.colorScheme.primary.g.toDouble(),
                    blue: theme.colorScheme.primary.b.toDouble(),
                    alpha: 0.3,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(
                        red: theme.colorScheme.primary.r.toDouble(),
                        green: theme.colorScheme.primary.g.toDouble(),
                        blue: theme.colorScheme.primary.b.toDouble(),
                        alpha: 0.2,
                      ),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 1000.ms,
                  curve: Curves.easeInOut,
                ),

          // Check indicator with glowing effect
          if (isCheck)
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.error.withValues(
                    red: theme.colorScheme.error.r.toDouble(),
                    green: theme.colorScheme.error.g.toDouble(),
                    blue: theme.colorScheme.error.b.toDouble(),
                    alpha: 0.3,
                  ),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.error.withValues(
                      red: theme.colorScheme.error.r.toDouble(),
                      green: theme.colorScheme.error.g.toDouble(),
                      blue: theme.colorScheme.error.b.toDouble(),
                      alpha: 0.3,
                    ),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .custom(
                  duration: 800.ms,
                  builder: (context, value, child) => Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(
                          red: theme.colorScheme.error.r.toDouble(),
                          green: theme.colorScheme.error.g.toDouble(),
                          blue: theme.colorScheme.error.b.toDouble(),
                          alpha: 0.5 + value * 0.5,
                        ),
                        width: 2.5,
                      ),
                    ),
                    child: child,
                  ),
                ),

          // Piece with smooth animation
          if (child != null)
            Padding(
              padding: const EdgeInsets.all(4),
              child: child!,
            )
                .animate(
                  target: isHighlighted ? 1 : 0,
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 200.ms,
                  curve: Curves.easeInOut,
                ),
        ],
      ),
    );
  }
}
