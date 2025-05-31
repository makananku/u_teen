import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite_item.dart';

class FavoriteProvider with ChangeNotifier {
  List<FavoriteItem> _favoriteItems = [];
  String? _userEmail;

  List<FavoriteItem> get favoriteItems => List.unmodifiable(_favoriteItems);

  Future<void> initialize(String userEmail) async {
    _userEmail = userEmail;
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (_userEmail == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(_userEmail)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['items'] != null) {
          _favoriteItems = (data['items'] as List)
              .map((item) {
                final favoriteItem = FavoriteItem(
                  name: item['name'],
                  price: item['price'],
                  imgBase64: item['imgBase64'] ?? item['image'] ?? '',
                  subtitle: item['subtitle'],
                );
                debugPrint('Loaded favorite: ${item['name']}, imgBase64 length: ${favoriteItem.imgBase64.length}');
                return favoriteItem;
              })
              .toList();
        } else {
          _favoriteItems = [];
          debugPrint('No favorite items found for $_userEmail');
        }
      } else {
        _favoriteItems = [];
        debugPrint('No favorites document for $_userEmail');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    if (_userEmail == null) return;
    try {
      final favoritesData = {
        'items': _favoriteItems.map((item) {
          debugPrint('Saving favorite: ${item.name}, imgBase64 length: ${item.imgBase64.length}');
          return {
            'name': item.name,
            'price': item.price,
            'imgBase64': item.imgBase64,
            'subtitle': item.subtitle,
          };
        }).toList(),
      };
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(_userEmail)
          .set(favoritesData);
      debugPrint('Favorites saved for $_userEmail');
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  Future<void> addToFavorites(FavoriteItem item) async {
    if (!_favoriteItems.any((existingItem) =>
        existingItem.name == item.name && existingItem.imgBase64 == item.imgBase64)) {
      _favoriteItems.add(item);
      debugPrint('Added to favorites: ${item.name}, imgBase64 length: ${item.imgBase64.length}');
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(FavoriteItem item) async {
    _favoriteItems.removeWhere((existingItem) =>
        existingItem.name == item.name && existingItem.imgBase64 == item.imgBase64);
    debugPrint('Removed from favorites: ${item.name}');
    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(FavoriteItem item) {
    return _favoriteItems.any((existingItem) =>
        existingItem.name == item.name && existingItem.imgBase64 == item.imgBase64);
  }

  Future<void> clearFavorites() async {
    _favoriteItems.clear();
    debugPrint('Cleared all favorites for $_userEmail');
    await _saveFavorites();
    notifyListeners();
  }
}