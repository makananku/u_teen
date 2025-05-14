import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimePickerWidget extends StatefulWidget {
  final Function(DateTime) onTimeSelected;
  final Function(bool, String?) onValidationChanged; // Callback untuk validasi

  const TimePickerWidget({
    Key? key,
    required this.onTimeSelected,
    required this.onValidationChanged,
  }) : super(key: key);

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  DateTime selectedTime = DateTime.now().add(const Duration(hours: 1));
  final DateFormat timeFormat = DateFormat('hh:mm a');
  bool isTimeValid = true;
  String? errorMessage;
  bool isPM = false;

  @override
  void initState() {
    super.initState();
    isPM = selectedTime.hour >= 12;
  }

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
                  // Hapus Spacer dan Icon arrow_drop_down
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

    if (time.isBefore(now)) {
      errorMessage = 'Pickup time cannot be in the past';
      return false;
    }

    if (hour < 8 || hour >= 24) {
      errorMessage = 'Pickup available only between 08:00 AM - 05:00 PM';
      return false;
    }

    errorMessage = null;
    return true;
  }

  Future<void> _showTimePicker() async {
    final initialTime = TimeOfDay.fromDateTime(selectedTime);
    int hour12 = initialTime.hourOfPeriod == 0 ? 12 : initialTime.hourOfPeriod;
    int minute = initialTime.minute;
    bool tempIsPM = initialTime.hour >= 12;

    await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour12, minute: minute),
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale('en', 'US'), // Set locale to US for 12-hour format
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false, // Enforce 12-hour format
            ),
            child: Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.blue,
                ),
                timePickerTheme: TimePickerThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  hourMinuteTextStyle: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  // Hide default AM/PM text
                  dayPeriodTextStyle: const TextStyle(
                    fontSize: 0,
                    color: Colors.transparent,
                  ),
                  dayPeriodBorderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                  dialTextColor: MaterialStateColor.resolveWith(
                    (states) => states.contains(MaterialState.selected)
                        ? Colors.white
                        : Colors.black,
                  ),
                  dialHandColor: Colors.blue,
                  hourMinuteShape: const CircleBorder(),
                ),
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Stack(
                    children: [
                      if (child != null) child,
                      Positioned(
                        right: 50,
                        top: 180,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAmPmButton('AM', !tempIsPM, () {
                              setState(() {
                                tempIsPM = false;
                              });
                            }),
                            const SizedBox(width: 8),
                            _buildAmPmButton('PM', tempIsPM, () {
                              setState(() {
                                tempIsPM = true;
                              });
                            }),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    ).then((pickedTime) {
      if (pickedTime != null) {
        // Convert selected time to 24-hour format for DateTime
        int pickedHour = pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
        final hour24 = tempIsPM
            ? (pickedHour == 12 ? 12 : pickedHour + 12)
            : (pickedHour == 12 ? 0 : pickedHour);

        final newTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          hour24,
          pickedTime.minute,
        );

        final isValid = _validateTime(newTime);

        setState(() {
          selectedTime = newTime;
          isTimeValid = isValid;
          isPM = tempIsPM;
        });

        if (isValid) {
          widget.onTimeSelected(newTime);
        }
        widget.onValidationChanged(isTimeValid, errorMessage); // Panggil callback validasi
      }
    });
  }

  Widget _buildAmPmButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}