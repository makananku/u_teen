import 'package:flutter/material.dart';
import '../../data/food_data.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'package:provider/provider.dart';

class FoodList extends StatelessWidget {
  final String selectedCategory;
  final Function(String, String, String, String, String) onFoodItemTap;

  const FoodList({
    Key? key,
    required this.selectedCategory,
    required this.onFoodItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final foodItems = FoodData.getFoodItems(selectedCategory);

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
              title: food["title"]!,
              subtitle: food["subtitle"]!,
              time: food["time"]!,
              imgUrl: food["imgUrl"]!,
              price: food["price"]!,
              sellerEmail: food["sellerEmail"] ?? '',
              onTap: () => onFoodItemTap(
                food["title"]!,
                food["price"]!,
                food["imgUrl"]!,
                food["subtitle"]!,
                food["sellerEmail"] ?? '',
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
  final String imgUrl;
  final String price;
  final String sellerEmail;
  final VoidCallback onTap;

  const FoodCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.imgUrl,
    required this.price,
    required this.sellerEmail,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  child: Image.asset(
                    imgUrl,
                    height: 120,
                    width: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
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