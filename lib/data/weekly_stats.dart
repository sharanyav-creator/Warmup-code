import 'models/session_record.dart';

class WeeklyStats {
  final List<bool> dayFilled; // oldest to newest, length 7
  final int sessionsCount;
  final double avgPace;
  final double crutchPercent;
  final int fumbles;

  const WeeklyStats({
    required this.dayFilled,
    required this.sessionsCount,
    required this.avgPace,
    required this.crutchPercent,
    required this.fumbles,
  });
}

WeeklyStats computeWeeklyStats(List<SessionRecord> sessions, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final weekDays = [for (var i = 6; i >= 0; i--) todayDate.subtract(Duration(days: i))];

  final weekSessions = sessions.where((s) {
    final day = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);
    return !day.isBefore(weekDays.first) && !day.isAfter(weekDays.last);
  }).toList();

  final sessionDays = weekSessions
      .map((s) => DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day))
      .toSet();

  final dayFilled = weekDays.map(sessionDays.contains).toList();

  final avgPace = weekSessions.isEmpty
      ? 0.0
      : weekSessions.map((s) => s.wordsPerMinute).reduce((a, b) => a + b) / weekSessions.length;

  final totalWords = weekSessions.fold(0, (sum, s) => sum + s.wordCount);
  final totalClutch = weekSessions.fold(0, (sum, s) => sum + s.clutchWordCount);
  final crutchPercent = totalWords == 0 ? 0.0 : totalClutch / totalWords * 100;

  final fumbles = weekSessions.fold(0, (sum, s) => sum + s.longPauseCount);

  return WeeklyStats(
    dayFilled: dayFilled,
    sessionsCount: sessionDays.length,
    avgPace: avgPace,
    crutchPercent: crutchPercent,
    fumbles: fumbles,
  );
}
