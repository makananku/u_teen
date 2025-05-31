import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_theme.dart';
import '../../../providers/theme_notifier.dart';

class TimePickerWidget extends StatefulWidget {
  final Function(DateTime) onTimeSelected;
  final Function(bool, String?) onValidationChanged;

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
  final DateFormat timeFormat = DateFormat('hh:mm a', 'en_US');
  bool isTimeValid = true;
  String? errorMessage;
  bool isPM = false;

  @override
  void initState() {
    super.initState();
    isPM = selectedTime.hour >= 12;
    isTimeValid = _validateTime(selectedTime);
    widget.onValidationChanged(isTimeValid, errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pick Up Time',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.getPrimaryText(isDarkMode),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showTimePicker,
          child: Card(
            color: AppTheme.getCard(isDarkMode),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppTheme.getPrimaryText(isDarkMode),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _formatDeliveryTime(selectedTime),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color:
                          isTimeValid
                              ? AppTheme.getPrimaryText(isDarkMode)
                              : AppTheme.getError(isDarkMode),
                    ),
                  ),
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
              style: TextStyle(
                color: AppTheme.getError(isDarkMode),
                fontSize: 12,
              ),
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

    if (hour < 8 || hour >= 17) {
      errorMessage = 'Pickup available only between 08:00 AM - 05:00 PM';
      return false;
    }

    errorMessage = null;
    return true;
  }

  Future<void> _showTimePicker() async {
    final initialTime = TimeOfDay.fromDateTime(selectedTime);
    bool tempIsPM = initialTime.hour >= 12;
    final isDarkMode =
        Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: AppTheme.getCard(isDarkMode),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getAccentPrimaryBlue(isDarkMode),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Time',
                        style: TextStyle(
                          color: AppTheme.getPrimaryText(!isDarkMode),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.getPrimaryText(!isDarkMode),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Time Picker
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppTheme.getAccentPrimaryBlue(isDarkMode),
                      ),
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: Colors.transparent,
                        dialBackgroundColor: AppTheme.getDetailBackground(
                          isDarkMode,
                        ),
                        hourMinuteTextStyle: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryText(isDarkMode),
                        ),
                        hourMinuteColor: AppTheme.getDivider(isDarkMode),
                        dialTextColor: AppTheme.getPrimaryText(isDarkMode),
                        entryModeIconColor: AppTheme.getPrimaryText(isDarkMode),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        return ElevatedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: initialTime,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppTheme.getAccentPrimaryBlue(
                                        isDarkMode,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                selectedTime = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  picked.hour,
                                  picked.minute,
                                );
                                isPM = picked.period == DayPeriod.pm;
                              });
                            }
                          },
                          child: Text(
                            'Select Time',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.getPrimaryText(isDarkMode),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // AM/PM Selector - Integrated beautifully
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildAmPmButton(
                          'AM',
                          !tempIsPM,
                          () => setState(() => tempIsPM = false),
                          isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildAmPmButton(
                          'PM',
                          tempIsPM,
                          () => setState(() => tempIsPM = true),
                          isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ),

                // Confirm Button
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.getAccentPrimaryBlue(
                        isDarkMode,
                      ),
                      foregroundColor: AppTheme.getPrimaryText(!isDarkMode),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final hour24 =
                          tempIsPM
                              ? (initialTime.hour == 12
                                  ? 12
                                  : initialTime.hour + 12)
                              : (initialTime.hour == 12 ? 0 : initialTime.hour);

                      final newTime = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        hour24,
                        initialTime.minute,
                      );

                      Navigator.pop(context, newTime);
                    },
                    child: const Text(
                      'CONFIRM TIME',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((newTime) {
      if (newTime != null) {
        final isValid = _validateTime(newTime);
        setState(() {
          selectedTime = newTime;
          isTimeValid = isValid;
          isPM = newTime.hour >= 12;
        });

        if (isValid) {
          widget.onTimeSelected(newTime);
        }
        widget.onValidationChanged(isTimeValid, errorMessage);
      }
    });
  }

  Widget _buildAmPmButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.getAccentPrimaryBlue(isDarkMode)
                  : AppTheme.getDivider(isDarkMode),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected
                    ? AppTheme.getAccentPrimaryBlue(isDarkMode)
                    : AppTheme.getDivider(isDarkMode),
            width: 2,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppTheme.getAccentPrimaryBlue(
                        isDarkMode,
                      ).withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color:
                  isSelected
                      ? AppTheme.getPrimaryText(!isDarkMode)
                      : AppTheme.getPrimaryText(isDarkMode),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
