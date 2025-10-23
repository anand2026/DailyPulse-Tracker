import '../../../core/database_helper.dart';
import '../models/mood_entry.dart';

class MoodService {
  Future<void> saveMoodEntry(MoodEntry entry) async {
    await entry.save();
  }

  Future<List<MoodEntry>> getMoodEntries(String userId) async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mood_entries',
      where: 'userId = ? AND deleted = ?',
      whereArgs: [userId, 0],
      orderBy: 'date DESC',
    );

    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<List<MoodEntry>> getMoodEntriesForDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mood_entries',
      where: 'userId = ? AND date >= ? AND date <= ? AND deleted = ?',
      whereArgs: [
        userId,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
        0,
      ],
      orderBy: 'date DESC',
    );

    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  Future<void> deleteMoodEntry(String id) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'mood_entries',
      {'deleted': 1, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== SUPPORTIVE FUNCTIONS ==========================================================================================
}
