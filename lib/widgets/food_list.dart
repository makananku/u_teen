import 'package:flutter/material.dart';
import '../data/food_data.dart';

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
      height: 220, // Increased height for better card display
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food image with price tag
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
                      color: Colors.grey[200],
                      child: const Icon(Icons.fastfood, size: 40),
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

            // Food details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
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
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey[600],
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