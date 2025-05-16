import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CalendarService {
  static const String _apiKey = 'AIzaSyCJubQ43RExEPnbfknWR7KKSQCzzGDeE80';
  static const String _calendarId = 'id.indonesian#holiday@group.v.calendar.google.com';

  Future<List<CalendarEvent>> getEventsInRange(DateTime startDate, DateTime endDate) async {
    try {
      final url = Uri.parse(
        'https://www.googleapis.com/calendar/v3/calendars/${Uri.encodeComponent(_calendarId)}/events'
        '?key=$_apiKey'
        '&timeMin=${startDate.toUtc().toIso8601String()}'
        '&timeMax=${endDate.toUtc().toIso8601String()}'
        '&orderBy=startTime'
        '&singleEvents=true'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List? ?? [];
        final events = items.map((item) => CalendarEvent.fromGoogleCalendar(item)).toList();
        return _mergeConsecutiveEvents(events);
      }
      return _getFallbackEvents();
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return _getFallbackEvents();
    }
  }

  Future<List<CalendarEvent>> getPublicEvents([int months = 6]) async {
    final now = DateTime.now();
    return getEventsInRange(now, DateTime(now.year, now.month + months, now.day));
  }

  List<CalendarEvent> _getFallbackEvents() {
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: '1',
        summary: 'Hari Kemerdekaan RI (Libur)',
        description: 'Libur Nasional',
        start: DateTime(now.year, 8, 17),
        end: DateTime(now.year, 8, 18),
        cardColor: _getCardColor(Colors.red[100]!),
      ),
      CalendarEvent(
        id: '2',
        summary: 'Tahun Baru (Libur)',
        description: 'Libur Nasional',
        start: DateTime(now.year + 1, 1, 1),
        end: DateTime(now.year + 1, 1, 2),
        cardColor: _getCardColor(Colors.blue[100]!),
      ),
      CalendarEvent(
        id: '3',
        summary: 'Ujian Akhir Semester',
        description: 'Jadwal Ujian',
        start: DateTime(now.year, 12, 10),
        end: DateTime(now.year, 12, 11),
        cardColor: _getCardColor(Colors.orange[100]!),
      ),
      CalendarEvent(
        id: '4',
        summary: 'Festival Kampus',
        description: 'Acara Mahasiswa',
        start: DateTime(now.year, 11, 15),
        end: DateTime(now.year, 11, 16),
        cardColor: _getCardColor(Colors.purple[100]!),
      ),
    ];
  }

  Color _getCardColor(Color baseColor) {
    return baseColor.withOpacity(0.2);
  }

  List<CalendarEvent> _mergeConsecutiveEvents(List<CalendarEvent> events) {
    if (events.isEmpty) return events;

    events.sort((a, b) => a.start.compareTo(b.start));

    List<CalendarEvent> mergedEvents = [];
    Map<String, List<CalendarEvent>> groupedEvents = {};

    for (var event in events) {
      final summary = event.summary.toLowerCase();
      if (!groupedEvents.containsKey(summary)) {
        groupedEvents[summary] = [];
      }
      groupedEvents[summary]!.add(event);
    }

    for (var summary in groupedEvents.keys) {
      var group = groupedEvents[summary]!;
      group.sort((a, b) => a.start.compareTo(b.start));

      CalendarEvent? currentEvent;

      for (var event in group) {
        if (currentEvent == null) {
          currentEvent = event;
          continue;
        }

        final daysDifference = event.start.difference(currentEvent.end).inDays;
        if (daysDifference <= 1) {
          final mergedDescription = currentEvent.description == event.description
              ? currentEvent.description
              : '${currentEvent.description}\n${event.description}'.trim();
          currentEvent = CalendarEvent(
            id: currentEvent.id,
            summary: currentEvent.summary,
            description: mergedDescription,
            start: currentEvent.start,
            end: event.end.isAfter(currentEvent.end) ? event.end : currentEvent.end,
            color: currentEvent.color,
            cardColor: currentEvent.cardColor,
            textColor: currentEvent.textColor,
          );
        } else {
          mergedEvents.add(currentEvent);
          currentEvent = event;
        }
      }

      if (currentEvent != null) {
        mergedEvents.add(currentEvent);
      }
    }

    mergedEvents.sort((a, b) => a.start.compareTo(b.start));
    return mergedEvents;
  }
}

class CalendarEvent {
  final String id;
  final String summary;
  final String description;
  final DateTime start;
  final DateTime end;
  final Color color;
  final Color cardColor;
  final Color textColor;

