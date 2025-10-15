import 'package:flutter/material.dart';

class CategoryCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int gamesCount;
  final VoidCallback? onTap;
  final bool hasNewGame;
  final bool isComingSoon;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.gamesCount,
    required this.onTap,
    this.hasNewGame = false,
    this.isComingSoon = false,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (isHovered && widget.onTap != null) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get appropriate colors based on category
    final Color primaryColor = widget.color;
    final Color iconBackgroundColor =
        Color.lerp(widget.color, Colors.white, 0.15) ?? widget.color;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(
                    red: primaryColor.r.toDouble(),
                    green: primaryColor.g.toDouble(),
                    blue: primaryColor.b.toDouble(),
                    alpha: 0.4 * 255,
                  ),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                splashColor: Colors.white.withValues(
                  red: 255,
                  green: 255,
                  blue: 255,
                  alpha: 0.1 * 255,
                ),
                highlightColor: Colors.white.withValues(
                  red: 255,
                  green: 255,
                  blue: 255,
                  alpha: 0.05 * 255,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                red: 0,
                                green: 0,
                                blue: 0,
                                alpha: 0.15 * 255,
                              ),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          size: 26,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.hasNewGame && !widget.isComingSoon)
                            Container(
                              margin: EdgeInsets.only(left: 4),
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      red: 0,
                                      green: 0,
                                      blue: 0,
                                      alpha: 0.1 * 255,
                                    ),
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 6),
                      if (widget.isComingSoon)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              red: 255,
                              green: 255,
                              blue: 255,
                              alpha: 0.2 * 255,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Coming Soon',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        Text(
                          '${widget.gamesCount} Games',
                          style: TextStyle(
                            color: Colors.white.withValues(
                              red: 255,
                              green: 255,
                              blue: 255,
                              alpha: 0.85 * 255,
                            ),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
