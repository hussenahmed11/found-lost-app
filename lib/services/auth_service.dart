import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user.
  User? get currentUser => _auth.currentUser;

  /// Sign in with email & password.
  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Register with email, password, and name.
  /// Also creates a user profile document in Firestore.
  Future<UserCredential> register(
      String email, String password, String name) async {
    final userCredential =
        await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final newUser = userCredential.user!;

    final profileData = {
      'uid': newUser.uid,
      'name': name,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
      'profileImage': null,
    };

    await _db.collection('users').doc(newUser.uid).set(profileData);
    return userCredential;
  }

  /// Fetch user profile from Firestore.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  /// Sign out.
  Future<void> logout() => _auth.signOut();
}
