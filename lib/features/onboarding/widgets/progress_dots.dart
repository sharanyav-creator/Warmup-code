import 'package:flutter/material.dart';

import '../../../core/design_tokens.dart';

/// Reproduces the 3-segment pill progress indicator from the Figma
/// onboarding frames (Frame 54): equal rounded segments, 18px gaps,
/// active segment solid orange, inactive segments white @ 20% opacity.
class ProgressDots extends StatelessWidget {
  final int total;
  final int activeIndex;

  const ProgressDots({super.key, required this.total, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 18),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: i == activeIndex ? OnboardingColors.orange : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
