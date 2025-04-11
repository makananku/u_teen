import 'package:flutter/material.dart';
import '../data/food_data.dart';

class FoodList extends StatelessWidget {
  final String selectedCategory;
  final Function(String, String, String, String, String) onFoodItemTap; // Changed to include sellerEmail

  const FoodList({
    Key? key,
    required this.selectedCategory,
    required this.onFoodItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final foodItems = FoodData.getFoodItems(selectedCategory);

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          final food = foodItems[index];
          return FoodCard(
            title: food["title"]!,
            subtitle: food["subtitle"]!,
            time: food["time"]!,
            imgUrl: food["imgUrl"]!,
            price: food["price"]!,
            sellerEmail: food["sellerEmail"] ?? '', // Add sellerEmail
            onTap: () => onFoodItemTap(
              food["title"]!,
              food["price"]!,
              food["imgUrl"]!,
              food["subtitle"]!,
              food["sellerEmail"] ?? '', // Pass sellerEmail
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
  final String sellerEmail; // Add sellerEmail
  final VoidCallback onTap;

  const FoodCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.imgUrl,
    required this.price,
    required this.sellerEmail, // Add to constructor
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Image.asset(
                imgUrl,
                height: 100,
                width: 160,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
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