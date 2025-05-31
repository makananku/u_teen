import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import 'dart:convert';

class FoodList extends StatefulWidget {
  final String selectedCategory;
  final Function(String, String, String, String, String) onFoodItemTap;

  const FoodList({
    Key? key,
    required this.selectedCategory,
    required this.onFoodItemTap,
  }) : super(key: key);

  @override
  _FoodListState createState() => _FoodListState();
}

class _FoodListState extends State<FoodList> {
  // Helper method to assign priority for sorting
  int _getCategoryPriority(String category) {
    switch (category) {
      case 'Food':
        return 1;
      case 'Drinks':
        return 2;
      case 'Snack':
        return 3;
      default:
        return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building FoodList with category: ${widget.selectedCategory}');
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').where('isActive', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Error fetching products: ${snapshot.error}');
          return const SizedBox(
            height: 220,
            child: Center(child: Text('Error loading products')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          debugPrint('No products found');
          return const SizedBox(
            height: 220,
            child: Center(child: Text('No products available')),
          );
        }

        // Convert Firestore documents to Product objects
        List<Product> products = snapshot.data!.docs.map((doc) => Product.fromFirestore(doc)).toList();

        // Filter products based on selected category
        List<Product> foodItems = widget.selectedCategory == 'All'
            ? products
            : products.where((food) => food.category == widget.selectedCategory).toList();

        // Sort products for "All" category: Food, Drinks, Snack
        if (widget.selectedCategory == 'All') {
          foodItems.sort((a, b) => _getCategoryPriority(a.category).compareTo(_getCategoryPriority(b.category)));
        }

        debugPrint('Filtered food items for category ${widget.selectedCategory}: ${foodItems.length}');

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              final food = foodItems[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: FoodCard(
                  title: food.title,
                  subtitle: food.subtitle,
                  time: food.time,
                  imgBase64: food.imgBase64,
                  price: food.price,
                  sellerEmail: food.sellerEmail,
                  onTap: () {
                    widget.onFoodItemTap(
                      food.title,
                      food.price,
                      food.imgBase64,
                      food.subtitle,
                      food.sellerEmail,
                    );
                    // Force rebuild to ensure UI updates
                    Future.microtask(() => setState(() {}));
                    debugPrint('Tapped food item: ${food.title}');
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class FoodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String imgBase64;
  final String price;
  final String sellerEmail;
  final VoidCallback onTap;

  const FoodCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.imgBase64,
    required this.price,
    required this.sellerEmail,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('Building FoodCard for $title');
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.getCard(isDarkMode),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getShadowLight(isDarkMode),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: imgBase64.isNotEmpty
                      ? Image.memory(
                          base64Decode(imgBase64),
                          height: 120,
                          width: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            debugPrint('Error loading Base64 image for $title');
                            return Container(
                              height: 120,
                              width: 180,
                              color: AppTheme.getDivider(isDarkMode),
                              child: Icon(
                                Icons.fastfood,
                                size: 40,
                                color: AppTheme.getPrimaryText(isDarkMode),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 120,
                          width: 180,
                          color: AppTheme.getDivider(isDarkMode),
                          child: Icon(
                            Icons.fastfood,
                            size: 40,
                            color: AppTheme.getPrimaryText(isDarkMode),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.3,
                      color: AppTheme.getPrimaryText(isDarkMode),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.getSecondaryText(isDarkMode),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.getTextGrey(isDarkMode),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          color: AppTheme.getSecondaryText(isDarkMode),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}