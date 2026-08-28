import '../../data/models/session_record.dart';

typedef ChangeBadge = ({String label, bool isGood});

/// Compares a count-style metric (lower is better) to the previous session.
ChangeBadge? percentChange(int current, int? previous) {
  if (previous == null || previous == 0) return null;
  final diff = previous - current;
  final pct = (diff.abs() / previous * 100).round();
  if (pct == 0) return null;
  final decreased = diff > 0;
  return (
    label: decreased ? '$pct% lesser than last Warmup' : '$pct% more than last time',
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
