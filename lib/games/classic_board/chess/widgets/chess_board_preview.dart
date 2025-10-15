import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Column(
              children: List.generate(4, (row) {
                return Row(
                  children: List.generate(4, (col) {
                    final isWhiteSquare = (row + col) % 2 == 0;
                    final color = isWhiteSquare ? colors[1] : colors[0];

                    return SizedBox(
                      width: squareSize,
                      height: squareSize,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: color.withValues(
                            red: color.r.toDouble(),
                            green: color.g.toDouble(),
                            blue: color.b.toDouble(),
                            alpha: isWhiteSquare ? 1.0 : 0.8,
                          ),
                          border: Border.all(
                            color: isSelected &&
                                    (row == 0 ||
                                        row == 3 ||
                                        col == 0 ||
                                        col == 3)
                                ? Get.theme.colorScheme.primary.withValues(
                                    red: Get.theme.colorScheme.primary.r
                                        .toDouble(),
                                    green: Get.theme.colorScheme.primary.g
                                        .toDouble(),
                                    blue: Get.theme.colorScheme.primary.b
                                        .toDouble(),
                                    alpha: 0.3,
                                  )
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
