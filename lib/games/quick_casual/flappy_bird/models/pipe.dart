import 'package:flutter/material.dart';

class Pipe {
  Offset position;
  final Size size;
  final bool isTop;
  bool passed = false;

  Pipe({
    required this.position,
    required this.size,
    required this.isTop,
  });

  double get width => size.width;
  double get height => size.height;

  Rect get rect => Rect.fromLTWH(
        position.dx,
        isTop ? 0 : position.dy,
        size.width,
        size.height,
      );
} 