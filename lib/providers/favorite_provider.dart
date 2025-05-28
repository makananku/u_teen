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
              .map((item) => FavoriteItem(
                    name: item['name'],
                    price: item['price'],
                    image: item['image'],
                    subtitle: item['subtitle'],
                  ))
              .toList();
        } else {
          _favoriteItems = [];
        }
      } else {
        _favoriteItems = [];
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
        'items': _favoriteItems.map((item) => {
              'name': item.name,
              'price': item.price,
              'image': item.image,
              'subtitle': item.subtitle,
            }).toList(),
      };
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(_userEmail)
          .set(favoritesData);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  Future<void> addToFavorites(FavoriteItem item) async {
    if (!_favoriteItems.any((existingItem) =>
        existingItem.name == item.name && existingItem.image == item.image)) {
      _favoriteItems.add(item);
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(FavoriteItem item) async {
    _favoriteItems.removeWhere((existingItem) =>
        existingItem.name == item.name && existingItem.image == item.image);
    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(FavoriteItem item) {
    return _favoriteItems.any((existingItem) =>
        existingItem.name == item.name && existingItem.image == item.image);
  }

  Future<void> clearFavorites() async {
    _favoriteItems.clear();
    await _saveFavorites();
    notifyListeners();
  }
}