import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/design_tokens.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  static const _items = [
    (label: 'Home', activeIcon: 'nav_home_active.svg', inactiveIcon: 'nav_home_inactive.svg'),
    (label: 'Progress', activeIcon: 'nav_progress_active.svg', inactiveIcon: 'nav_progress_inactive.svg'),
    (label: 'Goals', activeIcon: 'nav_goals_active.svg', inactiveIcon: 'nav_goals_inactive.svg'),
    (label: 'Profile', activeIcon: 'nav_profile_active.svg', inactiveIcon: 'nav_profile_inactive.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OnboardingColors.creamBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < _items.length; i++)
              _NavItem(
                label: _items[i].label,
                iconAsset: 'assets/main/${i == currentIndex ? _items[i].activeIcon : _items[i].inactiveIcon}',
                active: i == currentIndex,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String iconAsset;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.label, required this.iconAsset, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? OnboardingColors.maroonBackground : OnboardingColors.navInactive;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(iconAsset, width: 24, height: 24),
            const SizedBox(height: 4),
            Text(label, style: OnboardingText.headline(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
