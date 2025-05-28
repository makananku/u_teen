import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_teen/providers/theme_notifier.dart';
import 'package:u_teen/services/calendar_service.dart' as calendar_service;
import 'package:u_teen/utils/app_theme.dart';
import '../../utils/calendar_utils.dart';
import 'package:intl/intl.dart';

class CalendarSection extends StatefulWidget {
  final int selectedFilterIndex;
  final List<int> filterMonths;
  final String selectedEventType;
  final DateTimeRange? customDateRange;
  final ValueChanged<int> onFilterChanged;
  final ValueChanged<String> onEventTypeChanged;
  final ValueChanged<DateTimeRange> onCustomDateRangeSelected;

  const CalendarSection({
    super.key,
    required this.selectedFilterIndex,
    required this.filterMonths,
    required this.selectedEventType,
    required this.customDateRange,
    required this.onFilterChanged,
    required this.onEventTypeChanged,
    required this.onCustomDateRangeSelected,
  });

  @override
  _CalendarSectionState createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  late Map<String, Color> _filterColors;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    _filterColors = {
      'All': AppTheme.getAccentPrimaryBlue(isDarkMode),
      'Holidays': AppTheme.getSnackBarError(isDarkMode),
      'Exams': AppTheme.getRating(isDarkMode),
      'Events': AppTheme.getSnackBarSuccess(isDarkMode),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.getCard(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getSecondaryText(isDarkMode).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACADEMIC CALENDAR',
                      style: TextStyle(
                        color: AppTheme.getSecondaryText(isDarkMode),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    CalendarFilterButton(
                      selectedFilterIndex: widget.selectedFilterIndex,
                      filterMonths: widget.filterMonths,
                      onFilterChanged: widget.onFilterChanged,
                      onCustomDateRangeSelected: widget.onCustomDateRangeSelected,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DateRangeDisplay(
                  selectedFilterIndex: widget.selectedFilterIndex,
                  filterMonths: widget.filterMonths,
                  customDateRange: widget.customDateRange,
                ),
              ],
            ),
          ),
          FutureBuilder<List<calendar_service.CalendarEvent>>(
            future: widget.customDateRange != null
                ? calendar_service.CalendarService().getEventsInRange(
                    widget.customDateRange!.start,
                    widget.customDateRange!.end,
                  )
                : calendar_service.CalendarService().getPublicEvents(
                    widget.filterMonths[widget.selectedFilterIndex],
                  ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.getAccentPrimaryBlue(isDarkMode),
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    'Error loading calendar events',
                    style: TextStyle(color: AppTheme.getSnackBarError(isDarkMode)),
                  ),
                );
              }

              final events = snapshot.data ?? [];
              debugPrint('Events fetched: ${events.map((e) => e.summary).toList()}');

              final filteredEvents = widget.selectedEventType == 'All'
                  ? events
                  : events.where((event) => event.getEventType() == widget.selectedEventType).toList();

