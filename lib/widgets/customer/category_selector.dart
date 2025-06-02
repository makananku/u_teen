import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'package:provider/provider.dart';

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
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildCategory("All", selectedCategory == 'All', isDarkMode),
          _buildCategory("Food", selectedCategory == 'Food', isDarkMode),
          _buildCategory("Drink", selectedCategory == 'Drink', isDarkMode),
          _buildCategory("Snack", selectedCategory == 'Snack', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, bool isSelected, bool isDarkMode) {
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
                color: isSelected
                    ? AppTheme.getButton(isDarkMode)
                    : AppTheme.getPrimaryText(isDarkMode),
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 3,
                width: 30,
                color: AppTheme.getButton(isDarkMode),
              ),
          ],
        ),
      ),
    );
  }
}