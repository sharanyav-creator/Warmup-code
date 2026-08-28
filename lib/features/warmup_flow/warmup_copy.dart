import '../../data/models/session_record.dart';

typedef ChangeBadge = ({String label, bool isGood});

/// Compares a count-style metric (lower is better) to the previous session,
/// e.g. "2 words lesser than Last Warmup".
ChangeBadge? countDiffBadge(int current, int? previous, String unit) {
  if (previous == null) return null;
  final diff = previous - current;
  if (diff == 0) return null;
  final decreased = diff > 0;
  final amount = diff.abs();
  final word = amount == 1 ? unit : '${unit}s';
  return (
    label: decreased ? '$amount $word lesser than Last Warmup' : '$amount $word more than Last Warmup',
    isGood: decreased,
  );
}

ChangeBadge paceBadge(double wpm) {
  if (wpm >= 110 && wpm <= 160) return (label: 'Ideal', isGood: true);
  return (label: wpm < 110 ? 'Too slow' : 'Too fast', isGood: false);
}

String summaryHeadline(SessionRecord s) {
  if (s.wordCount == 0) return "We didn't catch any speech that time.";
  if (s.fillerCount == 0) return 'That was clean. Barely any filler words today.';
  if (s.fillerCount <= 2) return 'Pretty smooth, just a couple of filler words today.';
  if (s.fillerCount <= 5) return 'A few filler words crept in today.';
  return 'Filler words showed up a lot today — worth another rep.';
}
