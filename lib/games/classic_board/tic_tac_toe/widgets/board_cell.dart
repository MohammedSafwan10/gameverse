import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/game_theme.dart';
import 'symbol_painters.dart';

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
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _getCellBorderColor(),
            width: widget.isWinningCell ? 2.2 : 1.2,
          ),
          boxShadow: _getCellShadow(),
        ),
        transform: _isPressed ? Matrix4.diagonal3Values(0.95, 0.95, 1.0) : null,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildPlayerSymbol(),
            );
          },
        ),
      ),
    );
  }

    Color _getCellBackgroundColor() {
    if (widget.isWinningCell) {
      return TicTacToeTheme.primaryColor.withValues(alpha: 0.2);
    }
    if (widget.isHighlighted) {
      return Colors.white.withValues(alpha: 0.15);
    }
    return Colors.white.withValues(alpha: widget.player == Player.none ? 0.05 : 0.1);
  }

  Color _getCellBorderColor() {
    if (widget.isWinningCell) {
      return TicTacToeTheme.primaryColor;
    }
    return widget.isHighlighted
        ? TicTacToeTheme.primaryColor.withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.1);
  }

  List<BoxShadow> _getCellShadow() {
    final shadows = <BoxShadow>[];
    if (widget.isWinningCell) {
      shadows.add(BoxShadow(
        color: (widget.player == Player.x ? TicTacToeTheme.xColor : TicTacToeTheme.oColor)
            .withValues(alpha: 0.4),
        blurRadius: 24,
        spreadRadius: 2,
        offset: const Offset(0, 4),
      ));
    } else if (widget.isHighlighted) {
      shadows.add(BoxShadow(
        color: Colors.black.withValues(alpha: 0.24),
        blurRadius: 18,
        spreadRadius: -2,
        offset: const Offset(0, 8),
      ));
    } else {
      shadows.add(
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 12,
          spreadRadius: -4,
          offset: const Offset(0, 6),
        ),
      );
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
    return CustomPaint(
      size: const Size(48, 48),
      painter: XSymbolPainter(
        color: TicTacToeTheme.xColor,
        isWinning: widget.isWinningCell,
      ),
    );
  }

  Widget _buildOSymbol() {
    return CustomPaint(
      size: const Size(48, 48),
      painter: OSymbolPainter(
        color: TicTacToeTheme.oColor,
        isWinning: widget.isWinningCell,
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
              ? TicTacToeTheme.primaryColor.withValues(alpha: 0.2)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// Painters moved to symbol_painters.dart
