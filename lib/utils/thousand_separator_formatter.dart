import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove non-digits
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Parse the number and format with thousand separators
    double value = double.parse(newText);
    String formattedText = _formatter.format(value);

    // Calculate cursor position
    int selectionIndex = newValue.selection.end;
    int newLength = formattedText.length;
    int oldLength = oldValue.text.length;
    int diff = newLength - oldLength;

    // Adjust cursor position based on added/removed separators
    int newSelectionIndex = selectionIndex + diff;
    if (newSelectionIndex < 0) {
      newSelectionIndex = 0;
    } else if (newSelectionIndex > newLength) {
      newSelectionIndex = newLength;
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}