// rating_dialog.dart
import 'package:flutter/material.dart';
import '../../models/order_model.dart';

class RatingDialog extends StatefulWidget {
  final Order order;
  final Function(int foodRating, int appRating, String? foodNotes, String? appNotes) onSubmit;

  const RatingDialog({
    super.key,
    required this.order,
    required this.onSubmit,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _foodNotesController = TextEditingController();
  final _appNotesController = TextEditingController();
  
  int _foodRating = 0;
  int _appRating = 0;

  @override
  void dispose() {
    _foodNotesController.dispose();
    _appNotesController.dispose();
    super.dispose();
  }

  void _submitRating() {
    if (_foodRating == 0 || _appRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide both food and app ratings'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onSubmit(
      _foodRating,
      _appRating,
      _foodNotesController.text.trim().isNotEmpty ? _foodNotesController.text.trim() : null,
      _appNotesController.text.trim().isNotEmpty ? _appNotesController.text.trim() : null,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildRatingStars(int currentRating, ValueChanged<int> onRatingChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: IconButton(
            icon: Icon(
              index < currentRating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 24,
            ),
            onPressed: () => onRatingChanged(index + 1),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Rate Your Experience',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Food Rating Section
                const Text(
                  'Food Quality',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildRatingStars(_foodRating, (rating) {
                  setState(() => _foodRating = rating);
                }),
                TextFormField(
                  controller: _foodNotesController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Food Feedback (Optional)',
                    hintText: 'E.g. Taste, portion size',
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // App Rating Section
                const Text(
                  'App Experience',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildRatingStars(_appRating, (rating) {
                  setState(() => _appRating = rating);
                }),
                TextFormField(
                  controller: _appNotesController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'App Feedback (Optional)',
                    hintText: 'E.g. Usability, features',
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: _submitRating,
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(color: Colors.white),
                      ),
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