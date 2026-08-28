import '../db/app_database.dart';
import '../models/session_record.dart';

class SessionRepository {
  Future<int> insert(SessionRecord session) async {
    final db = await AppDatabase.instance.database;
    final map = session.toMap()..remove('id');
    return db.insert('sessions', map);
  }

  Future<List<SessionRecord>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('sessions', orderBy: 'createdAt DESC');
    return rows.map(SessionRecord.fromMap).toList();
  }

  Future<List<SessionRecord>> getRecent(int limit) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'sessions',
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    return rows.map(SessionRecord.fromMap).toList();
  }

  Future<Map<DateTime, List<SessionRecord>>> getGroupedByDay() async {
    final all = await getAll();
    final grouped = <DateTime, List<SessionRecord>>{};
    for (final s in all) {
      final day = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);
      grouped.putIfAbsent(day, () => []).add(s);
    }
    return grouped;
  }
}
