import 'package:flutter/material.dart';
import 'package:u_teen/screens/seller/edit_product_screen.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/providers/food_provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/screens/seller/home_screen.dart';
import 'package:u_teen/widgets/seller/seller_custom_bottom_navigation.dart';
import 'package:u_teen/models/product_model.dart';
import 'package:u_teen/widgets/seller/product_card.dart'; // Import the new card

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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('My Products', 
              style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black87),
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
        return ProductCard(
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
          onToggleStatus: () {
            foodProvider.toggleProductStatus(product.id);
          },
        );
      },
    );
  }
}