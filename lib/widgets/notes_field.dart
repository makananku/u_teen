import 'package:flutter/material.dart';

class NotesField extends StatelessWidget {
  final Function(String) onNotesChanged;

  const NotesField({
    Key? key,
    required this.onNotesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Notes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onNotesChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Special requests or instructions...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}