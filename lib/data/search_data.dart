import 'package:cloud_firestore/cloud_firestore.dart';

class SearchData {
  static List<String> recentSearches = [];

  static Future<void> loadRecentSearches(String userEmail) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('search_history')
          .doc(userEmail)
          .get();
      if (doc.exists) {
        recentSearches = List<String>.from(doc.data()?['searches'] ?? []);
      } else {
        recentSearches = [];
      }
    } catch (e) {
      print("Error loading recent searches: $e");
    }
  }

  static Future<void> saveRecentSearches(String userEmail) async {
    try {
      await FirebaseFirestore.instance
          .collection('search_history')
          .doc(userEmail)
          .set({'searches': recentSearches});
    } catch (e) {
      print("Error saving recent searches: $e");
    }
  }

  static Future<void> addRecentSearch(String query, String userEmail) async {
    try {
      recentSearches.remove(query);
      recentSearches.insert(0, query);
      if (recentSearches.length > 10) {
        recentSearches.removeLast();
      }
      await saveRecentSearches(userEmail);
    } catch (e) {
      print("Error adding recent search: $e");
    }
  }

  static Future<void> removeRecentSearch(String query, String userEmail) async {
    try {
      recentSearches.remove(query);
      await saveRecentSearches(userEmail);
    } catch (e) {
      print("Error removing recent search: $e");
    }
  }

  static List<String> getRecentSearches() {
    return recentSearches;
  }

  static Future<List<String>> getPopularCuisines() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('popular_cuisines')
          .doc('cuisines')
          .get();
      return List<String>.from(snapshot.data()?['items'] ?? [
        'Soto', 'Nasi Pecel', 'Bakso', 'Rice', 'Bakso & Soto', 'Coffee'
      ]);
    } catch (e) {
      print("Error loading popular cuisines: $e");
      return ['Soto', 'Nasi Pecel', 'Bakso', 'Rice', 'Bakso & Soto', 'Coffee'];
    }
  }
}