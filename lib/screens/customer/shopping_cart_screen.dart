import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'home_screen.dart';
import 'payment_screen.dart';
import '../../widgets/customer/custom_bottom_navigation.dart';
import 'dart:convert';
import 'dart:typed_data';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _emptyCartController;

  @override
  void initState() {
    super.initState();
    _emptyCartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _emptyCartController.forward();
  }

  @override
  void dispose() {
    _emptyCartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Scaffold(
            backgroundColor: AppTheme.getDetailBackground(isDarkMode),
            appBar: _buildAppBar(context, isDarkMode),
            body: _buildBody(context, isDarkMode),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: CustomBottomNavigation(
              selectedIndex: 2,
              context: context,
            ),
          );
        },
      ),
    );
  }

  Future<bool> _handleWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
    return false;
  }

  AppBar _buildAppBar(BuildContext context, bool isDarkMode) {
    final cartProvider = Provider.of<CartProvider>(context);

    return AppBar(
      title: Text(
        'My Cart',
        style: TextStyle(
          color: AppTheme.getPrimaryText(isDarkMode),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppTheme.getCard(isDarkMode),
      elevation: 0,
      actions: [
        if (cartProvider.cartItems.isNotEmpty)
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppTheme.getPrimaryText(isDarkMode)),
            onPressed: () => _showClearCartDialog(context),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, bool isDarkMode) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Column(
      children: [
        if (cartProvider.cartItems.isNotEmpty) _buildSummaryCard(cartProvider, isDarkMode),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
            child: cartProvider.cartItems.isEmpty
                ? _buildEmptyCartView(isDarkMode)
                : _buildCartItemsList(cartProvider, isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(CartProvider cartProvider, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCard(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getPrimaryText(isDarkMode).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Items',
                style: TextStyle(fontSize: 14, color: AppTheme.getSecondaryText(isDarkMode)),
              ),
              Text(
                '${cartProvider.totalItems}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getPrimaryText(isDarkMode),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total Price',
                style: TextStyle(fontSize: 14, color: AppTheme.getSecondaryText(isDarkMode)),
              ),
              Text(
                'Rp${cartProvider.totalPrice}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getButton(isDarkMode),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCartView(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animation/empty_cart.json',
            width: 280,
            height: 280,
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
          ),
          const SizedBox(height: 16),
          Text(
            "Hungry? Let's Fill Your Cart!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextDark(isDarkMode),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Your cart is waiting for delicious food. Start browsing our menu and add your favorites!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getSecondaryText(isDarkMode),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _emptyCartController,
              curve: Curves.elasticOut,
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getAccentBlue(isDarkMode),
                foregroundColor: AppTheme.getPrimaryText(!isDarkMode),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 3,
                shadowColor: AppTheme.getButton(isDarkMode).withOpacity(0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, size: 20, color: AppTheme.getPrimaryText(!isDarkMode)),
                  const SizedBox(width: 8),
                  Text(
                    "Explore Menu",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getPrimaryText(!isDarkMode),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(CartProvider cartProvider, bool isDarkMode) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const SizedBox(height: 8),
        ..._buildGroupedCartItems(cartProvider.groupedItems, isDarkMode),
      ],
    );
  }

  List<Widget> _buildGroupedCartItems(
    Map<String, List<CartItem>> groupedItems,
    bool isDarkMode,
  ) {
    return groupedItems.entries.map((entry) {
      final subtitle = entry.key;
      final items = entry.value;
      final totalPrice = items.fold(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMerchantHeader(subtitle, isDarkMode),
          ...items.map((item) => _buildCartItemCard(item, isDarkMode)),
          _buildCheckoutButton(items, totalPrice, isDarkMode),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget _buildMerchantHeader(String subtitle, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        subtitle,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.getTextMedium(isDarkMode),
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.getCard(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getPrimaryText(isDarkMode).withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Dismissible(
        key: Key('${item.name}_${item.subtitle}'),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: AppTheme.getAccentRedLight(isDarkMode),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: AppTheme.getSnackBarError(isDarkMode)),
        ),
        confirmDismiss: (direction) => _confirmDismiss(item),
        onDismissed: (direction) => _handleDismissed(item),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          leading: Hero(
            tag: 'cart_${item.name}_${item.subtitle}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imgbase64.isNotEmpty
                  ? Image.memory(
                      _decodeBase64(item.imgbase64),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        debugPrint('Error loading Base64 image for ${item.name}');
                        return Container(
                          width: 50,
                          height: 50,
                          color: AppTheme.getDivider(isDarkMode),
                          child: Icon(
                            Icons.fastfood,
                            size: 30,
                            color: AppTheme.getPrimaryText(isDarkMode),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      color: AppTheme.getDivider(isDarkMode),
                      child: Icon(
                        Icons.fastfood,
                        size: 30,
                        color: AppTheme.getPrimaryText(isDarkMode),
                      ),
                    ),
            ),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextMedium(isDarkMode),
            ),
          ),
          subtitle: Text(
            'Rp${item.price}',
            style: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
          ),
          trailing: _buildQuantityControls(item, isDarkMode),
        ),
      ),
    );
  }

  Uint8List _decodeBase64(String base64String) {
    try {
      final String cleanedBase64 = base64String.startsWith('data:image')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(cleanedBase64);
    } catch (e) {
      debugPrint('Error decoding Base64: $e');
      rethrow;
    }
  }

  Future<bool?> _confirmDismiss(CartItem item) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
        return AlertDialog(
          title: Text("Remove from cart?", style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode))),
          content: Text(
            "Are you sure you want to remove ${item.name} from your cart?",
            style: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel", style: TextStyle(color: AppTheme.getTextMedium(isDarkMode))),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Remove",
                style: TextStyle(color: AppTheme.getSnackBarError(isDarkMode)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleDismissed(CartItem item) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.removeFromCart(item);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${item.name} from cart'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildQuantityControls(CartItem item, bool isDarkMode) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getAccentBlueLight(isDarkMode),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove, size: 18, color: AppTheme.getButton(isDarkMode)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => cartProvider.decreaseQuantity(item),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              item.quantity.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getPrimaryText(isDarkMode),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add, size: 18, color: AppTheme.getButton(isDarkMode)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => cartProvider.increaseQuantity(item),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(List<CartItem> items, int totalPrice, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () => _navigateToPayment(items, totalPrice),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: AppTheme.getButton(isDarkMode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood_rounded,
              size: 20,
              color: AppTheme.getPrimaryText(!isDarkMode),
            ),
            const SizedBox(width: 8),
            Text(
              'Checkout (${items.length} items)',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getPrimaryText(!isDarkMode),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              'Rp$totalPrice',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.getPrimaryText(!isDarkMode),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPayment(List<CartItem> items, int totalPrice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(items: items, totalPrice: totalPrice),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear cart?", style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode))),
        content: Text(
          "Are you sure you want to remove all items from your cart?",
          style: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel", style: TextStyle(color: AppTheme.getTextMedium(isDarkMode))),
          ),
          TextButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cart cleared!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: Text(
              "Clear",
              style: TextStyle(color: AppTheme.getSnackBarError(isDarkMode)),
            ),
          ),
        ],
      ),
    );
  }
}