import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if this is the first run of the app
  static Future<bool> isFirstRun() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Return true if the 'first_run' key does not exist or is true
      final isFirst = prefs.getBool('first_run') ?? true;
      print('isFirstRun checked: $isFirst');
      return isFirst;
    } catch (e) {
      print('Error checking first run status: $e');
      return true; // Default to true to ensure initialization on error
    }
  }

  // Mark the first run as complete
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

    // Ensure user is authenticated (use anonymous login if not logged in)
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

    // Check if database is already initialized
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
      // Initialize Popular Cuisines
      await _initializePopularCuisines();

      // Check if 'products' collection already exists
      final productsSnapshot = await _firestore.collection('products').get();
      if (productsSnapshot.docs.isNotEmpty) {
        print('Products already exist, skipping product initialization.');
      } else {
        print('No products found. Please run the Python initialization script.');
      }

      // Mark initialization as complete in Firestore
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