  CalendarEvent({
    required this.id,
    required this.summary,
    required this.description,
    required this.start,
    required this.end,
    this.color = Colors.blue,
    Color? cardColor,
    this.textColor = Colors.black87,
  }) : cardColor = cardColor ?? Colors.white.withOpacity(0.9);

  factory CalendarEvent.fromGoogleCalendar(Map<String, dynamic> json) {
    try {
      final startDate = json['start']['date'] ?? json['start']['dateTime'];
      final endDate = json['end']['date'] ?? json['end']['dateTime'];
      final summary = json['summary'] ?? 'Event';

      final eventColor = _determineEventColor(summary);

      return CalendarEvent(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        summary: summary,
        description: json['description'] ?? 'No description available',
        start: DateTime.parse(startDate).toLocal(),
        end: DateTime.parse(endDate).toLocal(),
        color: eventColor,
        cardColor: _getCardBackgroundColor(eventColor),
        textColor: _getTextColor(eventColor),
      );
    } catch (e) {
      debugPrint('Error parsing event: $e');
      rethrow;
    }
  }

  static Color _determineEventColor(String summary) {
    final lowerSummary = summary.toLowerCase();
    if (lowerSummary.contains('holiday') || lowerSummary.contains('libur')) return Colors.indigo[400]!;
    if (lowerSummary.contains('natal')) return Colors.green[400]!;
    if (lowerSummary.contains('idul') || lowerSummary.contains('fitri')) return Colors.teal[600]!;
    if (lowerSummary.contains('exam') || lowerSummary.contains('ujian')) return Colors.orange[400]!;
    if (lowerSummary.contains('buruh') || lowerSummary.contains('labor') || lowerSummary.contains('labour')) return Colors.purple[400]!;
    if (lowerSummary.contains('paskah') || lowerSummary.contains('easter')) return Colors.pink[400]!;
    if (lowerSummary.contains('imlek') || lowerSummary.contains('chinese new year')) return Colors.red[400]!;
    if (lowerSummary.contains('nyepi')) return Colors.amber[400]!;
    if (lowerSummary.contains('waisak') || lowerSummary.contains('vesak')) return Colors.yellow[600]!;
    if (lowerSummary.contains('maulid') || lowerSummary.contains('mawlid')) return Colors.cyan[400]!;
    if (lowerSummary.contains('kemerdekaan') || lowerSummary.contains('independence')) return Colors.red[400]!;
    if (lowerSummary.contains('kurban') || lowerSummary.contains('adha')) return Colors.teal[400]!;
    return Colors.blueGrey[400]!;
  }

  static Color _getCardBackgroundColor(Color baseColor) {
    return baseColor.withOpacity(0.15);
  }

  static Color _getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }

  String get formattedDateRange {
    final dateFormat = DateFormat('d MMM yyyy', 'id_ID');
    final isSameDay = start.year == end.year &&
        start.month == end.month &&
        (start.day == end.day ||
            (end.difference(start).inDays <= 1 && end.hour == 0 && end.minute == 0));

    if (isSameDay) {
      return dateFormat.format(start);
    }
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }

  String get dayName {
    return DateFormat('EEEE', 'id_ID').format(start);
  }

  bool isInRange(DateTime rangeStart, DateTime rangeEnd) {
    return (start.isAfter(rangeStart) || start.isAtSameMomentAs(rangeStart)) &&
        (end.isBefore(rangeEnd) || end.isAtSameMomentAs(rangeEnd));
  }

  String getEventType() {
    final lowerSummary = summary.toLowerCase();
    if (lowerSummary.contains('holiday') || 
        lowerSummary.contains('libur') ||
        lowerSummary.contains('natal') ||
        lowerSummary.contains('idul') ||
        lowerSummary.contains('fitri') ||
        lowerSummary.contains('buruh') ||
        lowerSummary.contains('labor') ||
        lowerSummary.contains('labour') ||
        lowerSummary.contains('paskah') ||
        lowerSummary.contains('easter') ||
        lowerSummary.contains('imlek') ||
        lowerSummary.contains('chinese new year') ||
        lowerSummary.contains('nyepi') ||
        lowerSummary.contains('waisak') ||
        lowerSummary.contains('vesak') ||
        lowerSummary.contains('maulid') ||
        lowerSummary.contains('mawlid') ||
        lowerSummary.contains('kemerdekaan') ||
        lowerSummary.contains('independence') ||
        lowerSummary.contains('kurban') ||
        lowerSummary.contains('adha')) {
      return 'Holidays';
    } else if (lowerSummary.contains('exam') || lowerSummary.contains('ujian')) {
      return 'Exams';
    } else {
      return 'Events';
    }
  }
}