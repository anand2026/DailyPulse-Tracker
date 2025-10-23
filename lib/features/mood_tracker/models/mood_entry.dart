import 'package:sqflite/sqflite.dart';
import '../../../core/database_helper.dart';

enum MoodType {
  great,
  good,
  okay,
  bad,
  terrible;

  String get emoji {
    switch (this) {
      case MoodType.great:
        return '😄';
      case MoodType.good:
        return '🙂';
      case MoodType.okay:
        return '😐';
      case MoodType.bad:
        return '😔';
      case MoodType.terrible:
        return '😢';
    }
  }

  String get label {
    switch (this) {
      case MoodType.great:
        return 'Great';
      case MoodType.good:
        return 'Good';
      case MoodType.okay:
        return 'Okay';
      case MoodType.bad:
        return 'Bad';
      case MoodType.terrible:
        return 'Terrible';
    }
  }

  bool get isPositive {
    return this == MoodType.great || this == MoodType.good;
  }
}

class MoodEntry {
  final String? id;
  final String? userId;
  final DateTime? date;
  final MoodType? moodType;
  final String? emoji;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? deleted;

  MoodEntry({
    this.id,
    this.userId,
    this.date,
    this.moodType,
    this.emoji,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.deleted,
  });

  Future<void> save() async {
    if (id == null) {
      throw Exception('Cannot save mood entry: id is null');
    }

    try {
      final db = await DatabaseHelper.database;
      final map = toMap();

      await db.insert(
        'mood_entries',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to save mood entry to database: ${e.toString()}');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date?.toIso8601String(),
      'moodType': moodType?.name,
      'emoji': emoji ?? moodType?.emoji,
      'note': note,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'deleted': deleted ?? 0,
    };
  }

  static MoodEntry fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      userId: map['userId'],
      date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
      moodType: map['moodType'] != null
          ? MoodType.values.firstWhere(
              (e) => e.name == map['moodType'],
              orElse: () => MoodType.okay,
            )
          : null,
      emoji: map['emoji'],
      note: map['note'],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      deleted: map['deleted'],
    );
  }

  MoodEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    MoodType? moodType,
    String? emoji,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? deleted,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      moodType: moodType ?? this.moodType,
      emoji: emoji ?? this.emoji,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }
}
