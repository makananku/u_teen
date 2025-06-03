import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  String? _userEmail;

  List<CartItem> get cartItems => _cartItems;

  int get totalItems =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  Map<String, List<CartItem>> get groupedItems {
    final Map<String, List<CartItem>> grouped = {};
    for (var item in _cartItems) {
      final subtitle = item.subtitle.isNotEmpty ? item.subtitle : 'Unknown';
      if (!grouped.containsKey(subtitle)) {
        grouped[subtitle] = [];
      }
      grouped[subtitle]!.add(item);
    }
    return grouped;
  }

  Future<void> initialize(String userEmail) async {
    debugPrint('CartProvider: Initializing for user: $userEmail');
    if (userEmail.isEmpty) {
      debugPrint('CartProvider: Warning: userEmail is empty');
    }
    _userEmail = userEmail;
    await _loadCart();
  }

  Future<void> _loadCart() async {
    if (_userEmail == null) {
      debugPrint('CartProvider: Cannot load cart: userEmail is null');
      return;
    }
    try {
      debugPrint('CartProvider: Loading cart for $_userEmail');
      final doc = await FirebaseFirestore.instance
          .collection('cart')
          .doc(_userEmail)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['items'] != null) {
          _cartItems = (data['items'] as List)
              .map((item) => CartItem.fromMap(item))
              .toList();
          debugPrint('CartProvider: Loaded ${_cartItems.length} items');
        } else {
          _cartItems = [];
          debugPrint('CartProvider: No items found in cart');
        }
      } else {
        _cartItems = [];
        debugPrint('CartProvider: Cart document does not exist');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('CartProvider: Error loading cart: $e');
    }
  }

  Future<void> addToCart(CartItem item) async {
    int? newItemIndex;
    try {
      debugPrint(
          'CartProvider: Adding to cart: ${item.name}, imgbase64 length: ${item.imgBase64.length}');
      if (item.name.isEmpty || item.sellerEmail.isEmpty) {
        throw Exception('Invalid cart item: name or sellerEmail is empty');
      }
      if (_userEmail == null) {
        debugPrint('CartProvider: Cannot add to cart: userEmail is null');
        throw Exception('User email not set');
      }
      final existingItemIndex = _cartItems.indexWhere(
        (i) => i.name == item.name && i.subtitle == item.subtitle,
      );
      if (existingItemIndex != -1) {
        _cartItems[existingItemIndex].quantity++;
        debugPrint('CartProvider: Incremented quantity for ${item.name}');
      } else {
        _cartItems.add(item);
        newItemIndex = _cartItems.length - 1;
        debugPrint('CartProvider: Added new item: ${item.name}');
      }
      await _saveCart();
      await Future.delayed(const Duration(milliseconds: 250));
      debugPrint('CartProvider: Notifying listeners after cart update');
      notifyListeners();
    } catch (e) {
      // Rollback perubahan lokal
      final existingItemIndex = _cartItems.indexWhere(
        (i) => i.name == item.name && i.subtitle == item.subtitle,
      );
      if (existingItemIndex != -1) {
        _cartItems[existingItemIndex].quantity--;
        if (_cartItems[existingItemIndex].quantity == 0) {
          _cartItems.removeAt(existingItemIndex);
        }
        debugPrint('CartProvider: Rolled back quantity for ${item.name}');
      } else if (newItemIndex != null) {
        _cartItems.removeAt(newItemIndex);
        debugPrint('CartProvider: Removed new item: ${item.name}');
      }
      debugPrint('CartProvider: Error adding to cart: $e');
      throw e;
    }
  }

  Future<void> _saveCart() async {
    if (_userEmail == null) {
      debugPrint('CartProvider: Cannot save cart: userEmail is null');
      throw Exception('User email not set');
    }
    try {
      debugPrint(
          'CartProvider: Saving ${_cartItems.length} items to Firestore for $_userEmail');
      final cartData = {
        'items': _cartItems.map((item) => item.toMap()).toList(),
      };
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(_userEmail)
          .set(cartData, SetOptions(merge: false))
          .timeout(const Duration(seconds: 3), onTimeout: () {
        debugPrint('CartProvider: Firestore save timeout for $_userEmail');
        throw Exception('Firestore save timeout');
      });
      debugPrint('CartProvider: Cart saved successfully for $_userEmail');
    } catch (e) {
      debugPrint('CartProvider: Error saving cart: $e');
      throw Exception('Failed to save cart: $e');
    }
  }

  void removeFromCart(CartItem item) {
    final existingItemIndex = _cartItems.indexWhere(
      (i) => i.name == item.name && i.subtitle == item.subtitle,
    );
    if (existingItemIndex != -1) {
      _cartItems.removeAt(existingItemIndex);
      _saveCart();
      notifyListeners();
    }
  }

  void increaseQuantity(CartItem item) {
    final existingItemIndex = _cartItems.indexWhere(
      (i) => i.name == item.name && i.subtitle == item.subtitle,
    );
    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].quantity++;
      _saveCart();
      notifyListeners();
    }
  }

  void decreaseQuantity(CartItem item) {
    final existingItemIndex = _cartItems.indexWhere(
      (i) => i.name == item.name && i.subtitle == item.subtitle,
    );
    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].quantity--;
      if (_cartItems[existingItemIndex].quantity == 0) {
        _cartItems.removeAt(existingItemIndex);
      }
      _saveCart();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    await _saveCart();
    notifyListeners();
  }
}