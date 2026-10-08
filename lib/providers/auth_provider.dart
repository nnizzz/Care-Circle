import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth;
import 'package:flutter/foundation.dart';

import '../models/hivemodels.dart';

class AuthProvider extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore =FirebaseFirestore.instance;

  User? _currentUser;
  String? _loginError;

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  String? get loginError => _loginError;

  String? get userRole => _currentUser?.role;

  // Register user or orphanage
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    String? address,
    String? district,
    String? category,
  }) async {
    try {
      final credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'id': uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create orphanage profile
      if (role == 'orphanage') {
        await _firestore
            .collection('orphanages')
            .doc(uid)
            .set({
          'id': uid,
          'userId': uid,
          'name': name.trim(),
          'address': address?.trim() ?? '',
          'description': '',
          'image': '',
          'verified': false,
          'district': district?.trim() ?? '',
          'category': category?.trim() ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _currentUser = User(
        id: uid,
        name: name.trim(),
        email: email.trim(),
        password: '',
        phone: phone.trim(),
        role: role,
      );

      _loginError = null;

      notifyListeners();

      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint(
        'Firebase registration error: ${e.code}',
      );

      if (e.code == 'email-already-in-use') {
        _loginError ='This email is already registered.';
      } else if (e.code == 'weak-password') {
        _loginError = 'Password is too weak.';
      } else if (e.code == 'invalid-email') {
        _loginError = 'Please enter a valid email address.';
      } else {
        _loginError = 'Registration failed. Please try again.';
      }

      return false;
    } catch (e) {
      debugPrint('Registration error: $e');

      _loginError ='Registration failed. Please try again.';

      return false;
    }
  }

  // Login user or orphanage
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      _loginError = null;
      _currentUser = null;

      final credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      final document =
          await _firestore
              .collection('users')
              .doc(uid)
              .get();

      if (!document.exists) {
        _loginError =
            'User profile not found.';

        await _auth.signOut();

        return false;
      }

      final data = document.data()!;

      _currentUser = User(
        id: uid,
        name: data['name']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        password: '',
        phone: data['phone']?.toString() ?? '',
        role: data['role']?.toString() ?? 'user',
      );

      notifyListeners();

      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint(
        'Firebase login error: ${e.code}',
      );

      _currentUser = null;

      if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        _loginError =
            'Email or password is incorrect!';
      } else if (e.code == 'invalid-email') {
        _loginError =
            'Please enter a valid email address.';
      } else if (e.code == 'too-many-requests') {
        _loginError =
            'Too many login attempts. Please try again later.';
      } else if (e.code == 'network-request-failed') {
        _loginError =
            'Please check your internet connection.';
      } else {
        _loginError =
            'Unable to login. Please try again.';
      }

      notifyListeners();

      return false;
    } catch (e) {
      debugPrint('Login error: $e');

      _currentUser = null;

      _loginError =
          'Unable to login. Please try again.';

      notifyListeners();

      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    _currentUser = null;
    _loginError = null;

    notifyListeners();
  }

  // Check role
  bool hasRole(String role) {
    return _currentUser?.role == role;
  }
}