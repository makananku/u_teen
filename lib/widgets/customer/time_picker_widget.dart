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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          color: isTimeValid
                              ? AppTheme.getPrimaryText(isDarkMode)
                              : AppTheme.getError(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAmPmButton('AM', !isPM, () {
                        _updateAmPm(false);
                      }, isDarkMode),
                      const SizedBox(width: 16),
                      _buildAmPmButton('PM', isPM, () {
                        _updateAmPm(true);
                      }, isDarkMode),
                    ],
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

  void _updateAmPm(bool newIsPM) {
    if (isPM == newIsPM) return;

    final newHour = newIsPM 
        ? (selectedTime.hour < 12 ? selectedTime.hour + 12 : selectedTime.hour)
        : (selectedTime.hour >= 12 ? selectedTime.hour - 12 : selectedTime.hour);

    final newTime = DateTime(
      selectedTime.year,
      selectedTime.month,
      selectedTime.day,
      newHour,
      selectedTime.minute,
    );

    final isValid = _validateTime(newTime);

    setState(() {
      isPM = newIsPM;
      selectedTime = newTime;
      isTimeValid = isValid;
    });

    if (isValid) {
      widget.onTimeSelected(newTime);
    }
    widget.onValidationChanged(isTimeValid, errorMessage);
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
    final isDarkMode = Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;

    await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale('en', 'US'),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
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
              child: child!,
            ),
          ),
        );
      },
    ).then((pickedTime) {
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
          isPM = pickedTime.hour >= 12;
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.getAccentPrimaryBlue(isDarkMode)
              : AppTheme.getDivider(isDarkMode),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.getAccentPrimaryBlue(isDarkMode)
                : AppTheme.getDivider(isDarkMode),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppTheme.getPrimaryText(!isDarkMode)
                : AppTheme.getPrimaryText(isDarkMode),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}