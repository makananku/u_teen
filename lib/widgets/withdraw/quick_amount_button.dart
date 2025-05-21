import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/utils/app_theme.dart';

class QuickAmountButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const QuickAmountButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.getAccentPrimaryBlue(isDarkMode).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppTheme.getAccentPrimaryBlue(isDarkMode),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}