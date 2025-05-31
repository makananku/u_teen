import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/theme_notifier.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:typed_data';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function()? onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    this.onRemove,
  });

  Uint8List _decodeBase64(String base64String) {
    try {
      final String cleanedBase64 = base64String.startsWith('data:image')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(cleanedBase64);
    } catch (e) {
      debugPrint('Error decoding Base64 for ${item.name}: $e');
      // Return a small placeholder image
      const placeholderBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAEAwFLLYL9WAAAAABJRU5ErkJggg==';
      return base64Decode(placeholderBase64);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Dismissible(
        key: Key(item.hashCode.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          color: AppTheme.getError(isDarkMode),
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: AppTheme.getPrimaryText(!isDarkMode)),
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.getCard(isDarkMode),
              title: Text(
                'Remove Item',
                style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
              ),
              content: Text(
                'Remove ${item.name} from cart?',
                style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Remove',
                    style: TextStyle(color: AppTheme.getError(isDarkMode)),
                  ),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          Provider.of<CartProvider>(context, listen: false).removeFromCart(item);
          onRemove?.call();
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppTheme.getCard(isDarkMode),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.imgBase64.isNotEmpty
                      ? Image.memory(
                          _decodeBase64(item.imgBase64),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.fastfood,
                            size: 40,
                            color: AppTheme.getPrimaryText(isDarkMode),
                          ),
                        )
                      : Icon(
                          Icons.fastfood,
                          size: 40,
                          color: AppTheme.getPrimaryText(isDarkMode),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryText(isDarkMode),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(item.price),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getTextGrey(isDarkMode),
                        ),
                      ),
                      if (item.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getTextGrey(isDarkMode),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: AppTheme.getAccentPrimaryBlue(isDarkMode),
                      ),
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false)
                            .decreaseQuantity(item);
                      },
                    ),
                    Text(
                      item.quantity.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.getPrimaryText(isDarkMode),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.getAccentPrimaryBlue(isDarkMode),
                      ),
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false)
                            .increaseQuantity(item);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}