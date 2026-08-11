import 'dart:math';

import 'package:flutter/material.dart';

import '../models/card_model.dart';
import '../models/game_mode.dart';
import '../theme/memory_match_theme.dart';

const _assetRoot = 'assets/images/games/memory_match';
const _cardAssets = <String, String>{
  'rocket': '$_assetRoot/rocket_card_v1.png',
  'flower': '$_assetRoot/flower_card_v1.png',
  'planet': '$_assetRoot/planet_card_v1.png',
  'moon': '$_assetRoot/moon_card_v1.png',
  'lightning': '$_assetRoot/lightning_card_v1.png',
  'heart': '$_assetRoot/heart_card_v1.png',
  'controller': '$_assetRoot/controller_card_v1.png',
  'crown': '$_assetRoot/crown_card_v1.png',
  'rainbow': '$_assetRoot/rainbow_card_v1.png',
  'icecream': '$_assetRoot/icecream_card_v1.png',
};

class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.card,
    required this.mode,
    this.onFlipComplete,
  });

  final MemoryCard card;
  final MemoryMatchMode mode;
  final ValueChanged<bool>? onFlipComplete;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final AnimationController _matchController;
  late final Animation<double> _flipAnimation;
  late final Animation<double> _matchScale;
  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _flipAnimation = CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOutBack,
    );
    _matchController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _matchScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.12, end: 1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_matchController);
    _showFront = widget.card.isFlipped || widget.card.isMatched;
    if (_showFront) _flipController.value = 1;
  }

  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldShow = widget.card.isFlipped || widget.card.isMatched;
    if (shouldShow != _showFront) {
      _showFront = shouldShow;
      final animation =
          shouldShow ? _flipController.forward() : _flipController.reverse();
      animation.then((_) => widget.onFlipComplete?.call(shouldShow));
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
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_flipAnimation, _matchScale]),
        builder: (context, _) {
          final angle = _flipAnimation.value * pi;
          return Transform.scale(
            scale: widget.card.isMatched ? _matchScale.value : 1,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, .0015)
                ..rotateY(angle),
              child: angle < pi / 2 ? _back() : _front(),
            ),
          );
        },
      );

  Widget _front() {
    final asset = _cardAssets[widget.card.emoji];
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(pi),
      child: _shadowed(
        asset == null
            ? Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.card.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(widget.card.emoji),
              )
            : Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }

  Widget _back() => _shadowed(
        Image.asset(
          '$_assetRoot/blue_card_back_v1.png',
          fit: BoxFit.contain,
        ),
      );

  Widget _shadowed(Widget child) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: MemoryMatchTheme.ink.withValues(alpha: .27),
              blurRadius: widget.card.isMatched ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );
}
