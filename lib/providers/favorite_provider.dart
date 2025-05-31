import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/favorite_item.dart';
import '../../auth/auth_provider.dart';

class FavoriteProvider with ChangeNotifier {
  List<FavoriteItem> _favoriteItems = [];
  String? _userEmail;
  bool _isInitialized = false;

  List<FavoriteItem> get favoriteItems => List.unmodifiable(_favoriteItems);

  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) {
      debugPrint('FavoriteProvider: Already initialized');
      return;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userEmail = authProvider.user?.email;
    if (_userEmail == null) {
      debugPrint('FavoriteProvider: No user logged in, cannot initialize favorites');
      _favoriteItems = [];
      notifyListeners();
      return;
    }
    debugPrint('FavoriteProvider: Initializing for user $_userEmail');
    await _loadFavorites();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    if (_userEmail == null) {
      debugPrint('FavoriteProvider: Cannot load favorites, no user email');
      return;
    }
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
                final favoriteItem = FavoriteItem.fromMap(item);
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
      debugPrint('Error loading favorites for $_userEmail: $e');
    }
  }

  Future<void> _saveFavorites() async {
    if (_userEmail == null) {
      debugPrint('FavoriteProvider: Cannot save favorites, no user email');
      return;
    }
    try {
      final favoritesData = {
        'items': _favoriteItems.map((item) {
          debugPrint('Saving favorite: ${item.name}, imgBase64 length: ${item.imgBase64.length}');
          return item.toMap();
        }).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(_userEmail)
          .set(favoritesData, SetOptions(merge: true));
      debugPrint('Favorites saved for $_userEmail');
    } catch (e) {
      debugPrint('Error saving favorites for $_userEmail: $e');
      throw Exception('Failed to save favorites: $e');
    }
  }

  Future<void> addToFavorites(FavoriteItem item) async {
    if (_userEmail == null) {
      debugPrint('FavoriteProvider: Cannot add favorite, no user logged in');
      throw Exception('No user logged in');
    }
    if (!_favoriteItems.any((existingItem) =>
        existingItem.name == item.name && existingItem.imgBase64 == item.imgBase64)) {
      _favoriteItems.add(item);
      debugPrint('Added to favorites: ${item.name}, imgBase64 length: ${item.imgBase64.length}');
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFromFavorites(FavoriteItem item) async {
    if (_userEmail == null) {
      debugPrint('FavoriteProvider: Cannot remove favorite, no user logged in');
      return;
    }
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
    if (_userEmail == null) {
      debugPrint('FavoriteProvider: Cannot clear favorites, no user logged in');
      return;
    }
    _favoriteItems.clear();
    debugPrint('Cleared all favorites for $_userEmail');
    await _saveFavorites();
    notifyListeners();
  }
}