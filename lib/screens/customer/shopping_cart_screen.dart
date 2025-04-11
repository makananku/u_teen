import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';
import 'home_screen.dart';
import 'payment_screen.dart'; // Import the payment screen
import '../../widgets/custom_bottom_navigation.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> 
    with SingleTickerProviderStateMixin {
  late final AnimationController _emptyCartController;
  late final Animation<double> _emptyCartAnimation;

  @override
  void initState() {
    super.initState();
    _emptyCartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _emptyCartAnimation = CurvedAnimation(
      parent: _emptyCartController,
      curve: Curves.elasticOut,
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
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(context),
            body: _buildBody(context),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

  AppBar _buildAppBar(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    
    return AppBar(
      title: const Text(
        "My Cart",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        ),
      ),
      actions: [
        if (cartProvider.cartItems.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black),
            onPressed: () => _showClearCartDialog(context),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: cartProvider.cartItems.isEmpty
            ? _buildEmptyCartView()
            : _buildCartItemsList(cartProvider),
      ),
    );
  }

  Widget _buildEmptyCartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animation/empty_cart.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            repeat: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Column(
              children: [
                Text(
                  "Your Shopping Cart is Empty",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "It looks like you haven't added any delicious food yet. "
                  "Let's fill it up with tasty meals!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          ScaleTransition(
            scale: _emptyCartAnimation,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                elevation: 5,
              ),
              icon: const Icon(Icons.restaurant, color: Colors.white),
              label: const Text(
                "Browse Foods",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(CartProvider cartProvider) {
    return ListView(
      children: [
        ..._buildGroupedCartItems(cartProvider.groupedItems),
        const SizedBox(height: 100),
      ],
    );
  }

  List<Widget> _buildGroupedCartItems(Map<String, List<CartItem>> groupedItems) {
    return groupedItems.entries.map((entry) {
      final subtitle = entry.key;
      final items = entry.value;
      final totalPrice = items.fold(
        0, (sum, item) => sum + (item.price * item.quantity),
      );

      return Column(
        children: [
          _buildMerchantHeader(subtitle),
          ...items.map((item) => CartItemTile(item: item)),
          _buildCheckoutButton(items, totalPrice),
          const Divider(height: 20, thickness: 1, color: Colors.grey),
        ],
      );
    }).toList();
  }

  Widget _buildMerchantHeader(String subtitle) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8), // Changed to left-only padding
      child: Align(
        alignment: Alignment.centerLeft, // Align text to left
        child: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutButton(List<CartItem> items, int totalPrice) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () => _navigateToPayment(items, totalPrice), // Changed to navigation
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.blue,
        ),
        child: Text(
          'Buy Now (${items.length} items) - Rp$totalPrice',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _navigateToPayment(List<CartItem> items, int totalPrice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          items: items,
          totalPrice: totalPrice,
        ),
      ),
    );
  }

  void _processCheckout(List<CartItem> items) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.removeItems(items);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Successfully checked out ${items.length} items from ${items.first.subtitle}',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear cart?"),
        content: const Text("Are you sure you want to remove all items from your cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                  content: Text('Cart cleared!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: const Text(
              "Clear",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Dismissible(
      key: Key('${item.name}_${item.subtitle}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissibleBackground(),
      confirmDismiss: (direction) => _confirmDismiss(context),
      onDismissed: (direction) => _handleDismissed(context),
      child: Container(
        color: Colors.white,
        child: ListTile(
          leading: _buildItemImage(),
          title: Text(item.name, style: const TextStyle(color: Colors.black)),
          subtitle: Text(
            'Rp${item.price} x ${item.quantity}',
            style: const TextStyle(color: Colors.black54),
          ),
          trailing: _buildQuantityControls(cartProvider),
        ),
      ),
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
      color: Colors.red[100],
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete, color: Colors.red),
    );
  }

  Future<bool?> _confirmDismiss(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove from cart?"),
        content: Text("Are you sure you want to remove ${item.name} from your cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              "Remove",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDismissed(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.removeFromCart(item);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${item.name} from cart'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildItemImage() {
    return Hero(
      tag: 'cart_${item.name}_${item.subtitle}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          item.image,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildQuantityControls(CartProvider cartProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.blue),
          onPressed: () => cartProvider.decreaseQuantity(item),
        ),
        Text(item.quantity.toString(), 
            style: const TextStyle(color: Colors.black)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
          onPressed: () => cartProvider.increaseQuantity(item),
        ),
      ],
    );
  }
}