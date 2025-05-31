import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';
import '../../models/favorite_item.dart';
import 'dart:convert';
import 'dart:typed_data';

class DetailBox extends StatefulWidget {
  final String selectedFoodItem;
  final String selectedFoodPrice;
  final String selectedFoodImgBase64;
  final String selectedFoodSubtitle;
  final String sellerEmail;
  final VoidCallback onClose;

  const DetailBox({
    Key? key,
    required this.selectedFoodItem,
    required this.selectedFoodPrice,
    required this.selectedFoodImgBase64,
    required this.selectedFoodSubtitle,
    required this.sellerEmail,
    required this.onClose,
  }) : super(key: key);

  @override
  _DetailBoxState createState() => _DetailBoxState();
}

class _DetailBoxState extends State<DetailBox> {
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final cleanPrice = widget.selectedFoodPrice.replaceAll(RegExp(r'[^0-9]'), '');
    final isFavorite = favoriteProvider.isFavorite(FavoriteItem(
      name: widget.selectedFoodItem,
      price: cleanPrice,
      imgBase64: widget.selectedFoodImgBase64,
      subtitle: widget.selectedFoodSubtitle,
    ));

    debugPrint('DetailBox: Rendering ${widget.selectedFoodItem}, imgBase64 length: ${widget.selectedFoodImgBase64.length}');

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
              onTap: () {
                debugPrint('DetailBox: Closing via onClose');
                widget.onClose();
              },
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
                            child: widget.selectedFoodImgBase64.isNotEmpty
                                ? Image.memory(
                                    _decodeBase64(widget.selectedFoodImgBase64),
                                    height: 220,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      debugPrint('Error loading Base64 image for ${widget.selectedFoodItem}');
                                      return Container(
                                        height: 220,
                                        width: double.infinity,
                                        color: AppTheme.getDivider(isDarkMode),
                                        child: Icon(
                                          Icons.fastfood,
                                          size: 60,
                                          color: AppTheme.getPrimaryText(isDarkMode),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    height: 220,
                                    width: double.infinity,
                                    color: AppTheme.getDivider(isDarkMode),
                                    child: Icon(
                                      Icons.fastfood,
                                      size: 60,
                                      color: AppTheme.getPrimaryText(isDarkMode),
                                    ),
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
                            widget.selectedFoodPrice,
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
                      widget.selectedFoodItem,
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
                      widget.selectedFoodSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.getSecondaryText(isDarkMode),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isAddingToCart
                          ? null
                          : () async {
                              debugPrint('DetailBox: Add to Cart button pressed for ${widget.selectedFoodItem}');
                              setState(() {
                                _isAddingToCart = true;
                              });
                              try {
                                final price = int.tryParse(cleanPrice) ?? 0;
                                if (widget.selectedFoodImgBase64.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Cannot add item: No image data'),
                                      backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                                    ),
                                  );
                                  return;
                                }
                                await cartProvider.addToCart(CartItem(
                                  name: widget.selectedFoodItem,
                                  price: price,
                                  imgbase64: widget.selectedFoodImgBase64,
                                  subtitle: widget.selectedFoodSubtitle,
                                  sellerEmail: widget.sellerEmail,
                                ));
                                debugPrint('DetailBox: Added to cart: ${widget.selectedFoodItem}, imgBase64 length: ${widget.selectedFoodImgBase64.length}');
                                // Increased delay to ensure rendering stability
                                await Future.delayed(const Duration(milliseconds: 200));
                                if (context.mounted) {
                                  debugPrint('DetailBox: Popping context for ${widget.selectedFoodItem}');
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                debugPrint('DetailBox: Error adding to cart: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to add item to cart: $e'),
                                      backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isAddingToCart = false;
                                  });
                                }
                              }
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
                      child: _isAddingToCart
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.getPrimaryText(!isDarkMode),
                              ),
                            )
                          : const Text(
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
                        onTap: () async {
                          final favoriteItem = FavoriteItem(
                            name: widget.selectedFoodItem,
                            price: cleanPrice,
                            imgBase64: widget.selectedFoodImgBase64,
                            subtitle: widget.selectedFoodSubtitle,
                          );
                          if (isFavorite) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.selectedFoodItem} is already in favorites',
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
                            try {
                              await favoriteProvider.addToFavorites(favoriteItem);
                              debugPrint('DetailBox: Added to favorites: ${favoriteItem.name}, imgBase64 length: ${favoriteItem.imgBase64.length}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${widget.selectedFoodItem} added to favorites!',
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
                            } catch (e) {
                              debugPrint('DetailBox: Error adding to favorites: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to add ${widget.selectedFoodItem} to favorites',
                                    style: TextStyle(
                                      color: AppTheme.getPrimaryText(!isDarkMode),
                                    ),
                                  ),
                                  backgroundColor: AppTheme.getSnackBarError(isDarkMode),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
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

  Uint8List _decodeBase64(String base64String) {
    try {
      final String cleanedBase64 = base64String.startsWith('data:image')
          ? base64String.split(',').last
          : base64String;
      debugPrint('DetailBox: Decoding Base64 for ${widget.selectedFoodItem}, length: ${cleanedBase64.length}');
      return base64Decode(cleanedBase64);
    } catch (e) {
      debugPrint('DetailBox: Error decoding Base64 for ${widget.selectedFoodItem}: $e');
      return Uint8List(0); // Trigger errorBuilder
    }
  }
}