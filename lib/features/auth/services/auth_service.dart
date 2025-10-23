import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as model;

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<model.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserFromFirebase(firebaseUser);
    });
  }

  model.User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    return model.User(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      createdAt: firebaseUser.metadata.creationTime,
      updatedAt: DateTime.now(),
    );
  }

  Future<model.User> signUp(String email, String password, String displayName) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(displayName);

    final user = model.User(
      id: credential.user!.uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deleted: false,
    );

    await user.save();
    await _saveUserToFirestore(user);

    return user;
  }

  Future<model.User> signIn(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = await _getUserFromFirebase(credential.user!);
    await user.save();

    return user;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateProfile(String displayName) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) throw Exception('No user logged in');

    await firebaseUser.updateDisplayName(displayName);

    final user = model.User(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: displayName,
      createdAt: firebaseUser.metadata.creationTime,
      updatedAt: DateTime.now(),
    );

    await user.save();
    await _saveUserToFirestore(user);
  }

  // ===== SUPPORTIVE FUNCTIONS =====

  Future<model.User> _getUserFromFirebase(firebase_auth.User firebaseUser) async {
    return model.User(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      createdAt: firebaseUser.metadata.creationTime,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _saveUserToFirestore(model.User user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }
}
