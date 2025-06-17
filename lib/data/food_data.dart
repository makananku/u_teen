import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class FoodData {
  static Future<void> initializeData() async {
    final firestore = FirebaseFirestore.instance;

    // Check if products already exist
    final productsSnapshot = await firestore.collection('products').get();
    if (productsSnapshot.docs.isNotEmpty) {
      debugPrint('Products already exist, skipping initialization.');
      return;
    }

    final products = [
      Product(
        id: 'product1',
        title: 'Soto Ayam',
        subtitle: 'Masakan Minang',
        time: '8 mins',
        imgBase64: '',
        price: '20000',
        sellerEmail: '456@seller.umn.ac.id',
        tenantName: 'Masakan Minang',
        category: 'Food', 
        isActive: true,
      ),
      Product(
        id: 'product2',
        title: 'Nasi Pecel',
        subtitle: 'Masakan Minang',
        time: '5 mins',
        imgBase64: '',
        price: '15000',
        sellerEmail: '456@seller.umn.ac.id',
        tenantName: 'Masakan Minang',
        category: 'Food', 
        isActive: true,
      ),
      Product(
        id: 'product3',
        title: 'Bakso',
        subtitle: 'Bakso 88',
        time: '15 mins',
        imgBase64: '',
        price: '20000',
        sellerEmail: 'seller@example.com',
        tenantName: 'Bakso 88',
        category: 'Food',
        isActive: true,
      ),
      Product(
        id: 'product4',
        title: 'Mie Ayam',
        subtitle: 'Mie Ayam Enak',
        time: '3 mins',
        imgBase64: '',
        price: '20000',
        sellerEmail: 'seller@example.com',
        tenantName: 'Mie Ayam Enak',
        category: 'Food',
        isActive: true,
      ),
      Product(
        id: 'product5',
        title: 'Matcha Latte',
        subtitle: 'KopiKu',
        time: '10 mins',
        imgBase64: '',
        price: '25000',
        sellerEmail: 'seller@example.com',
        tenantName: 'KopiKu',
        category: 'Drink', 
        isActive: true,
      ),
      Product(
        id: 'product6',
        title: 'Cappucino',
        subtitle: 'KopiKu',
        time: '6 mins',
        imgBase64: '',
        price: '8000',
        sellerEmail: 'seller@example.com',
        tenantName: 'KopiKu',
        category: 'Drink', 
        isActive: true,
      ),
      Product(
        id: 'product7',
        title: 'Burger',
        subtitle: 'Aneka Makanan',
        time: '10 mins',
        imgBase64: '',
        price: '30000',
        sellerEmail: 'seller@example.com',
        tenantName: 'Aneka Makanan',
        category: 'Snack', 
        isActive: true,
      ),
      Product(
        id: 'product8',
        title: 'Kentang Goreng',
        subtitle: 'Fast Food Restaurant',
        time: '3 mins',
        imgBase64: '',
        price: '12000',
        sellerEmail: 'seller@example.com',
        tenantName: 'Fast Food Restaurant',
        category: 'Snack', 
        isActive: true,
      ),
    ];

    for (var product in products) {
      await firestore
          .collection('products')
          .doc(product.id)
          .set(product.toMap(), SetOptions(merge: true));
    }
    debugPrint('Product initialization completed.');
  }

  static Future<List<Product>> getFoodItems(String category) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();
      List<Product> products = snapshot.docs
          .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      if (category != 'All') {
        products = products.where((p) => p.category == category).toList();
      }
      return products;
    } catch (e) {
      debugPrint('Error loading food items: $e');
      return [];
    }
  }
}