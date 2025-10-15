import 'package:flutter/material.dart';

class TicTacToeAnimations {
  static const duration = Duration(milliseconds: 300);
  static const curve = Curves.easeInOut;
  
  static const defaultDuration = Duration(milliseconds: 300);
  static const defaultCurve = Curves.easeInOut;
  
  static const fastDuration = Duration(milliseconds: 150);
  static const slowDuration = Duration(milliseconds: 500);
  
  static const bounceOutCurve = Curves.bounceOut;
  static const elasticOutCurve = Curves.elasticOut;

  static Widget fadeIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget slideIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Offset offset = const Offset(0.0, 0.2),
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: offset, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value * 100,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget scale({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget staggeredList({
    required List<Widget> children,
    Duration itemDuration = defaultDuration,
    Duration? staggerDuration,
    Curve curve = defaultCurve,
    bool fadeIn = true,
    bool slideIn = true,
    bool scale = true,
  }) {
    return ListView.builder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        Widget child = children[index];

        if (scale) {
          child = TicTacToeAnimations.scale(
            child: child,
            duration: itemDuration,
            curve: curve,
          );
        }

        if (slideIn) {
          child = TicTacToeAnimations.slideIn(
            child: child,
            duration: itemDuration,
            curve: curve,
          );
        }

        if (fadeIn) {
          child = TicTacToeAnimations.fadeIn(
            child: child,
            duration: itemDuration,
            curve: curve,
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: child,
        );
      },
    );
  }

  static Widget crossFade({
    required Widget firstChild,
    required Widget secondChild,
    required bool showFirst,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return AnimatedCrossFade(
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState:
          showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: duration,
      firstCurve: curve,
      secondCurve: curve,
      sizeCurve: curve,
    );
  }

  static Widget fadeSlide({
    required Widget child,
    required bool show,
    Duration? duration,
    Curve? curve,
    Offset? offset,
  }) {
    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      duration: duration ?? TicTacToeAnimations.duration,
      curve: curve ?? TicTacToeAnimations.curve,
      child: AnimatedSlide(
        offset: show ? Offset.zero : (offset ?? const Offset(0, 0.1)),
        duration: duration ?? TicTacToeAnimations.duration,
        child: child,
      ),
    );
  }
}
