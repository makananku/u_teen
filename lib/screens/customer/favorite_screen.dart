import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../models/favorite_item.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'home_screen.dart';
import 'dart:convert';
import 'dart:typed_data';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  void _navigateToDetail(BuildContext context, FavoriteItem item) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          initialFoodItem: item.name,
          initialFoodPrice: item.price,
          initialFoodImg64: item.imgBase64,
          initialFoodSubtitle: item.subtitle ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final favoriteItems = favoriteProvider.favoriteItems;
    final theme = Theme.of(context);
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Scaffold(
      backgroundColor: AppTheme.getCard(isDarkMode),
      appBar: AppBar(
        title: Text(
          "My Favorites",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.getPrimaryText(isDarkMode),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.getCard(isDarkMode),
        foregroundColor: AppTheme.getPrimaryText(isDarkMode),
      ),
      body: favoriteItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: AppTheme.getTextGrey(isDarkMode),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No favorites yet",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.getSecondaryText(isDarkMode),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: favoriteItems.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: AppTheme.getDivider(isDarkMode),
              ),
              itemBuilder: (context, index) {
                final item = favoriteItems[index];
                debugPrint('Rendering favorite: ${item.name}, imgBase64 length: ${item.imgBase64.length}');
                return Dismissible(
                  key: Key(item.name),
                  background: Container(
                    color: AppTheme.getAccentRedLight(isDarkMode),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.delete,
                      color: AppTheme.getSnackBarError(isDarkMode),
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.getCard(isDarkMode),
                        title: Text(
                          "Remove from favorites?",
                          style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
                        ),
                        content: Text(
                          "Are you sure you want to remove ${item.name}?",
                          style: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: AppTheme.getTextMedium(isDarkMode)),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(
                              "Remove",
                              style: TextStyle(color: AppTheme.getSnackBarError(isDarkMode)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    favoriteProvider.removeFromFavorites(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed ${item.name} from favorites'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.imgBase64.isNotEmpty
                          ? Image.memory(
                              _decodeBase64(item.imgBase64),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                debugPrint('Error loading Base64 image for ${item.name}');
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: AppTheme.getDivider(isDarkMode),
                                  child: Icon(
                                    Icons.fastfood,
                                    color: AppTheme.getPrimaryText(isDarkMode),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: AppTheme.getDivider(isDarkMode),
                              child: Icon(
                                Icons.fastfood,
                                color: AppTheme.getPrimaryText(isDarkMode),
                              ),
                            ),
                    ),
                    title: Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getPrimaryText(isDarkMode),
                      ),
                    ),
                    subtitle: Text(
                      "Rp ${item.price}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.getSecondaryText(isDarkMode),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.shopping_cart, color: AppTheme.getAccentGreen(isDarkMode)),
                          onPressed: () => _navigateToDetail(context, item),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppTheme.getSnackBarError(isDarkMode),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.getCard(isDarkMode),
                                title: Text(
                                  "Remove from favorites?",
                                  style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
                                ),
                                content: Text(
                                  "Are you sure you want to remove ${item.name}?",
                                  style: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: AppTheme.getTextMedium(isDarkMode)),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      favoriteProvider.removeFromFavorites(item);
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Removed ${item.name} from favorites'),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Remove",
                                      style: TextStyle(color: AppTheme.getSnackBarError(isDarkMode)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Uint8List _decodeBase64(String base64String) {
    try {
      // Remove data URI prefix if present
      final String cleanedBase64 = base64String.startsWith('data:image')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(cleanedBase64);
    } catch (e) {
      debugPrint('Error decoding Base64: $e');
      rethrow;
    }
  }
}