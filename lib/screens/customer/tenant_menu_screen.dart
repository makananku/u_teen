import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import '../../models/product_model.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../widgets/customer/detail_box.dart';

class TenantMenuScreen extends StatefulWidget {
  final String tenantName;
  final String sellerEmail;

  const TenantMenuScreen({
    Key? key,
    required this.tenantName,
    required this.sellerEmail,
  }) : super(key: key);

  @override
  _TenantMenuScreenState createState() => _TenantMenuScreenState();
}

class _TenantMenuScreenState extends State<TenantMenuScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool isDetailVisible = false;
  String selectedFoodItem = '';
  String selectedFoodPrice = '';
  String selectedFoodImgBase64 = '';
  String selectedFoodSubtitle = '';
  String selectedSellerEmail = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _handleFoodItemTap(
    String title,
    String price,
    String imgBase64,
    String subtitle,
    String sellerEmail,
  ) {
    setState(() {
      selectedFoodItem = title;
      selectedFoodPrice = price;
      selectedFoodImgBase64 = imgBase64;
      selectedFoodSubtitle = subtitle;
      selectedSellerEmail = sellerEmail;
      isDetailVisible = true;
    });
  }

  void _closeDetailBox() {
    setState(() {
      isDetailVisible = false;
    });
  }

  Uint8List _decodeBase64(String base64String) {
    try {
      final String cleanedBase64 = base64String.startsWith('data:image')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(cleanedBase64);
    } catch (e) {
      debugPrint('TenantMenuScreen: Error decoding Base64 for $base64String: $e');
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.getBackground(isDarkMode),
      appBar: AppBar(
        title: Text(
          widget.tenantName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.getCard(isDarkMode),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.getPrimaryText(isDarkMode),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('isActive', isEqualTo: true)
                  .where('tenantName', isEqualTo: widget.tenantName)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.getAccentPurple(isDarkMode),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading menu',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.getSecondaryText(isDarkMode),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fastfood_rounded,
                          size: 48,
                          color: AppTheme.getSecondaryText(isDarkMode),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No menu items available',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.getSecondaryText(isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data!.docs
                    .map((doc) => Product.fromFirestore(doc))
                    .toList();

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8, // Slightly taller cards
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return MenuItemCard(
                        product: product,
                        onTap: () => _handleFoodItemTap(
                          product.title,
                          product.price,
                          product.imgBase64,
                          product.subtitle,
                          product.sellerEmail,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (isDetailVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeDetailBox,
                child: Container(
                  color: AppTheme.getPrimaryText(isDarkMode).withOpacity(0.4),
                ),
              ),
            ),
          if (isDetailVisible)
            DetailBox(
              selectedFoodItem: selectedFoodItem,
              selectedFoodPrice: selectedFoodPrice,
              selectedFoodImgBase64: selectedFoodImgBase64,
              selectedFoodSubtitle: selectedFoodSubtitle,
              sellerEmail: selectedSellerEmail,
              onClose: _closeDetailBox,
            ),
        ],
      ),
    );
  }
}

class MenuItemCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const MenuItemCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  _MenuItemCardState createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutQuad,
    ));
    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 6.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutQuad,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isHovered = false);
    _hoverController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  Uint8List _decodeBase64(String base64String) {
    try {
      final String cleanedBase64 = base64String.startsWith('data:image')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(cleanedBase64);
    } catch (e) {
      debugPrint('MenuItemCard: Error decoding Base64 for ${widget.product.title}: $e');
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _elevationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppTheme.getCard(isDarkMode),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getShadow(isDarkMode).withOpacity(0.2 * _elevationAnimation.value/6),
                    blurRadius: 8 * _elevationAnimation.value/2,
                    spreadRadius: 1 * _elevationAnimation.value/3,
                    offset: Offset(0, 3 * _elevationAnimation.value/3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Stack(
                      children: [
                        widget.product.imgBase64.isNotEmpty
                            ? Image.memory(
                                _decodeBase64(widget.product.imgBase64),
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.getOrderButtonBackground(isDarkMode),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: AppTheme.getOrderButtonIcon(isDarkMode),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Food details
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getPrimaryText(isDarkMode),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.getSecondaryText(isDarkMode),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rp ${widget.product.price}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getAccentPurple(isDarkMode),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    return Container(
      height: 120,
      color: AppTheme.getDivider(isDarkMode),
      child: Center(
        child: Icon(
          Icons.fastfood_rounded,
          size: 40,
          color: AppTheme.getPrimaryText(isDarkMode).withOpacity(0.3),
        ),
      ),
    );
  }
}