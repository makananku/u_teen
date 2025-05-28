import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> initializeData() async {
    print('Starting database initialization...');

    // Pastikan pengguna terautentikasi (gunakan login anonim jika belum login)
    try {
      if (_auth.currentUser == null) {
        print('No user logged in, signing in anonymously...');
        await _auth.signInAnonymously();
        print('Anonymous login successful: ${_auth.currentUser?.uid}');
      } else {
        print('User already logged in: ${_auth.currentUser?.uid}');
      }
    } catch (e) {
      print('Error during anonymous login: $e');
      return;
    }

    // Periksa apakah database sudah diinisialisasi
    try {
      final initializedDoc = await _firestore.collection('metadata').doc('initialized').get();
      if (initializedDoc.exists && initializedDoc.data()?['status'] == true) {
        print('Database already initialized, skipping initialization.');
        return;
      }
    } catch (e) {
      print('Error checking initialization status: $e');
      return;
    }

    try {
      // Inisialisasi Popular Cuisines
      await _initializePopularCuisines();

      // Periksa apakah koleksi 'products' sudah ada
      final productsSnapshot = await _firestore.collection('products').get();
      if (productsSnapshot.docs.isNotEmpty) {
        print('Products already exist, skipping product initialization.');
      } else {
        print('No products found. Please run the Python initialization script.');
      }

      // Tandai inisialisasi selesai
      await _firestore.collection('metadata').doc('initialized').set({'status': true});
      print('Database initialization completed successfully.');
    } catch (e) {
      print('Error during database initialization: $e');
    }
  }

  static Future<void> _initializePopularCuisines() async {
    try {
      final docRef = _firestore.collection('popular_cuisines').doc('cuisines');
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          'items': ['Soto', 'Nasi Pecel', 'Bakso', 'Rice', 'Bakso & Soto', 'Coffee']
        });
        print('Popular cuisines initialized successfully.');
      } else {
        print('Popular cuisines already initialized.');
      }
    } catch (e) {
      print('Error initializing popular cuisines: $e');
    }
  }
}