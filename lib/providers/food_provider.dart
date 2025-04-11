import 'package:flutter/material.dart';
import 'package:u_teen/models/product_model.dart';
import 'package:u_teen/data/food_data.dart';

class FoodProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    // Convert FoodData to Product models
    final foodItems = FoodData.getFoodItems('All');
    _products =
        foodItems
            .map(
              (item) => Product(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: item['title'] ?? '',
                subtitle: item['subtitle'] ?? '',
                price: item['price'] ?? '',
                time: item['time'] ?? '',
                imgUrl: item['imgUrl'] ?? '',
                sellerEmail: item['sellerEmail'] ?? '',
                String: null,
              ),
            )
            .toList();

    _isLoading = false;
    notifyListeners();
  }

  void clearProducts() {
    _products = [];
    notifyListeners();
  }

  Future<void> addProduct(Product newProduct) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    _products.add(newProduct);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProduct(Product updatedProduct) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _products.removeWhere((p) => p.id == productId);
    _isLoading = false;
    notifyListeners();
  }

  List<Product> getProductsBySeller(String sellerEmail) {
    return _products.where((p) => p.sellerEmail == sellerEmail).toList();
  }
}
