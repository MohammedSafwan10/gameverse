import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/block.dart';
import 'merge_particles.dart';

class BlockTile extends StatelessWidget {
  final Block? block;
  final double size;

  const BlockTile({
    super.key,
    required this.block,
    required this.size,
  });

  Color _getBackgroundColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72).withValues(
          red: 0xED / 0xFF,
          green: 0xCF / 0xFF,
          blue: 0x72 / 0xFF,
          alpha: 0.95,
        );
      case 256:
        return const Color(0xFFEDCC61).withValues(
          red: 0xED / 0xFF,
          green: 0xCC / 0xFF,
          blue: 0x61 / 0xFF,
          alpha: 0.95,
        );
      case 512:
        return const Color(0xFFEDC850).withValues(
          red: 0xED / 0xFF,
          green: 0xC8 / 0xFF,
          blue: 0x50 / 0xFF,
          alpha: 0.95,
        );
      case 1024:
        return const Color(0xFFEDC53F).withValues(
          red: 0xED / 0xFF,
          green: 0xC5 / 0xFF,
          blue: 0x3F / 0xFF,
          alpha: 0.95,
        );
      case 2048:
        return const Color(0xFFEDC22E).withValues(
          red: 0xED / 0xFF,
          green: 0xC2 / 0xFF,
          blue: 0x2E / 0xFF,
          alpha: 0.95,
        );
      case 4096:
        return const Color(0xFF3C3A32).withValues(
          red: 0x3C / 0xFF,
          green: 0x3A / 0xFF,
          blue: 0x32 / 0xFF,
          alpha: 0.95,
        );
      default:
        return const Color(0xFF3C3A32).withValues(
          red: 0x3C / 0xFF,
          green: 0x3A / 0xFF,
          blue: 0x32 / 0xFF,
          alpha: 0.95,
        );
    }
  }
  Color _getTextColor(int value) {
    if (value <= 4) {
      return const Color(0xFF776E65);
    }
    if (value >= 128) {
      return Colors.white.withValues(
        red: 1.0,
        green: 1.0,
        blue: 1.0,
        alpha: 0.95,
      );
    }
    return Colors.white;
  }

  double _getFontSize(int value) {
    if (value < 100) return size * 0.42;
    if (value < 1000) return size * 0.34;
    if (value < 10000) return size * 0.26;
    return size * 0.20;
  }

  @override
  Widget build(BuildContext context) {
    if (block == null) {
      return Container(
        width: size,
        height: size,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey.shade200.withValues(
            red: Colors.grey.shade200.r.toDouble(),
            green: Colors.grey.shade200.g.toDouble(),
            blue: Colors.grey.shade200.b.toDouble(),
            alpha: 0.7,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300.withValues(
              red: Colors.grey.shade300.r.toDouble(),
              green: Colors.grey.shade300.g.toDouble(),
              blue: Colors.grey.shade300.b.toDouble(),
              alpha: 0.8,
            ),
            width: 2,
          ),
        ),
      );
    }

    final backgroundColor = _getBackgroundColor(block!.value);
    final textColor = _getTextColor(block!.value);
    final fontSize = _getFontSize(block!.value);
    final isSpecialMerge = block!.value >= 1024;
    final isHighValue = block!.value >= 512;

    Widget tileContent = Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: backgroundColor.withValues(
            red: backgroundColor.r.toDouble(),
            green: backgroundColor.g.toDouble(),
            blue: backgroundColor.b.toDouble(),
            alpha: 0.9,
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(
              red: backgroundColor.r.toDouble(),
              green: backgroundColor.g.toDouble(),
              blue: backgroundColor.b.toDouble(),
              alpha: 0.4,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          if (isHighValue)
            BoxShadow(
              color: backgroundColor.withValues(
                red: backgroundColor.r.toDouble(),
                green: backgroundColor.g.toDouble(),
                blue: backgroundColor.b.toDouble(),
                alpha: 0.5,
              ),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              block!.value.toString(),
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                shadows: isHighValue
                    ? [
                        Shadow(
                          color: textColor.withValues(
                            red: textColor.r.toDouble(),
                            green: textColor.g.toDouble(),
                            blue: textColor.b.toDouble(),
                            alpha: 0.4,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );

    // Enhanced merge animation with controlled scaling
    if (block!.isMerged) {
      tileContent = Stack(
        children: [
          tileContent
              .animate(
                onPlay: (controller) => controller.forward(from: 0),
              )
              .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1.08, 1.08),
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
              )
              .then()
              .scale(
                begin: const Offset(1.08, 1.08),
                end: const Offset(1.0, 1.0),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
              ),
          if (block!.isMerged && !block!.isNew)
            MergeParticles(
              value: block!.value,
              color: backgroundColor,
              size: size,
            ),
        ],
      );

      // Special effects for high-value merges
      if (isSpecialMerge) {
        tileContent = tileContent
            .animate()
            .shake(
              duration: const Duration(milliseconds: 300),
              offset: const Offset(0, 1),
              hz: 4,
            )
            .shimmer(
              duration: const Duration(milliseconds: 700),
              color: Colors.white.withValues(
                red: 1.0,
                green: 1.0,
                blue: 1.0,
                alpha: 0.4,
              ),
              size: 2,
            );
      }
    }

    // Subtle new block animation
    if (block!.isNew) {
      tileContent = tileContent
          .animate()
          .scale(
            begin: const Offset(0.1, 0.1),
            end: const Offset(1.03, 1.03),
            curve: Curves.easeOutBack,
            duration: const Duration(milliseconds: 150),
          )
          .then()
          .scale(
            begin: const Offset(1.03, 1.03),
            end: const Offset(1.0, 1.0),
            duration: const Duration(milliseconds: 100),
          )
          .fadeIn(duration: const Duration(milliseconds: 150));
    }

    // Subtle hover effect for mergeable blocks
    if (!block!.isNew && !block!.isMerged) {
      tileContent = tileContent
          .animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          )
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.015, 1.015),
            duration: const Duration(milliseconds: 2000),
            curve: Curves.easeInOut,
          );

      // Subtle glow for high-value tiles
      if (isHighValue) {
        tileContent = tileContent.animate().custom(
              duration: const Duration(milliseconds: 2000),
              builder: (context, value, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: backgroundColor.withValues(
                          red: backgroundColor.r.toDouble(),
                          green: backgroundColor.g.toDouble(),
                          blue: backgroundColor.b.toDouble(),
                          alpha: 0.3 * value,
                        ),
                        blurRadius: 6 * value,
                        spreadRadius: 1 * value,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
            );
      }
    }

    return tileContent;
  }
}
