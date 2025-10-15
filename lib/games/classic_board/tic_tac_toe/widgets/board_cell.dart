import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/game_theme.dart';

class BoardCell extends StatefulWidget {
  final Player player;
  final VoidCallback onTap;
  final bool isWinningCell;
  final bool isEnabled;
  final bool isHighlighted;

  const BoardCell({
    super.key,
    required this.player,
    required this.onTap,
    this.isWinningCell = false,
    this.isEnabled = true,
    this.isHighlighted = false,
  });

  @override
  State<BoardCell> createState() => _BoardCellState();
}

class _BoardCellState extends State<BoardCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotateAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(
      begin: widget.player == Player.x ? -0.25 : 0.0,
      end: widget.player == Player.x ? 0.0 : 0.25,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    if (widget.player != Player.none) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(BoardCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.player != Player.none && oldWidget.player == Player.none) {
      _controller.forward(from: 0.0);
    } else if (widget.player == Player.none &&
        oldWidget.player != Player.none) {
      _controller.reverse();
    }

    // Update winning cell animation
    if (widget.isWinningCell && !oldWidget.isWinningCell) {
      _pulseAnimation();
    }
  }

  void _pulseAnimation() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _controller.forward(from: 0.8);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled ? widget.onTap : null,
      onTapDown: (_) {
        if (widget.isEnabled) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.isEnabled) {
          setState(() => _isPressed = false);
        }
      },
      onTapCancel: () {
        if (widget.isEnabled) {
          setState(() => _isPressed = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _getCellBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getCellBorderColor(),
            width: widget.isWinningCell ? 2.0 : 1.0,
          ),
          boxShadow: _getCellShadow(),
        ),
        transform: _isPressed ? Matrix4.diagonal3Values(0.95, 0.95, 1.0) : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value * 3.14159,
                child: _buildPlayerSymbol(),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getCellBackgroundColor() {
    if (widget.isWinningCell) {
      return TicTacToeTheme.primaryColor.withValues(
        red: TicTacToeTheme.primaryColor.r.toDouble(),
        green: TicTacToeTheme.primaryColor.g.toDouble(),
        blue: TicTacToeTheme.primaryColor.b.toDouble(),
        alpha: 0.1,
      );
    }

    if (widget.isHighlighted) {
      return Colors.grey.withValues(
        red: Colors.grey.r.toDouble(),
        green: Colors.grey.g.toDouble(),
        blue: Colors.grey.b.toDouble(),
        alpha: 0.1,
      );
    }

    return widget.isEnabled && widget.player == Player.none
        ? Colors.white
        : Theme.of(context).colorScheme.surface;
  }

  Color _getCellBorderColor() {
    if (widget.isWinningCell) {
      return TicTacToeTheme.primaryColor;
    }

    return widget.isHighlighted
        ? TicTacToeTheme.primaryColor.withValues(
            red: TicTacToeTheme.primaryColor.r.toDouble(),
            green: TicTacToeTheme.primaryColor.g.toDouble(),
            blue: TicTacToeTheme.primaryColor.b.toDouble(),
            alpha: 0.5,
          )
        : TicTacToeTheme.gridColor.withValues(
            red: TicTacToeTheme.gridColor.r.toDouble(),
            green: TicTacToeTheme.gridColor.g.toDouble(),
            blue: TicTacToeTheme.gridColor.b.toDouble(),
            alpha: 0.2,
          );
  }

  List<BoxShadow> _getCellShadow() {
    final shadows = <BoxShadow>[];

    if (widget.isWinningCell) {
      shadows.add(BoxShadow(
        color: TicTacToeTheme.primaryColor.withValues(
          red: TicTacToeTheme.primaryColor.r.toDouble(),
          green: TicTacToeTheme.primaryColor.g.toDouble(),
          blue: TicTacToeTheme.primaryColor.b.toDouble(),
          alpha: 0.3,
        ),
        blurRadius: 8,
        spreadRadius: 2,
      ));
    } else if (widget.isHighlighted) {
      shadows.add(BoxShadow(
        color: Theme.of(context).colorScheme.secondary.withValues(
              red: Theme.of(context).colorScheme.secondary.r.toDouble(),
              green: Theme.of(context).colorScheme.secondary.g.toDouble(),
              blue: Theme.of(context).colorScheme.secondary.b.toDouble(),
              alpha: 0.2,
            ),
        blurRadius: 4,
        spreadRadius: 1,
      ));
    }

    return shadows;
  }

  Widget _buildPlayerSymbol() {
    switch (widget.player) {
      case Player.x:
        return _buildXSymbol();
      case Player.o:
        return _buildOSymbol();
      case Player.none:
        return _buildEmptyCell();
    }
  }

  Widget _buildXSymbol() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          TicTacToeTheme.xColor,
          TicTacToeTheme.xColor.withValues(
            red: TicTacToeTheme.xColor.r.toDouble(),
            green: TicTacToeTheme.xColor.g.toDouble(),
            blue: TicTacToeTheme.xColor.b.toDouble(),
            alpha: 0.7,
          ),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Icon(
        Icons.close_rounded,
        size: 50,
        color: Colors.white,
        shadows: widget.isWinningCell
            ? [
                Shadow(
                  color: TicTacToeTheme.xColor.withValues(
                    red: TicTacToeTheme.xColor.r.toDouble(),
                    green: TicTacToeTheme.xColor.g.toDouble(),
                    blue: TicTacToeTheme.xColor.b.toDouble(),
                    alpha: 0.5,
                  ),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildOSymbol() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          TicTacToeTheme.oColor,
          TicTacToeTheme.oColor.withValues(
            red: TicTacToeTheme.oColor.r.toDouble(),
            green: TicTacToeTheme.oColor.g.toDouble(),
            blue: TicTacToeTheme.oColor.b.toDouble(),
            alpha: 0.7,
          ),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Icon(
        Icons.circle_outlined,
        size: 50,
        color: Colors.white,
        shadows: widget.isWinningCell
            ? [
                Shadow(
                  color: TicTacToeTheme.oColor.withValues(
                    red: TicTacToeTheme.oColor.r.toDouble(),
                    green: TicTacToeTheme.oColor.g.toDouble(),
                    blue: TicTacToeTheme.oColor.b.toDouble(),
                    alpha: 0.5,
                  ),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildEmptyCell() {
    if (!widget.isEnabled) return const SizedBox();

    return Center(
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: _isPressed
              ? TicTacToeTheme.primaryColor.withValues(
                  red: TicTacToeTheme.primaryColor.r.toDouble(),
                  green: TicTacToeTheme.primaryColor.g.toDouble(),
                  blue: TicTacToeTheme.primaryColor.b.toDouble(),
                  alpha: 0.2,
                )
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
