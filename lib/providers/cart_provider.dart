import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _userEmail;

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  bool get isLoading => _isLoading;

  Future<void> initialize(String userEmail) async {
    debugPrint('Initializing CartProvider for user: $userEmail');
    _userEmail = userEmail;
    await _loadCart();
  }

  Future<void> _loadCart() async {
    if (_userEmail == null) {
      debugPrint('Cannot load cart: userEmail is null');
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('cart')
          .doc(_userEmail)
          .get()
          .timeout(const Duration(seconds: 3), onTimeout: () {
        debugPrint('Firestore load timeout for $_userEmail');
        throw Exception('Firestore load timeout');
      });
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['items'] != null) {
          _cartItems = (data['items'] as List)
              .map((item) => CartItem.fromMap(item))
              .toList();
          debugPrint('Loaded ${_cartItems.length} items from Firestore');
        } else {
          _cartItems = [];
          debugPrint('No items found in Firestore cart');
        }
      } else {
        _cartItems = [];
        debugPrint('Cart document does not exist for $_userEmail');
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    if (_userEmail == null) {
      debugPrint('Cannot save cart: userEmail is null');
      throw Exception('User email not set');
    }
    try {
      debugPrint('Saving ${_cartItems.length} items to Firestore for $_userEmail');
      final cartData = {
        'items': _cartItems.map((item) => item.toMap()).toList(),
      };
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(_userEmail)
          .set(cartData, SetOptions(merge: false))
          .timeout(const Duration(seconds: 3), onTimeout: () {
        debugPrint('Firestore save timeout for $_userEmail');
        throw Exception('Firestore save timeout');
      });
      debugPrint('Cart saved successfully for $_userEmail');
    } catch (e) {
      debugPrint('Error saving cart: $e');
      throw Exception('Failed to save cart: $e');
    }
  }

  Future<void> addToCart(CartItem item) async {
    try {
      debugPrint('Adding to cart: ${item.name}, imgbase64 length: ${item.imgbase64.length}');
      if (item.name.isEmpty || item.sellerEmail.isEmpty) {
        throw Exception('Invalid cart item: name or sellerEmail is empty');
      }
      final existingItemIndex = _cartItems.indexWhere(
        (i) => i.name == item.name && i.subtitle == item.subtitle,
      );
      if (existingItemIndex != -1) {
        _cartItems[existingItemIndex].quantity++;
        debugPrint('Incremented quantity for ${item.name}');
      } else {
        _cartItems.add(item);
        debugPrint('Added new item: ${item.name}');
      }
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding to cart: $e');
      throw e;
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    try {
      debugPrint('Removing from cart: ${item.name}');
      _cartItems.remove(item);
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing from cart: $e');
    }
  }

  Future<void> increaseQuantity(CartItem item) async {
    try {
      debugPrint('Increasing quantity for ${item.name}');
      item.quantity++;
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('Error increasing quantity: $e');
    }
  }

  Future<void> decreaseQuantity(CartItem item) async {
    try {
      debugPrint('Decreasing quantity for ${item.name}');
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        _cartItems.remove(item);
      }
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('Error decreasing quantity: $e');
    }
  }

  Future<void> removeItems(List<CartItem> items) async {
    try {
      debugPrint('Removing ${items.length} items');
      _cartItems.removeWhere((item) => items.contains(item));
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing items: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      debugPrint('Clearing cart');
      _cartItems.clear();
      await _saveCart();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
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