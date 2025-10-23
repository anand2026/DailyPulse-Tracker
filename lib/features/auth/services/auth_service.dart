import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _currentUserKey = 'current_user_id';
  static const String _guestUserId = 'guest_user';

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_currentUserKey) ?? _guestUserId;

    return User(
      id: userId,
      email: userId == _guestUserId ? null : '$userId@local.com',
      displayName: userId == _guestUserId ? 'Guest User' : userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<User?> signUp(String email, String password) async {
    final userId = email.split('@').first;
    final user = User(
      id: userId,
      email: email,
      displayName: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _saveCurrentUser(userId);
    return user;
  }

  Future<User?> signIn(String email, String password) async {
    final userId = email.split('@').first;
    final user = User(
      id: userId,
      email: email,
      displayName: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _saveCurrentUser(userId);
    return user;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<void> _saveCurrentUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, userId);
  }
}
