import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:u_teen/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:u_teen/auth/auth_provider.dart';

class FoodProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  int _currentPage = 0;
  static const int _pageSize = 10; // Batas produk per muat
  bool _hasMore = true;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FoodProvider() {
    debugPrint('FoodProvider initialized');
  }

  // Memuat data awal dengan pagination dan filter tenantName
  Future<void> loadProducts(BuildContext context, {String category = 'All', String? tenantName}) async {
    if (_isLoading || !_hasMore) return;

    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('Loading products for category: $category, tenantName: $tenantName, page: $_currentPage');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      String? sellerEmail = authProvider.sellerEmail;

      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .orderBy('title') // Tambahkan urutan untuk konsistensi
          .limit(_pageSize * (_currentPage + 1))
          .get();

      final newProducts = querySnapshot.docs.map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>)).toList();
      debugPrint('Fetched ${newProducts.length} products from Firestore');

      // Filter berdasarkan tenantName
      if (tenantName != null && tenantName.isNotEmpty) {
        newProducts.removeWhere((product) => product.tenantName != tenantName);
        debugPrint('Filtered by tenantName: $tenantName, remaining: ${newProducts.length}');
      }

      // Filter berdasarkan sellerEmail jika ada
      if (sellerEmail != null && sellerEmail.isNotEmpty) {
        newProducts.removeWhere((product) => product.sellerEmail != sellerEmail);
        debugPrint('Filtered by sellerEmail: $sellerEmail, remaining: ${newProducts.length}');
      }

      // Filter berdasarkan category
      if (category != 'All') {
        newProducts.removeWhere((product) => product.category != category);
        debugPrint('Filtered by category: $category, remaining: ${newProducts.length}');
      }

      // Cek apakah ada data baru
      if (newProducts.length < _pageSize * (_currentPage + 1)) {
        _hasMore = false;
        debugPrint('No more products to load');
      } else {
        _currentPage++;
        debugPrint('Incremented page to: $_currentPage');
      }

      _products = [..._products, ...newProducts.where((p) => !_products.contains(p))];
      _isLoading = false;
      notifyListeners();
      debugPrint('Products updated, total: ${_products.length}');
    } catch (e) {
      debugPrint('Error loading products: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Muat lebih banyak produk dengan filter tenantName
  Future<void> loadMoreProducts(BuildContext context, {String category = 'All', String? tenantName}) async {
    debugPrint('Loading more products for category: $category, tenantName: $tenantName');
    await loadProducts(context, category: category, tenantName: tenantName);
  }

  // Filter produk dengan kategori dan tenantName
  Future<void> filterProducts(BuildContext context, String category, String? tenantName) async {
    debugPrint('Filtering products by category: $category, tenantName: $tenantName');
    _currentPage = 0; // Reset halaman saat filter
    _products = [];
    _hasMore = true;
    await loadProducts(context, category: category, tenantName: tenantName);
  }

  // Ambil produk berdasarkan seller
  List<Product> getProductsBySeller(String sellerEmail) {
    if (sellerEmail.isEmpty) {
      debugPrint('Seller email is empty, returning empty list');
      return [];
    }
    final sellerProducts = _products.where((product) => product.sellerEmail == sellerEmail).toList();
    debugPrint('Found ${sellerProducts.length} products for seller: $sellerEmail');
    return sellerProducts;
  }

  // Tambah produk baru
  Future<void> addProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('Adding new product: ${product.title}');

      await _firestore.collection('products').doc(product.id).set(product.toMap());
      _products.add(product);
      _isLoading = false;
      notifyListeners();
      debugPrint('Product added successfully: ${product.id}');
    } catch (e) {
      debugPrint('Error adding product: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update produk
  Future<void> updateProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('Updating product: ${product.id}');

      await _firestore.collection('products').doc(product.id).update(product.toMap());
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        debugPrint('Product updated in local list at index: $index');
      } else {
        debugPrint('Product not found in local list');
      }
      _isLoading = false;
      notifyListeners();
      debugPrint('Product updated successfully: ${product.id}');
    } catch (e) {
      debugPrint('Error updating product: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Hapus produk
  Future<void> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('Deleting product: $productId');

      await _firestore.collection('products').doc(productId).delete();
      _products.removeWhere((p) => p.id == productId);
      _isLoading = false;
      notifyListeners();
      debugPrint('Product deleted successfully: $productId');
    } catch (e) {
      debugPrint('Error deleting product: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Alias untuk deleteProduct
  Future<void> removeProduct(String productId) async {
    debugPrint('Removing product (alias for delete): $productId');
    await deleteProduct(productId);
  }

  // Toggle status produk
  Future<void> toggleProductStatus(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();
      debugPrint('Toggling status for product: $productId');

      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) {
        debugPrint('Product not found in local list: $productId');
        return;
      }

      final product = _products[index];
      final newStatus = !product.isActive;

      await _firestore.collection('products').doc(productId).update({
        'isActive': newStatus,
      });

      _products[index] = product.copyWith(isActive: newStatus);
      _isLoading = false;
      notifyListeners();
      debugPrint('Product status toggled to: $newStatus for $productId');
    } catch (e) {
      debugPrint('Error toggling product status: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Bersihkan produk
  void clearProducts() {
    debugPrint('Clearing all products');
    _products = [];
    _currentPage = 0;
    _hasMore = true;
    _isLoading = false;
    notifyListeners();
    debugPrint('Products cleared');
  }
}