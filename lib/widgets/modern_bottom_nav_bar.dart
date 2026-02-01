import 'package:flutter/material.dart';

class ModernBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<ModernNavItem> items;

  const ModernBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.items = const [
      ModernNavItem(icon: Icons.grid_view_rounded, label: 'Home'),
      ModernNavItem(icon: Icons.person_rounded, label: 'Profile'),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          return _buildNavItem(context, index, items[index]);
        }),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, ModernNavItem item) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 24 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withOpacity(0.6),
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ModernNavItem {
  final IconData icon;
  final String label;

  const ModernNavItem({required this.icon, required this.label});
}
