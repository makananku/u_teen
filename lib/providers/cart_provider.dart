import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void addToCart(CartItem item) {
    final existingItemIndex = _cartItems.indexWhere(
      (i) => i.name == item.name && i.subtitle == item.subtitle,
    );
    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].quantity++;
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  void increaseQuantity(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _cartItems.remove(item);
    }
    notifyListeners();
  }

  void removeItems(List<CartItem> items) {
    _cartItems.removeWhere((item) => items.contains(item));
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
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
