import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../data/models/session_record.dart';
import 'warmup_copy.dart';

enum WarmupFactor { fillerWords, pace, longPauses, fumbles }

extension WarmupFactorX on WarmupFactor {
  String get title {
    switch (this) {
      case WarmupFactor.fillerWords:
        return 'Filler words';
      case WarmupFactor.pace:
        return 'Pace';
      case WarmupFactor.longPauses:
        return 'Long pauses';
      case WarmupFactor.fumbles:
        return 'Fumbles';
    }
  }

  int currentCount(SessionRecord s) {
    switch (this) {
      case WarmupFactor.fillerWords:
        return s.fillerCount;
      case WarmupFactor.pace:
        return s.wordsPerMinute.round();
      case WarmupFactor.longPauses:
        return s.longPauseCount;
      case WarmupFactor.fumbles:
        return s.fumbleCount;
    }
  }

  int? previousCount(SessionRecord? previous) {
    if (previous == null) return null;
    switch (this) {
      case WarmupFactor.fillerWords:
        return previous.fillerCount;
      case WarmupFactor.pace:
        return previous.wordsPerMinute.round();
      case WarmupFactor.longPauses:
        return previous.longPauseCount;
      case WarmupFactor.fumbles:
        return previous.fumbleCount;
    }
  }

  /// Singular unit noun used in stat labels and change badges, e.g. "word".
  String get unit {
    switch (this) {
      case WarmupFactor.fillerWords:
        return 'word';
      case WarmupFactor.pace:
        return 'wpm';
      case WarmupFactor.longPauses:
        return 'pause';
      case WarmupFactor.fumbles:
        return 'time';
    }
  }

  String valueLabel(SessionRecord s) {
    if (this == WarmupFactor.pace) return '${s.wordsPerMinute.round()} wpm';
    final count = currentCount(s);
    return '$count ${count == 1 ? unit : '${unit}s'}';
  }

  ChangeBadge? badge(SessionRecord s, SessionRecord? previous) {
    if (this == WarmupFactor.pace) return paceBadge(s.wordsPerMinute);
    return countDiffBadge(currentCount(s), previousCount(previous), unit);
  }

  /// Bar fraction: proportion of "current" against current+previous, so the
  /// bar visually shows whether this session moved up or down.
  double barFraction(SessionRecord s, SessionRecord? previous) {
    final current = currentCount(s).toDouble();
    final prev = previousCount(previous)?.toDouble();
    if (prev == null || (current == 0 && prev == 0)) return current > 0 ? 0.6 : 0.15;
    final total = current + prev;
    if (total == 0) return 0.15;
    return (current / total).clamp(0.08, 0.92);
  }
}

class FactorBarCard extends StatelessWidget {
  final WarmupFactor factor;
  final SessionRecord session;
  final SessionRecord? previous;
  final VoidCallback? onTap;

  const FactorBarCard({
    super.key,
    required this.factor,
    required this.session,
    required this.previous,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badge = factor.badge(session, previous);
    final fraction = factor.barFraction(session, previous);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(factor.title, style: OnboardingText.body(color: Colors.black).copyWith(fontSize: 12)),
                Text(
                  factor.valueLabel(session),
                  style: OnboardingText.body(color: Colors.black).copyWith(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: (fraction * 100).round(),
                      child: Container(color: OnboardingColors.orange),
                    ),
                    Expanded(
                      flex: 100 - (fraction * 100).round(),
                      child: Container(color: const Color(0xFFE5E0D8)),
                    ),
                  ],
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(height: 6),
              Text(
                badge.label.toUpperCase(),
                style: OnboardingText.buttonLabel(color: const Color(0xFFBBBBBB)).copyWith(fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
