import 'dart:math';
import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../models/game_mode.dart';

class FlipCard extends StatefulWidget {
  final MemoryCard card;
  final MemoryMatchMode mode;
  final Function(bool)? onFlipComplete;

  const FlipCard({
    super.key,
    required this.card,
    required this.mode,
    this.onFlipComplete,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _matchController;
  late Animation<double> _flipAnimation;
  late Animation<double> _matchScale;

  bool _showFront = false;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );

    _matchController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _matchScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_matchController);

    _showFront = widget.card.isFlipped || widget.card.isMatched;
    if (_showFront) _flipController.value = 1.0;
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldShowFront = widget.card.isFlipped || widget.card.isMatched;
    if (shouldShowFront != _showFront) {
      _showFront = shouldShowFront;
      if (_showFront) {
        _flipController.forward().then((_) {
          widget.onFlipComplete?.call(true);
        });
      } else {
        _flipController.reverse().then((_) {
          widget.onFlipComplete?.call(false);
        });
      }
    }

    if (widget.card.isMatched && !oldWidget.card.isMatched) {
      _matchController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _matchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_flipAnimation, _matchScale]),
      builder: (context, _) {
        final angle = _flipAnimation.value * pi;
        final isFrontVisible = angle < pi / 2;
        final scale = widget.card.isMatched ? _matchScale.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(angle),
            child: isFrontVisible ? _buildBackSide() : _buildFrontSide(),
          ),
        );
      },
    );
  }

  Widget _buildFrontSide() {
    final cardColor = widget.card.backgroundColor;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.card.isMatched
                ? Colors.greenAccent.withValues(alpha: 0.8)
                : cardColor.withValues(alpha: 0.6),
            width: widget.card.isMatched ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.card.isMatched ? Colors.greenAccent : cardColor)
                  .withValues(alpha: widget.card.isMatched ? 0.4 : 0.25),
              blurRadius: widget.card.isMatched ? 12 : 6,
              spreadRadius: widget.card.isMatched ? 1 : 0,
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: RadialGradient(
              colors: [
                cardColor.withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Text(
              widget.card.emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackSide() {
    final modeColor = widget.mode.color;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D2D44),
            const Color(0xFF1A1A2E),
          ],
        ),
        border: Border.all(
          color: modeColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              modeColor.withValues(alpha: 0.08),
              modeColor.withValues(alpha: 0.15),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.question_mark_rounded,
            size: 26,
            color: modeColor.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
