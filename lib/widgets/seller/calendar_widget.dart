import 'package:flutter/material.dart';
import 'package:u_teen/services/calendar_service.dart' as calendar_service;
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
  final Map<String, Color> _filterColors = {
    'All': Colors.blueAccent,
    'Holidays': Colors.redAccent,
    'Exams': Colors.orangeAccent,
    'Events': Colors.purpleAccent,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calendar Header with Enhanced Controls
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
                        color: Colors.grey[600],
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

          // Events List
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
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    'Error loading calendar events',
                    style: TextStyle(color: Colors.red[700]),
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
                    // Event Type Filter Chips
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
                                color: Colors.grey[600],
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
    return PopupMenuButton<String>(
      color: Colors.white,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.filter_list,
              size: 16,
              color: Colors.blue[700],
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
              Icon(Icons.calendar_view_month, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('1 Month'),
            ],
          ),
        ),
        PopupMenuItem(
          value: '1',
          child: Row(
            children: [
              Icon(Icons.calendar_view_week, color: Colors.green[700]),
              const SizedBox(width: 8),
              const Text('3 Months'),
            ],
          ),
        ),
        PopupMenuItem(
          value: '2',
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text('6 Months'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'custom',
          child: Row(
            children: [
              Icon(Icons.date_range, color: Colors.purple[700]),
              const SizedBox(width: 8),
              const Text('Custom Range...'),
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
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            rangeText,
            style: TextStyle(
              color: Colors.blue[700],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: isSelected ? Colors.white : color),
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
          color: isSelected ? Colors.white : color,
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
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
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  event.formattedDateRange,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
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
  final DateTimeRange? selectedRange = await showDateRangePicker(
    context: context,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blue[700]!,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      );
    },
  );

  if (selectedRange != null) {
    onSelected(selectedRange);
  }
}