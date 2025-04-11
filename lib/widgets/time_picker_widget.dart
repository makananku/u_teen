import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimePickerWidget extends StatefulWidget {
  final Function(DateTime) onTimeSelected;

  const TimePickerWidget({
    Key? key,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  DateTime selectedTime = DateTime.now().add(const Duration(hours: 1));
  final DateFormat timeFormat = DateFormat('HH:mm');
  bool isTimeValid = true;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pick Up Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showTimePicker,
          child: Card(
            color: Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 16),
                  Text(
                    _formatDeliveryTime(selectedTime),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isTimeValid ? Colors.black : Colors.red,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        if (!isTimeValid)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorMessage ?? 'Invalid time',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  String _formatDeliveryTime(DateTime time) {
    return 'Today, ${timeFormat.format(time)}';
  }

  bool _validateTime(DateTime time) {
    final now = DateTime.now();
    final hour = time.hour;
    
    // Check if time is in the past
    if (time.isBefore(now)) {
      errorMessage = 'Pickup time cannot be in the past';
      return false;
    }
    
    // Check business hours (8 AM - 5 PM)
    if (hour < 8 || hour >= 17) {
      errorMessage = 'Pickup available only between 08:00-17:00';
      return false;
    }
    
    return true;
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedTime),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final newTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        pickedTime.hour,
        pickedTime.minute,
      );
      
      final isValid = _validateTime(newTime);
      
      setState(() {
        selectedTime = newTime;
        isTimeValid = isValid;
      });

      if (isValid) {
        widget.onTimeSelected(newTime);
      }
    }
  }
}