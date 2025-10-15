import 'package:flutter/material.dart';
import '../theme/game_theme.dart';

class ComboText extends StatefulWidget {
  final int combo;
  final VoidCallback onComplete;

  const ComboText({
    super.key,
    required this.combo,
    required this.onComplete,
  });

  @override
  State<ComboText> createState() => _ComboTextState();
}

class _ComboTextState extends State<ComboText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60.0,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20.0,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getComboText() {
    if (widget.combo < 3) return '';
    if (widget.combo < 5) return 'Nice!';
    if (widget.combo < 8) return 'Great!';
    if (widget.combo < 12) return 'Amazing!';
    if (widget.combo < 16) return 'Incredible!';
    return 'Unstoppable!';
  }

  Color _getComboColor() {
    if (widget.combo < 3) return WhackAMoleTheme.primaryColor;
    if (widget.combo < 5) return Colors.green;
    if (widget.combo < 8) return Colors.blue;
    if (widget.combo < 12) return Colors.purple;
    if (widget.combo < 16) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getComboText(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getComboColor(),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(
                          red: Colors.black.r.toDouble(),
                          green: Colors.black.g.toDouble(),
                          blue: Colors.black.b.toDouble(),
                          alpha: 0.3,
                        ),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (widget.combo >= 3) ...[
                  const SizedBox(height: 5),
                  Text(
                    '${widget.combo}x COMBO!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getComboColor(),
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(
                            red: Colors.black.r.toDouble(),
                            green: Colors.black.g.toDouble(),
                            blue: Colors.black.b.toDouble(),
                            alpha: 0.3,
                          ),
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
