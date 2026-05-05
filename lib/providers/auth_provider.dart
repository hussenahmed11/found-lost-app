import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;
  Map<String, dynamic>? _profile;
  bool _loading = true;

  User? get user => _user;
  Map<String, dynamic>? get profile => _profile;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        _user = firebaseUser;
        _profile = await _authService.getUserProfile(firebaseUser.uid);
      } else {
        _user = null;
        _profile = null;
      }
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email, password);
  }

  Future<void> signInWithGoogle() async {
    final userCredential = await _authService.signInWithGoogle();
    if (userCredential != null) {
      _profile = await _authService.getUserProfile(userCredential.user!.uid);
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name) async {
    final userCredential = await _authService.register(email, password, name);
    _profile = {
      'uid': userCredential.user!.uid,
      'name': name,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
      'profileImage': null,
    };
    notifyListeners();
  }

  /// Update user profile fields in Firestore and refresh local cache.
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final uid = _user?.uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).update(updates);

    // Refresh local profile cache
    _profile = await _authService.getUserProfile(uid);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}
