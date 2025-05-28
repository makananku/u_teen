import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import 'dart:convert';

class FoodList extends StatelessWidget {
  final String selectedCategory;
  final Function(String, String, String, String, String) onFoodItemTap;
  final List<Product> products;

  const FoodList({
    Key? key,
    required this.selectedCategory,
    required this.onFoodItemTap,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('Building FoodList with ${products.length} products');
    final foodItems = selectedCategory == 'All'
        ? products
        : products.where((food) => food.subtitle == selectedCategory).toList();
    debugPrint('Filtered food items for category $selectedCategory: ${foodItems.length}');

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
              price: food.price.toString(),
              sellerEmail: food.sellerEmail ?? '',
              onTap: () => onFoodItemTap(
                food.title,
                food.price.toString(),
                food.imgBase64,
                food.subtitle,
                food.sellerEmail ?? '',
              ),
            ),
          );
        },
      ),
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