import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CalendarService {
  static const String _apiKey = 'AIzaSyCJubQ43RExEPnbfknWR7KKSQCzzGDeE80';
  static const String _calendarId = 'id.indonesian#holiday@group.v.calendar.google.com';

  // New method to filter events by date range
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
        return items.map((item) => CalendarEvent.fromGoogleCalendar(item)).toList();
      }
      return _getFallbackEvents();
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return _getFallbackEvents();
    }
  }

  Future<List<CalendarEvent>> getPublicEvents() async {
    final now = DateTime.now();
    return getEventsInRange(now, DateTime(now.year, now.month + 6, now.day));
  }

  List<CalendarEvent> _getFallbackEvents() {
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: '1',
        summary: 'Hari Kemerdekaan RI',
        description: 'Libur Nasional',
        start: DateTime(now.year, 8, 17),
        end: DateTime(now.year, 8, 18),
        cardColor: _getCardColor(Colors.red[100]!),
      ),
      CalendarEvent(
        id: '2',
        summary: 'Tahun Baru',
        description: 'Libur Nasional',
        start: DateTime(now.year + 1, 1, 1),
        end: DateTime(now.year + 1, 1, 2),
        cardColor: _getCardColor(Colors.blue[100]!),
      ),
    ];
  }

  // Helper method for card colors
  Color _getCardColor(Color baseColor) {
    return baseColor.withOpacity(0.2); // Semi-transparent version
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
    if (lowerSummary.contains('holiday')) return Colors.red[400]!;
    if (lowerSummary.contains('natal')) return Colors.green[400]!;
    if (lowerSummary.contains('idul') || lowerSummary.contains('fitri')) 
      return Colors.green[700]!;
    if (lowerSummary.contains('exam')) return Colors.orange[400]!;
    return Colors.blue[400]!;
  }

  static Color _getCardBackgroundColor(Color baseColor) {
    return baseColor.withOpacity(0.15);
  }

  static Color _getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }

  String get formattedDateRange {
    final dateFormat = DateFormat('d MMM', 'id_ID');
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return dateFormat.format(start);
    }
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }

  String get dayName {
    return DateFormat('EEEE', 'id_ID').format(start);
  }

  // New method to check if event is within a date range
  bool isInRange(DateTime rangeStart, DateTime rangeEnd) {
    return (start.isAfter(rangeStart) || start.isAtSameMomentAs(rangeStart)) &&
           (end.isBefore(rangeEnd) || end.isAtSameMomentAs(rangeEnd));
  }
}