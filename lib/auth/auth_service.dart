import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    try {
      // Login dengan Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ambil data pengguna dari Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return User(
          email: userCredential.user!.email!,
          name: userDoc['name'] ?? '',
          userType: userDoc['userType'] ?? 'customer',
          nim: userDoc['nim'] ?? '',
          phoneNumber: userDoc['phoneNumber'] ?? '',
          prodi: userDoc['prodi'] ?? '',
          angkatan: userDoc['angkatan'] ?? '',
        );
      } else {
        print('User document not found in Firestore');
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'Email diperlukan';
    if (!email.endsWith('@student.umn.ac.id') &&
        !email.endsWith('@seller.umn.ac.id') &&
        !email.endsWith('@umn.ac.id') &&
        !email.endsWith('@lecturer.umn.ac.id')) {
      return 'Email harus menggunakan domain UMN yang valid';
    }
    return null;
  }
}

class User {
  final String email;
  final String name;
  final String userType;
  final String nim;
  final String phoneNumber;
  final String prodi;
  final String angkatan;

  User({
    required this.email,
    required this.name,
    required this.userType,
    required this.nim,
    required this.phoneNumber,
    required this.prodi,
    required this.angkatan,
  });
}