import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _userId;

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  bool get isLoading => _isLoading;

  Future<void> initialize(String userId) async {
    debugPrint('CartProvider: Initializing for user ID: $userId');
    _userId = userId;
    await _loadCart();
  }

  Future<void> _loadCart() async {
    if (_userId == null) {
      debugPrint('CartProvider: Cannot load cart: userId is null');
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final authUser = fb.FirebaseAuth.instance.currentUser;
      debugPrint('CartProvider: Loading cart for $_userId, auth user: ${authUser?.email}, uid: ${authUser?.uid}');
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .doc('cart')
          .get()
          .timeout(const Duration(seconds: 3), onTimeout: () {
        debugPrint('CartProvider: Firestore load timeout for $_userId');
        throw Exception('Firestore load timeout');
      });
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['items'] != null) {
          _cartItems = (data['items'] as List)
              .map((item) => CartItem.fromMap(item))
              .toList();
          debugPrint('CartProvider: Loaded ${_cartItems.length} items from Firestore');
        } else {
          _cartItems = [];
          debugPrint('CartProvider: No items found in Firestore cart');
        }
      } else {
        _cartItems = [];
        debugPrint('CartProvider: Cart document does not exist for $_userId');
      }
    } catch (e) {
      debugPrint('CartProvider: Error loading cart: $e');
      if (e.toString().contains('permission-denied')) {
        debugPrint('CartProvider: Permission denied when loading cart for $_userId. Check Firestore rules.');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    if (_userId == null) {
      debugPrint('CartProvider: Cannot save cart: userId is null');
      throw Exception('User ID not set');
    }
    try {
      final authUser = fb.FirebaseAuth.instance.currentUser;
      debugPrint('CartProvider: Saving ${_cartItems.length} items to Firestore for $_userId, auth user: ${authUser?.email}, uid: ${authUser?.uid}');
      final cartData = {
        'items': _cartItems.map((item) => item.toMap()).toList(),
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .doc('cart')
          .set(cartData, SetOptions(merge: false))
          .timeout(const Duration(seconds: 3), onTimeout: () {
        debugPrint('CartProvider: Firestore save timeout for $_userId');
        throw Exception('Firestore save timeout');
      });
      debugPrint('CartProvider: Cart saved successfully for $_userId');
    } catch (e) {
      debugPrint('CartProvider: Error saving cart: $e');
      if (e.toString().contains('permission-denied')) {
        debugPrint('CartProvider: Permission denied when saving cart for $_userId. Check Firestore rules.');
      }
      throw Exception('Failed to save cart: $e');
    }
  }

  Future<void> addToCart(CartItem item) async {
    try {
      debugPrint('CartProvider: Adding to cart: ${item.name}, imgbase64 length: ${item.imgBase64.length}');
      if (item.name.isEmpty || item.sellerEmail.isEmpty) {
        throw Exception('Invalid cart item: name or sellerEmail is empty');
      }
      final existingItemIndex = _cartItems.indexWhere(
        (i) => i.name == item.name && i.subtitle == item.subtitle,
      );
      if (existingItemIndex != -1) {
        _cartItems[existingItemIndex].quantity++;
        debugPrint('CartProvider: Incremented quantity for ${item.name}');
      } else {
        _cartItems.add(item);
        debugPrint('CartProvider: Added new item: ${item.name}');
      }
      await _saveCart();
      await Future.delayed(const Duration(milliseconds: 250));
      debugPrint('CartProvider: Notifying listeners after cart update');
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider: Error adding to cart: $e');
      throw e;
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    try {
      debugPrint('CartProvider: Removing from cart: ${item.name}');
      _cartItems.remove(item);
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider: Error removing from cart: $e');
    }
  }

  Future<void> increaseQuantity(CartItem item) async {
    try {
      debugPrint('CartProvider: Increasing quantity for ${item.name}');
      item.quantity++;
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider: Error increasing quantity: $e');
    }
  }

  Future<void> decreaseQuantity(CartItem item) async {
    try {
      debugPrint('CartProvider: Decreasing quantity for ${item.name}');
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        _cartItems.remove(item);
      }
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider: Error decreasing quantity: $e');
    }
  }

  Future<void> removeItems(List<CartItem> items) async {
    try {
      debugPrint('CartProvider: Removing ${items.length} items');
      _cartItems.removeWhere((item) => items.contains(item));
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider: Error removing items: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      debugPrint('CartProvider: Clearing cart');
      _cartItems.clear();
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider: Error clearing cart: $e');
    }
  }

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  Map<String, List<CartItem>> get groupedItems {
    final Map<String, List<CartItem>> groups = {};
    for (var item in _cartItems) {
      if (!groups.containsKey(item.subtitle)) {
        groups[item.subtitle] = [];
      }
      groups[item.subtitle]!.add(item);
    }
    return groups;
  }
}