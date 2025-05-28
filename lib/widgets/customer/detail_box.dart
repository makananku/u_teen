import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';
import '../../models/favorite_item.dart';

class DetailBox extends StatelessWidget {
  final String selectedFoodItem;
  final String selectedFoodPrice;
  final String selectedFoodImgUrl;
  final String selectedFoodSubtitle;
  final VoidCallback onClose;

  const DetailBox({
    Key? key,
    required this.selectedFoodItem,
    required this.selectedFoodPrice,
    required this.selectedFoodImgUrl,
    required this.selectedFoodSubtitle,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final isFavorite = favoriteProvider.favoriteItems.any((item) =>
        item.name == selectedFoodItem && item.image == selectedFoodImgUrl);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCard(isDarkMode),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getPrimaryText(isDarkMode).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onClose,
              child: Center(
                child: Container(
                  width: 60,
                  height: 5,
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.getDivider(isDarkMode),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.getPrimaryText(isDarkMode)
                                    .withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              selectedFoodImgUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppTheme.getPrimaryText(isDarkMode)
                                      .withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Text(
                            selectedFoodPrice,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.getPrimaryText(!isDarkMode),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      selectedFoodItem,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: AppTheme.getPrimaryText(isDarkMode),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedFoodSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.getSecondaryText(isDarkMode),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final price = int.tryParse(selectedFoodPrice.replaceAll('Rp ', '').replaceAll('.', '')) ?? 0;
                        cartProvider.addToCart(CartItem(
                          name: selectedFoodItem,
                          price: price,
                          image: selectedFoodImgUrl,
                          subtitle: selectedFoodSubtitle,
                          sellerEmail: 'masakan.minang@example.com',
                        ));
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                        backgroundColor: AppTheme.getButton(isDarkMode),
                        foregroundColor: AppTheme.getPrimaryText(!isDarkMode),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: InkWell(
                        onTap: () {
                          if (isFavorite) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '$selectedFoodItem is already in favorites',
                                  style: TextStyle(
                                    color: AppTheme.getPrimaryText(!isDarkMode),
                                  ),
                                ),
                                backgroundColor: AppTheme.getSnackBarInfo(isDarkMode),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } else {
                            favoriteProvider.addToFavorites(FavoriteItem(
                              name: selectedFoodItem,
                              price: selectedFoodPrice,
                              image: selectedFoodImgUrl,
                              subtitle: selectedFoodSubtitle,
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '$selectedFoodItem added to favorites!',
                                  style: TextStyle(
                                    color: AppTheme.getPrimaryText(!isDarkMode),
                                  ),
                                ),
                                backgroundColor: AppTheme.getSnackBarInfo(isDarkMode),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? AppTheme.getSnackBarError(isDarkMode)
                                    .withOpacity(0.1)
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isFavorite
                                  ? AppTheme.getSnackBarError(isDarkMode)
                                      .withOpacity(0.3)
                                  : AppTheme.getDivider(isDarkMode),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color: isFavorite
                                    ? AppTheme.getSnackBarError(isDarkMode)
                                    : AppTheme.getSecondaryText(isDarkMode),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isFavorite
                                    ? 'Saved to favorites'
                                    : 'Save to favorites',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isFavorite
                                      ? AppTheme.getSnackBarError(isDarkMode)
                                      : AppTheme.getSecondaryText(isDarkMode),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}