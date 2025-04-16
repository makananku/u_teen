import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategory("All", selectedCategory == 'All'),
          _buildCategory("Food", selectedCategory == 'Food'),
          _buildCategory("Drinks", selectedCategory == 'Drinks'),
          _buildCategory("Snack", selectedCategory == 'Snack'),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => onCategorySelected(title),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.grey.shade800,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 3,
                width: 30,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }
}