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
  final DateFormat timeFormat = DateFormat('hh:mm a', 'en_US'); // Pastikan format menggunakan locale en_US
  bool isTimeValid = true;
  String? errorMessage;
  bool isPM = false;

  @override
  void initState() {
    super.initState();
    isPM = selectedTime.hour >= 12;
    // Validasi awal
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
                      color: isTimeValid
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

    if (hour < 8 || hour >= 23) { // Ubah batas menjadi 17:00 (5 PM)
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
    final isDarkMode = Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;

    await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour12, minute: minute),
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale('en', 'US'), // Pastikan locale en_US
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false, // Paksa format 12 jam
            ),
            child: Theme(
              data: isDarkMode
                  ? ThemeData.dark().copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: AppTheme.getAccentPrimaryBlue(isDarkMode),
                        surface: AppTheme.getCard(isDarkMode),
                        onSurface: AppTheme.getPrimaryText(isDarkMode),
                      ),
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: AppTheme.getCard(isDarkMode),
                        dialBackgroundColor: AppTheme.getDetailBackground(isDarkMode),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        hourMinuteTextStyle: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryText(isDarkMode),
                        ),
                        dayPeriodTextStyle: const TextStyle(
                          fontSize: 0,
                          color: Colors.transparent,
                        ),
                        dayPeriodBorderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                        dialTextColor: MaterialStateColor.resolveWith(
                          (states) => states.contains(MaterialState.selected)
                              ? AppTheme.getPrimaryText(!isDarkMode)
                              : AppTheme.getPrimaryText(isDarkMode),
                        ),
                        dialHandColor: AppTheme.getAccentPrimaryBlue(isDarkMode),
                        hourMinuteShape: const CircleBorder(),
                        hourMinuteTextColor: AppTheme.getPrimaryText(isDarkMode),
                        entryModeIconColor: AppTheme.getPrimaryText(isDarkMode),
                      ),
                    )
                  : ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppTheme.getAccentPrimaryBlue(isDarkMode),
                        surface: AppTheme.getCard(isDarkMode),
                        onSurface: AppTheme.getPrimaryText(isDarkMode),
                      ),
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: AppTheme.getCard(isDarkMode),
                        dialBackgroundColor: AppTheme.getDetailBackground(isDarkMode),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        hourMinuteTextStyle: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryText(isDarkMode),
                        ),
                        dayPeriodTextStyle: const TextStyle(
                          fontSize: 0,
                          color: Colors.transparent,
                        ),
                        dayPeriodBorderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                        dialTextColor: MaterialStateColor.resolveWith(
                          (states) => states.contains(MaterialState.selected)
                              ? AppTheme.getPrimaryText(!isDarkMode)
                              : AppTheme.getPrimaryText(isDarkMode),
                        ),
                        dialHandColor: AppTheme.getAccentPrimaryBlue(isDarkMode),
                        hourMinuteShape: const CircleBorder(),
                        hourMinuteTextColor: AppTheme.getPrimaryText(isDarkMode),
                        entryModeIconColor: AppTheme.getPrimaryText(isDarkMode),
                      ),
                    ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Stack(
                    children: [
                      if (child != null) child,
                      Positioned(
                        right: 50,
                        top: 220, // Changed from 180 to 220 to lower the position
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildAmPmButton('AM', !tempIsPM, () {
                              setState(() {
                                tempIsPM = false;
                              });
                            }, isDarkMode),
                            const SizedBox(width: 8),
                            _buildAmPmButton('PM', tempIsPM, () {
                              setState(() {
                                tempIsPM = true;
                              });
                            }, isDarkMode),
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
        widget.onValidationChanged(isTimeValid, errorMessage);
      }
    });
  }

  Widget _buildAmPmButton(String label, bool isSelected, VoidCallback onTap, bool isDarkMode) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.getAccentPrimaryBlue(isDarkMode) : AppTheme.getDivider(isDarkMode),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppTheme.getPrimaryText(!isDarkMode)
                : AppTheme.getPrimaryText(isDarkMode),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}