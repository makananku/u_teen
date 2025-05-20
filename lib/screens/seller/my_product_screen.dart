import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/screens/seller/edit_product_screen.dart';
import 'package:u_teen/providers/food_provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/screens/seller/home_screen.dart';
import 'package:u_teen/widgets/seller/custom_bottom_navigation.dart';
import 'package:u_teen/models/product_model.dart';
import 'package:u_teen/widgets/seller/product_card.dart';
import 'package:u_teen/providers/theme_notifier.dart';

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
    return ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          final isDarkMode = themeNotifier.isDarkMode;
          return Theme(
            data: themeNotifier.currentTheme,
            child: WillPopScope(
              onWillPop: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
                );
                return false;
              },
              child: Scaffold(
                backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
                appBar: AppBar(
                  title: Text(
                    'My Product',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  elevation: 0.5,
                  iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black87),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.add, color: isDarkMode ? Colors.white : Colors.black87),
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
                      child: _buildContent(context),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final foodProvider = Provider.of<FoodProvider>(context);
    final currentSellerEmail = authProvider.user?.email;
    final sellerProducts = foodProvider.getProductsBySeller(currentSellerEmail ?? '');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (foodProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.white : Colors.black87),
        ),
      );
    }

    if (sellerProducts.isEmpty) {
      return Center(
        child: Text(
          'No products found. Add your first product!',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey.shade600,
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