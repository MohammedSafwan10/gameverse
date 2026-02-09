import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

class CountdownTimer extends StatefulWidget {
  final VoidCallback onComplete;
  final Duration duration;
  final String message;

  const CountdownTimer({
    super.key,
    required this.onComplete,
    this.duration = const Duration(seconds: 3),
    this.message = 'Ready?',
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late int _secondsRemaining;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.duration.inSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.message.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: Colors.white70,
              ),
            ).animate().fadeIn().slideY(begin: -0.5),
            const SizedBox(height: 24),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: Center(
                child: Text(
                  _secondsRemaining.toString(),
                  key: ValueKey(_secondsRemaining),
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                )
                    .animate(key: ValueKey(_secondsRemaining))
                    .scale(
                        begin: const Offset(1.5, 1.5),
                        duration: 400.ms,
                        curve: Curves.easeOutBack)
                    .fadeOut(delay: 600.ms),
              ),
            ).animate().scale(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
