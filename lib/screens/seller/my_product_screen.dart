import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/screens/seller/edit_product_screen.dart';
import 'package:u_teen/providers/food_provider.dart';
import 'package:u_teen/auth/auth_provider.dart';
import 'package:u_teen/screens/seller/home_screen.dart';
import 'package:u_teen/widgets/seller/custom_bottom_navigation.dart';
import 'package:u_teen/widgets/seller/product_card.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';

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
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      foodProvider.clearProducts(); // Bersihkan produk sebelumnya
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tenantName = authProvider.tenantName;
      foodProvider.loadProducts(context, tenantName: tenantName); // Muat produk dengan filter tenantName
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
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
          backgroundColor: AppTheme.getBackground(isDarkMode),
          appBar: AppBar(
            title: Text(
              'My Product',
              style: TextStyle(
                color: AppTheme.getPrimaryText(isDarkMode),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppTheme.getCard(isDarkMode),
            elevation: 0.5,
            iconTheme: IconThemeData(color: AppTheme.getPrimaryText(isDarkMode)),
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: AppTheme.getPrimaryText(isDarkMode)),
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
  }

  Widget _buildContent(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final foodProvider = Provider.of<FoodProvider>(context);
    final currentTenantName = authProvider.tenantName ?? '';
    final currentSellerEmail = authProvider.user?.email ?? '';
    final sellerProducts = foodProvider.getProductsBySeller(currentSellerEmail)
        .where((product) => product.tenantName == currentTenantName)
        .toList();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (foodProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.getPrimaryText(isDarkMode)),
        ),
      );
    }

    if (sellerProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No products found. Add your first product!',
              style: TextStyle(
                color: AppTheme.getSecondaryText(isDarkMode),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            if (foodProvider.hasMore) // Tambah tombol untuk muat lebih banyak
              ElevatedButton(
                onPressed: () {
                  final foodProvider = Provider.of<FoodProvider>(context, listen: false);
                  foodProvider.loadMoreProducts(context, tenantName: currentTenantName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getPrimaryText(isDarkMode),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Load More',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: sellerProducts.length + (foodProvider.hasMore ? 1 : 0), // Tambah 1 untuk "Load More"
      itemBuilder: (context, index) {
        if (index == sellerProducts.length && foodProvider.hasMore) {
          // Item terakhir adalah tombol "Load More"
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  final foodProvider = Provider.of<FoodProvider>(context, listen: false);
                  foodProvider.loadMoreProducts(context, tenantName: currentTenantName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getPrimaryText(isDarkMode),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Load More',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }

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
          onDelete: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Product'),
                content: const Text('Are you sure you want to delete this product?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );

            if (confirm != true) return;

            try {
              await foodProvider.removeProduct(product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Product deleted successfully'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: AppTheme.getSnackBarSuccess(isDarkMode),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete product: $e'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                ),
              );
            }
          },
          onToggleStatus: () async {
            try {
              await foodProvider.toggleProductStatus(product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Product status updated to ${product.isActive ? 'inactive' : 'active'}'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: AppTheme.getSnackBarSuccess(isDarkMode),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to toggle product status: $e'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                ),
              );
            }
          },
        );
      },
    );
  }
}