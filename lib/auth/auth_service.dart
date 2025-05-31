import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

class User {
  final String email;
  final String name;
  final String userType; // 'seller' or 'customer'
  final String? nim;
  final String? phoneNumber;
  final String? prodi;
  final String? angkatan;
  final String? tenantName; // Added for sellers

  User({
    required this.email,
    required this.name,
    required this.userType,
    this.nim,
    this.phoneNumber,
    this.prodi,
    this.angkatan,
    this.tenantName,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final email = data['email'] ?? '';
    final name = data['name'] ?? '';
    final userType = data['userType'] ?? 'customer';

    if (email.isEmpty || name.isEmpty || userType.isEmpty) {
      throw Exception('Invalid user data: email, name, or userType is missing');
    }

    return User(
      email: email,
      name: name,
      userType: userType,
      nim: data['nim'],
      phoneNumber: data['phoneNumber'],
      prodi: data['prodi'],
      angkatan: data['angkatan'],
      tenantName: data['tenantName'],
    );
  }
}

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    try {
      debugPrint('AuthService: Attempting login for $email');
      // Authenticate with Firebase
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        debugPrint('AuthService: Login failed, no user found');
        throw Exception('Login failed: No user found');
      }

      debugPrint('AuthService: Authenticated user UID: ${credential.user!.uid}');
      // Fetch user data from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        debugPrint('AuthService: Firestore document not found for UID: ${credential.user!.uid}');
        throw Exception('User data not found in Firestore for UID: ${credential.user!.uid}');
      }

      final user = User.fromFirestore(doc);
      debugPrint('AuthService: Successfully fetched user: ${user.email}, type: ${user.userType}');
      return user;
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('AuthService: FirebaseAuth error: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email format.');
      } else {
        throw Exception('Authentication error: ${e.message}');
      }
    } catch (e) {
      debugPrint('AuthService: Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}