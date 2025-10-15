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

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _matchAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _matchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_matchAnimationController);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
    ]).animate(_matchAnimationController);
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isFlipped != oldWidget.card.isFlipped) {
      _isAnimating = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isAnimating = false;
          });
          widget.onFlipComplete?.call(widget.card.isFlipped);
        }
      });
    }

    // Trigger match animation when card is matched
    if (widget.card.isMatched && !oldWidget.card.isMatched) {
      _showMatchAnimation();
    }
  }

  @override
  void dispose() {
    _matchAnimationController.dispose();
    super.dispose();
  }

  void _showMatchAnimation() {
    if (!_matchAnimationController.isAnimating) {
      _matchAnimationController.forward().then((_) {
        if (mounted) {
          _matchAnimationController.value = 0.0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.card.isMatched && !_matchAnimationController.isAnimating) {
      _showMatchAnimation();
    }

    return IgnorePointer(
      ignoring: _isAnimating,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(4),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final rotateAnim = Tween(begin: 0.0, end: pi)
                  .chain(CurveTween(curve: Curves.easeInOutCubic))
                  .animate(animation);

              return AnimatedBuilder(
                animation: rotateAnim,
                child: child,
                builder: (context, child) {
                  var tilt = rotateAnim.value;
                  final isBack = child?.key == const ValueKey('back');

                  if (isBack) {
                    tilt = pi - tilt;
                  }

                  if (tilt > pi / 2) {
                    child = Transform(
                      transform: Matrix4.rotationY(pi),
                      alignment: Alignment.center,
                      child: child,
                    );
                  }

                  Widget result = Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateY(tilt),
                    alignment: Alignment.center,
                    child: child,
                  );

                  if (widget.card.isMatched) {
                    result = AnimatedBuilder(
                      animation: _matchAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              child!,
                              FadeTransition(
                                opacity: _opacityAnimation,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: widget.mode.color.withValues(
                                        red: widget.mode.color.r.toDouble(),
                                        green: widget.mode.color.g.toDouble(),
                                        blue: widget.mode.color.b.toDouble(),
                                        alpha: 0.5,
                                      ),
                                      width: 3,
                                    ),
                                    gradient: RadialGradient(
                                      colors: [
                                        widget.mode.color.withValues(
                                          red: widget.mode.color.r.toDouble(),
                                          green: widget.mode.color.g.toDouble(),
                                          blue: widget.mode.color.b.toDouble(),
                                          alpha: 0.2,
                                        ),
                                        widget.mode.color.withValues(
                                          red: widget.mode.color.r.toDouble(),
                                          green: widget.mode.color.g.toDouble(),
                                          blue: widget.mode.color.b.toDouble(),
                                          alpha: 0.0,
                                        ),
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline,
                                    color: widget.mode.color.withValues(
                                      red: widget.mode.color.r.toDouble(),
                                      green: widget.mode.color.g.toDouble(),
                                      blue: widget.mode.color.b.toDouble(),
                                      alpha: 0.8,
                                    ),
                                    size: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: result,
                    );
                  }

                  return result;
                },
              );
            },
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: widget.card.isFlipped || widget.card.isMatched
                ? _buildFrontSide()
                : _buildBackSide(),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontSide() {
    return Container(
      key: const ValueKey('front'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              red: 0.0,
              green: 0.0,
              blue: 0.0,
              alpha: 0.1,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: widget.card.backgroundColor.withValues(
            red: widget.card.backgroundColor.r.toDouble(),
            green: widget.card.backgroundColor.g.toDouble(),
            blue: widget.card.backgroundColor.b.toDouble(),
            alpha: 0.15,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.card.backgroundColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            widget.card.emoji,
            style: TextStyle(
              fontSize: 28,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(
                    red: 0.0,
                    green: 0.0,
                    blue: 0.0,
                    alpha: 0.2,
                  ),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackSide() {
    return Container(
      key: const ValueKey('back'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              red: 0.0,
              green: 0.0,
              blue: 0.0,
              alpha: 0.1,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.mode.color.withValues(
                red: widget.mode.color.r.toDouble(),
                green: widget.mode.color.g.toDouble(),
                blue: widget.mode.color.b.toDouble(),
                alpha: 0.15,
              ),
              widget.mode.color.withValues(
                red: widget.mode.color.r.toDouble(),
                green: widget.mode.color.g.toDouble(),
                blue: widget.mode.color.b.toDouble(),
                alpha: 0.25,
              ),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.mode.color,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.question_mark_rounded,
            size: 28,
            color: widget.mode.color.withValues(
              red: widget.mode.color.r.toDouble(),
              green: widget.mode.color.g.toDouble(),
              blue: widget.mode.color.b.toDouble(),
              alpha: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
