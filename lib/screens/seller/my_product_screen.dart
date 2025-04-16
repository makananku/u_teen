import 'package:flutter/material.dart';
import 'package:u_teen/screens/seller/edit_product_screen.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/providers/food_provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/screens/seller/home_screen.dart';
import 'package:u_teen/widgets/seller/seller_custom_bottom_navigation.dart';
import 'package:u_teen/models/product_model.dart';

class SellerMyProductScreen extends StatefulWidget {
  const SellerMyProductScreen({super.key});

  @override
  State<SellerMyProductScreen> createState() => _SellerMyProductScreenState();
}

class _SellerMyProductScreenState extends State<SellerMyProductScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoodProvider>(context, listen: false).loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final foodProvider = Provider.of<FoodProvider>(context);
    final currentSellerEmail = authProvider.user?.email;
    final sellerProducts = foodProvider.getProductsBySeller(currentSellerEmail ?? '');

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Background scaffold putih
        appBar: AppBar(
          title: const Text('My Products', 
              style: TextStyle(color: Colors.black87)), // Text hitam
          backgroundColor: Colors.white, // AppBar putih
          elevation: 0.5, // Sedikit shadow untuk delineasi
          iconTheme: const IconThemeData(color: Colors.black87), // Icon hitam
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SellerEditProductScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // Background putih sudah di Scaffold
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: _buildContent(foodProvider, sellerProducts),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SellerCustomBottomNavigation(
                selectedIndex: NavIndices.products,
                context: context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(FoodProvider foodProvider, List<Product> sellerProducts) {
    if (foodProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
        ),
      );
    }

    if (sellerProducts.isEmpty) {
      return Center(
        child: Text(
          'No products found. Add your first product!',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: sellerProducts.length,
      itemBuilder: (context, index) {
        final product = sellerProducts[index];
        return _ProductCard(
          product: product,
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SellerEditProductScreen(
                  product: product,
                ),
              ),
            );
          },
          onDelete: () {
            foodProvider.removeProduct(product.id);
          },
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  product.imgUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp${product.price}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Buttons
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, 
                      color: Colors.blue.shade600),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, 
                      color: Colors.red.shade600),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}