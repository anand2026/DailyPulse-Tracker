import 'package:sqflite/sqflite.dart';
import '../../../core/database_helper.dart';

class User {
  final String? id;
  final String? email;
  final String? displayName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? deleted;

  User({
    this.id,
    this.email,
    this.displayName,
    this.createdAt,
    this.updatedAt,
    this.deleted,
  });

  Future<void> save() async {
    final db = await DatabaseHelper.database;
    final now = DateTime.now();

    final userData = {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': (createdAt ?? now).toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'deleted': (deleted ?? false) ? 1 : 0,
    };

    await db.insert(
      'users',
      userData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deleted': (deleted ?? false) ? 1 : 0,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
      deleted: map['deleted'] == 1,
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }
}
