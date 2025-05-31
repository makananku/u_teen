import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> isFirstRun() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirst = prefs.getBool('first_run') ?? true;
      print('isFirstRun checked: $isFirst');
      return isFirst;
    } catch (e) {
      print('Error checking first run status: $e');
      return true;
    }
  }

  static Future<void> setFirstRunComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_run', false);
      print('First run marked as complete');
    } catch (e) {
      print('Error setting first run complete: $e');
    }
  }

  static Future<void> initializeData() async {
    print('Starting database initialization...');

    // Skip anonymous login; rely on AuthProvider
    if (_auth.currentUser == null || _auth.currentUser!.isAnonymous) {
      print('No authenticated user, skipping initialization until login');
      return;
    }
    print('User logged in: ${_auth.currentUser?.email}');

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
      await _initializePopularCuisines();

      final productsSnapshot = await _firestore.collection('products').get();
      if (productsSnapshot.docs.isNotEmpty) {
        print('Products already exist, skipping product initialization.');
      } else {
        print('No products found. Please run the Python initialization script.');
      }

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