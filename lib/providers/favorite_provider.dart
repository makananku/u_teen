import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/favorite_item.dart';
import '../../auth/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'dart:convert';

class FavoriteProvider with ChangeNotifier {
  List<FavoriteItem> _favoriteItems = [];
  String? _userEmail;
  bool _isInitialized = false;
  bool _isLoading = false;

  List<FavoriteItem> get favoriteItems => List.unmodifiable(_favoriteItems);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) {
      debugPrint('FavoriteProvider: Already initialized');
      return;
    }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null || authProvider.user!.email.isEmpty) {
      debugPrint('FavoriteProvider: No user logged in or email is empty, skipping initialization');
      _favoriteItems = [];
      _isInitialized = true;
      notifyListeners();
      return;
    }
    _userEmail = authProvider.user!.email;
    debugPrint('FavoriteProvider: Initializing for user $_userEmail');
    await _loadFavorites();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    if (_userEmail == null || _userEmail!.isEmpty) {
      debugPrint('FavoriteProvider: Cannot load favorites, no user email');
      _favoriteItems = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
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
                if (favoriteItem.imgBase64.isEmpty) {
                  debugPrint('FavoriteProvider: Warning: Empty imgBase64 for ${favoriteItem.name}');
                }
                return favoriteItem;
              })
              .toList();
          debugPrint('FavoriteProvider: Loaded ${_favoriteItems.length} favorite items');
        } else {
          _favoriteItems = [];
          debugPrint('FavoriteProvider: No items found in favorites document');
        }
      } else {
        _favoriteItems = [];
        debugPrint('FavoriteProvider: Favorites document does not exist for $_userEmail');
      }
    } catch (e) {
      debugPrint('FavoriteProvider: Error loading favorites for $_userEmail: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isValidBase64(String str) {
    try {
      base64Decode(str.startsWith('data:image') ? str.split(',').last : str);
      return true;
    } catch (e) {
      debugPrint('FavoriteProvider: Invalid Base64 string: $e');
      return false;
    }
  }

  Future<void> _saveFavorites() async {
    if (_userEmail == null || _userEmail!.isEmpty) {
      debugPrint('FavoriteProvider: Cannot save favorites, no user email');
      throw Exception('User email not set');
    }
    final firebaseUser = fb.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      debugPrint('FavoriteProvider: No authenticated user');
      throw Exception('No authenticated user');
    }
    _isLoading = true;
    notifyListeners();
    try {
      final favoritesData = {
        'items': _favoriteItems.map((item) {
          debugPrint('FavoriteProvider: Saving favorite: ${item.name}, imgBase64 length: ${item.imgBase64.length}');
          return item.toMap();
        }).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(_userEmail)
          .set(favoritesData, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10), onTimeout: () {
            debugPrint('FavoriteProvider: Firestore save timeout for $_userEmail');
            throw Exception('Firestore save timeout');
          });
      debugPrint('FavoriteProvider: Favorites saved for $_userEmail');
    } catch (e, stackTrace) {
      debugPrint('FavoriteProvider: Error saving favorites for $_userEmail: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to save favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToFavorites(FavoriteItem item) async {
    if (_userEmail == null || _userEmail!.isEmpty) {
      debugPrint('FavoriteProvider: Cannot add favorite, no user logged in');
      throw Exception('No user logged in');
    }
    if (item.name.isEmpty || item.imgBase64.isEmpty || !isValidBase64(item.imgBase64)) {
      debugPrint('FavoriteProvider: Invalid favorite item: name, imgBase64, or invalid Base64');
      throw Exception('Invalid favorite item');
    }
    if (!_favoriteItems.any((existingItem) =>
        existingItem.name == item.name && existingItem.imgBase64 == item.imgBase64)) {
      _favoriteItems.add(item);
      debugPrint('FavoriteProvider: Added to favorites: ${item.name}, imgBase64 length: ${item.imgBase64.length}');
      await _saveFavorites();
      notifyListeners();
    } else {
      debugPrint('FavoriteProvider: Item ${item.name} already in favorites');
    }
  }

  Future<void> removeFromFavorites(FavoriteItem item) async {
    if (_userEmail == null || _userEmail!.isEmpty) {
      debugPrint('FavoriteProvider: Cannot remove favorite, no user logged in');
      return;
    }
    _favoriteItems.removeWhere((existingItem) =>
        existingItem.name == item.name && existingItem.imgBase64 == item.imgBase64);
    debugPrint('FavoriteProvider: Removed from favorites: ${item.name}');
    await _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(FavoriteItem item) {
    return _favoriteItems.any((existingItem) =>
        existingItem.name == item.name && existingItem.imgBase64 == item.imgBase64);
  }

  Future<void> clearFavorites() async {
    if (_userEmail == null || _userEmail!.isEmpty) {
      debugPrint('FavoriteProvider: Cannot clear favorites, no user logged in');
      return;
    }
    _favoriteItems.clear();
    debugPrint('FavoriteProvider: Cleared all favorites for $_userEmail');
    await _saveFavorites();
    notifyListeners();
  }
}