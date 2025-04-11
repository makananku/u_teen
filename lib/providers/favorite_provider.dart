import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/favorite_item.dart';

class FavoriteProvider with ChangeNotifier {
  List<FavoriteItem> _favoriteItems = [];
  static const String _favoritesKey = 'favorites';

  List<FavoriteItem> get favoriteItems => _favoriteItems;

  FavoriteProvider() {
    _loadFavorites();
  }

  // Memuat data favorit dari SharedPreferences saat provider diinisialisasi
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      _favoriteItems = favoritesJson
          .map((json) => FavoriteItem.fromJson(jsonDecode(json)))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // Menyimpan data favorit ke SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favoriteItems
          .map((item) => jsonEncode(item.toJson()))
          .toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // Menambahkan item ke favorit
  Future<void> addToFavorites(FavoriteItem item) async {
    if (!_favoriteItems.any((existingItem) => 
        existingItem.name == item.name && 
        existingItem.image == item.image)) {
      _favoriteItems.add(item);
      await _saveFavorites();
      notifyListeners();
    }
  }

  // Menghapus item dari favorit
  Future<void> removeFromFavorites(FavoriteItem item) async {
    _favoriteItems.removeWhere((existingItem) => 
        existingItem.name == item.name && 
        existingItem.image == item.image);
    await _saveFavorites();
    notifyListeners();
  }

  // Mengecek apakah item sudah difavoritkan
  bool isFavorite(FavoriteItem item) {
    return _favoriteItems.any((existingItem) => 
        existingItem.name == item.name && 
        existingItem.image == item.image);
  }

  // Membersihkan semua favorit (opsional)
  Future<void> clearFavorites() async {
    _favoriteItems.clear();
    await _saveFavorites();
    notifyListeners();
  }
}