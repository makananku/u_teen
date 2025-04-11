import 'package:shared_preferences/shared_preferences.dart';

class SearchData {
  static List<String> recentSearches = [];

  // Load recent searches dari SharedPreferences
  static Future<void> loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      recentSearches = prefs.getStringList('recentSearches') ?? [];
    } catch (e) {
      print("Error loading recent searches: $e");
    }
  }

  // Simpan recent searches ke SharedPreferences
  static Future<void> saveRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recentSearches', recentSearches);
    } catch (e) {
      print("Error saving recent searches: $e");
    }
  }

  // Menambahkan search query ke recent searches
  static Future<void> addRecentSearch(String query) async {
    try {
      if (!recentSearches.contains(query)) {
        recentSearches.insert(0, query); // Tambahkan di awal list
        // Batasi jumlah recent searches (misalnya, maksimal 10)
        if (recentSearches.length > 10) {
          recentSearches.removeLast();
        }
        await saveRecentSearches(); // Simpan ke SharedPreferences
      }
    } catch (e) {
      print("Error adding recent search: $e");
    }
  }

  // Menghapus search query dari recent searches
  static Future<void> removeRecentSearch(String query) async {
    try {
      recentSearches.remove(query);
      await saveRecentSearches(); // Simpan ke SharedPreferences
    } catch (e) {
      print("Error removing recent search: $e");
    }
  }

  // Mendapatkan daftar recent searches
  static List<String> getRecentSearches() {
    return recentSearches;
  }

  // Data untuk popular cuisines (tetap statis)
  static List<String> getPopularCuisines() {
    return ['Soto', 'Nasi Pecel', 'Bakso', 'Rice', 'Bakso & Soto', 'Coffee'];
  }
}