              debugPrint('Selected filter: ${widget.selectedEventType}');
              debugPrint('Filtered events: ${filteredEvents.map((e) => e.summary).toList()}');

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          EventTypeChip(
                            label: 'All',
                            icon: Icons.calendar_today,
                            isSelected: widget.selectedEventType == 'All',
                            color: _filterColors['All']!,
                            onSelected: () => widget.onEventTypeChanged('All'),
                          ),
                          EventTypeChip(
                            label: 'Holidays',
                            icon: Icons.beach_access,
                            isSelected: widget.selectedEventType == 'Holidays',
                            color: _filterColors['Holidays']!,
                            onSelected: () => widget.onEventTypeChanged('Holidays'),
                          ),
                          EventTypeChip(
                            label: 'Exams',
                            icon: Icons.school,
                            isSelected: widget.selectedEventType == 'Exams',
                            color: _filterColors['Exams']!,
                            onSelected: () => widget.onEventTypeChanged('Exams'),
                          ),
                          EventTypeChip(
                            label: 'Events',
                            icon: Icons.event,
                            isSelected: widget.selectedEventType == 'Events',
                            color: _filterColors['Events']!,
                            onSelected: () => widget.onEventTypeChanged('Events'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    filteredEvents.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            child: Text(
                              'No events in the selected period',
                              style: TextStyle(
                                color: AppTheme.getSecondaryText(isDarkMode),
                                fontSize: 14,
                              ),
                            ),
                          )
                        : Column(
                            children: filteredEvents.map((event) => EventItem(event: event)).toList(),
                          ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CalendarFilterButton extends StatelessWidget {
  final int selectedFilterIndex;
  final List<int> filterMonths;
  final ValueChanged<int> onFilterChanged;
  final ValueChanged<DateTimeRange> onCustomDateRangeSelected;

  const CalendarFilterButton({
    super.key,
    required this.selectedFilterIndex,
    required this.filterMonths,
    required this.onFilterChanged,
    required this.onCustomDateRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    return PopupMenuButton<String>(
      color: AppTheme.getCard(isDarkMode),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.getAccentPrimaryBlue(isDarkMode).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter',
              style: TextStyle(
                color: AppTheme.getAccentPrimaryBlue(isDarkMode),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.filter_list,
              size: 16,
              color: AppTheme.getAccentPrimaryBlue(isDarkMode),
            ),
          ],
        ),
      ),
      onSelected: (value) {
        if (value == 'custom') {
          showCustomDateRangePicker(context, onCustomDateRangeSelected);
        } else {
          onFilterChanged(int.parse(value));
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: '0',
          child: Row(
            children: [
              Icon(Icons.calendar_view_month, color: AppTheme.getAccentPrimaryBlue(isDarkMode)),
              const SizedBox(width: 8),
              Text(
                '1 Month',
                style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: '1',
          child: Row(
            children: [
              Icon(Icons.calendar_view_week, color: AppTheme.getSnackBarSuccess(isDarkMode)),
              const SizedBox(width: 8),
              Text(
                '3 Months',
                style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: '2',
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: AppTheme.getRating(isDarkMode)),
              const SizedBox(width: 8),
              Text(
                '6 Months',
                style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'custom',
          child: Row(
            children: [
              Icon(Icons.date_range, color: AppTheme.getSnackBarError(isDarkMode)),
              const SizedBox(width: 8),
              Text(
                'Custom Range...',
                style: TextStyle(color: AppTheme.getPrimaryText(isDarkMode)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DateRangeDisplay extends StatelessWidget {
  final int selectedFilterIndex;
  final List<int> filterMonths;
  final DateTimeRange? customDateRange;

  const DateRangeDisplay({
    super.key,
    required this.selectedFilterIndex,
    required this.filterMonths,
    required this.customDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final now = DateTime.now();
    late String rangeText;

    if (customDateRange != null) {
      rangeText =
          '${DateFormat('MMM yyyy').format(customDateRange!.start)} - ${DateFormat('MMM yyyy').format(customDateRange!.end)}';
    } else {
      final endDate = DateTime(
        now.year,
        now.month + filterMonths[selectedFilterIndex],
        now.day,
      );
      rangeText = '${DateFormat('MMM yyyy').format(now)} - ${DateFormat('MMM yyyy').format(endDate)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.getAccentPrimaryBlue(isDarkMode).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 16, color: AppTheme.getAccentPrimaryBlue(isDarkMode)),
          const SizedBox(width: 8),
          Text(
            rangeText,
            style: TextStyle(
              color: AppTheme.getAccentPrimaryBlue(isDarkMode),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class EventTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onSelected;

  const EventTypeChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppTheme.getPrimaryText(!isDarkMode) : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: isSelected ? AppTheme.getPrimaryText(!isDarkMode) : color),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) onSelected();
        },
        selectedColor: color,
        backgroundColor: color.withOpacity(0.1),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.getPrimaryText(!isDarkMode) : color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }
}

class EventItem extends StatelessWidget {
  final calendar_service.CalendarEvent event;

  const EventItem({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final icon = CalendarUtils.getEventIcon(event.summary);
    final color = CalendarUtils.getEventColor(event.summary);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          event.summary,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.getPrimaryText(isDarkMode),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              event.description,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getSecondaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 12, color: AppTheme.getSecondaryText(isDarkMode)),
                const SizedBox(width: 4),
                Text(
                  event.formattedDateRange,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getSecondaryText(isDarkMode),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            event.dayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

void showCustomDateRangePicker(BuildContext context, ValueChanged<DateTimeRange> onSelected) async {
  final isDarkMode = Provider.of<ThemeNotifier>(context, listen: false).isDarkMode;
  final DateTimeRange? selectedRange = await showDateRangePicker(
    context: context,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme(
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
            primary: AppTheme.getAccentPrimaryBlue(isDarkMode),
            onPrimary: AppTheme.getPrimaryText(!isDarkMode),
            surface: AppTheme.getCard(isDarkMode),
            onSurface: AppTheme.getPrimaryText(isDarkMode),
            secondary: AppTheme.getSecondaryText(isDarkMode),
            onSecondary: AppTheme.getPrimaryText(!isDarkMode),
            error: AppTheme.getSnackBarError(isDarkMode),
            onError: AppTheme.getPrimaryText(!isDarkMode),
            background: AppTheme.getBackground(isDarkMode),
            onBackground: AppTheme.getPrimaryText(isDarkMode),
          ),
          dialogBackgroundColor: AppTheme.getCard(isDarkMode),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.getAccentPrimaryBlue(isDarkMode),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (selectedRange != null) {
    onSelected(selectedRange);
  }
}