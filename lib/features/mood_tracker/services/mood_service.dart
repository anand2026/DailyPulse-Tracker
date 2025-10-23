import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/database_helper.dart';
import '../models/mood_entry.dart';

class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMoodEntry(MoodEntry entry) async {
    await entry.save();
    await _syncMoodEntryToFirestore(entry);
  }

  Future<List<MoodEntry>> getMoodEntries(String userId) async {
    await _syncFromFirestore(userId);

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
    await _syncFromFirestore(userId);

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

    await _syncDeletionToFirestore(id);
  }

  // ===== SUPPORTIVE FUNCTIONS =====

  Future<void> _syncMoodEntryToFirestore(MoodEntry entry) async {
    if (entry.userId == null || entry.id == null) {
      print('❌ Cannot sync: userId or id is null');
      return;
    }

    try {
      print('📤 Syncing to Firestore: users/${entry.userId}/mood_entries/${entry.id}');
      await _firestore
          .collection('users')
          .doc(entry.userId)
          .collection('mood_entries')
          .doc(entry.id)
          .set(entry.toMap());
      print('✅ Successfully synced to Firestore');
    } catch (e) {
      print('❌ Firestore sync error: $e');
    }
  }

  Future<void> _syncDeletionToFirestore(String id) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        'mood_entries',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final entry = MoodEntry.fromMap(result.first);
        if (entry.userId != null) {
          await _firestore
              .collection('users')
              .doc(entry.userId)
              .collection('mood_entries')
              .doc(id)
              .update({'deleted': 1, 'updatedAt': DateTime.now().toIso8601String()});
        }
      }
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> _syncFromFirestore(String userId) async {
    try {
      print('📥 Syncing from Firestore for user: $userId');
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('mood_entries')
          .get();

      print('📥 Found ${snapshot.docs.length} entries in Firestore');
      if (snapshot.docs.isEmpty) return;

      final db = await DatabaseHelper.database;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final firestoreEntry = MoodEntry.fromMap(data);

        final existing = await db.query(
          'mood_entries',
          where: 'id = ?',
          whereArgs: [doc.id],
          limit: 1,
        );

        if (existing.isEmpty) {
          await db.insert(
            'mood_entries',
            firestoreEntry.toMap(),
          );
          print('✅ Inserted new entry from Firestore: ${doc.id}');
        } else {
          final localEntry = MoodEntry.fromMap(existing.first);
          final firestoreUpdated = firestoreEntry.updatedAt ?? DateTime(2000);
          final localUpdated = localEntry.updatedAt ?? DateTime(2000);

          if (firestoreUpdated.isAfter(localUpdated)) {
            await db.update(
              'mood_entries',
              firestoreEntry.toMap(),
              where: 'id = ?',
              whereArgs: [doc.id],
            );
            print('✅ Updated entry from Firestore: ${doc.id}');
          }
        }
      }
    } catch (e) {
      print('❌ Firestore sync from cloud error: $e');
    }
  }
}
