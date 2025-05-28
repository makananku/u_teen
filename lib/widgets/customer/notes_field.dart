import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import '../../../providers/theme_notifier.dart';
import 'package:provider/provider.dart';

class NotesField extends StatelessWidget {
  final Function(String) onNotesChanged;

  const NotesField({
    Key? key,
    required this.onNotesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.getPrimaryText(isDarkMode),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onNotesChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.getCard(isDarkMode),
            hintText: 'Special requests or instructions...',
            hintStyle: TextStyle(color: AppTheme.getSecondaryText(isDarkMode)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.getDivider(isDarkMode)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.getDivider(isDarkMode)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.getButton(isDarkMode)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
          maxLines: 3,
        ),
      ],
    );
  }
}