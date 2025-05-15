import 'package:flutter/material.dart';
import '../models/order_model.dart';

class RatingDialog extends StatefulWidget {
  final Order order;
  final Function(int, int, String?, String?) onSubmit;

  const RatingDialog({
    super.key,
    required this.order,
    required this.onSubmit,
  });

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int foodRating = 0;
  int appRating = 0;
  final foodNotesController = TextEditingController();
  final appNotesController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    foodNotesController.dispose();
    appNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Rate Your Experience',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Food Rating
                const Text(
                  'Food Quality',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: IconButton(
                        key: ValueKey('food_star_$index'),
                        iconSize: 24,
                        icon: Icon(
                          index < foodRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            foodRating = index + 1;
                          });
                        },
                      ),
                    );
                  }),
                ),
                TextFormField(
                  controller: foodNotesController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Food Feedback (Optional)',
                    hintText: 'E.g. Taste, portion size',
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // App Rating
                const Text(
                  'App Experience',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: IconButton(
                        key: ValueKey('app_star_$index'),
                        iconSize: 24,
                        icon: Icon(
                          index < appRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            appRating = index + 1;
                          });
                        },
                      ),
                    );
                  }),
                ),
                TextFormField(
                  controller: appNotesController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'App Feedback (Optional)',
                    hintText: 'E.g. Usability, features',
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 24),

                // Buttons
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
                      onPressed: () {
                        if (foodRating == 0 || appRating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Please provide both food and app ratings'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        widget.onSubmit(
                          foodRating,
                          appRating,
                          foodNotesController.text.isNotEmpty
                              ? foodNotesController.text
                              : null,
                          appNotesController.text.isNotEmpty
                              ? appNotesController.text
                              : null,
                        );

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thank you for your feedback!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
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