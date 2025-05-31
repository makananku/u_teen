import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _userEmail;

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  bool get isLoading => _isLoading;

  // Initialize with user email to scope cart data
  Future<void> initialize(String userEmail) async {
    _userEmail = userEmail;
    await _loadCart();
  }

  Future<void> _loadCart() async {
    if (_userEmail == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('cart')
          .doc(_userEmail)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['items'] != null) {
          _cartItems = (data['items'] as List)
              .map((item) => CartItem(
                    name: item['name'],
                    price: item['price'],
                    imgbase64: item['imgbase64'],
                    subtitle: item['subtitle'],
                    sellerEmail: item['sellerEmail'],
                    quantity: item['quantity'],
                  ))
              .toList();
        } else {
          _cartItems = [];
        }
      } else {
        _cartItems = [];
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    if (_userEmail == null) return;
    try {
      final cartData = {
        'items': _cartItems.map((item) => {
              'name': item.name,
              'price': item.price,
              'imgbase64': item.imgbase64,
              'subtitle': item.subtitle,
              'sellerEmail': item.sellerEmail,
              'quantity': item.quantity,
            }).toList(),
      };
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(_userEmail)
          .set(cartData);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<void> addToCart(CartItem item) async {
    final existingItemIndex = _cartItems.indexWhere(
      (i) => i.name == item.name && i.subtitle == item.subtitle,
    );
    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].quantity++;
    } else {
      _cartItems.add(item);
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeFromCart(CartItem item) async {
    _cartItems.remove(item);
    await _saveCart();
    notifyListeners();
  }

  Future<void> increaseQuantity(CartItem item) async {
    item.quantity++;
    await _saveCart();
    notifyListeners();
  }

  Future<void> decreaseQuantity(CartItem item) async {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _cartItems.remove(item);
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeItems(List<CartItem> items) async {
    _cartItems.removeWhere((item) => items.contains(item));
    await _saveCart();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCart();
    notifyListeners();
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