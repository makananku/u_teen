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
    return User(
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      userType: data['userType'] ?? 'customer',
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
      // Authenticate with Firebase
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Login failed: No user found');
      }

      // Fetch user data from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        throw Exception('User data not found in Firestore');
      }

      return User.fromFirestore(doc);
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
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