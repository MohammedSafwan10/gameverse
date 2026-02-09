import 'package:flutter/material.dart';

class ChessBoardPreview extends StatelessWidget {
  final List<Color> colors;
  final bool isSelected;

  const ChessBoardPreview({
    super.key,
    required this.colors,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final squareSize = size / 4;

        return Column(
          children: List.generate(4, (row) {
            return Row(
              children: List.generate(4, (col) {
                final isWhiteSquare = (row + col) % 2 == 0;
                final color = isWhiteSquare ? colors[1] : colors[0];

                return Container(
                  width: squareSize,
                  height: squareSize,
                  color: color,
                );
              }),
            );
          }),
        );
      },
    );
  }
}
