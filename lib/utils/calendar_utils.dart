import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarUtils {
  static IconData getEventIcon(String summary) {
    final lowerSummary = summary.toLowerCase();
    if (lowerSummary.contains('exam') || lowerSummary.contains('ujian')) return Icons.assignment;
    if (lowerSummary.contains('holiday') || lowerSummary.contains('libur')) return Icons.beach_access;
    if (lowerSummary.contains('meeting')) return Icons.people;
    if (lowerSummary.contains('natal') || lowerSummary.contains('christmas')) return Icons.celebration;
    if (lowerSummary.contains('idul') || lowerSummary.contains('fitri')) return Icons.mosque;
    if (lowerSummary.contains('tahun baru') || lowerSummary.contains('new year')) return Icons.confirmation_number;
    if (lowerSummary.contains('kemerdekaan') || lowerSummary.contains('independence')) return Icons.flag;
    if (lowerSummary.contains('buruh') || lowerSummary.contains('labor')) return Icons.work;
    if (lowerSummary.contains('paskah') || lowerSummary.contains('easter')) return Icons.church;
    return Icons.event;
  }

  static Color getEventColor(String summary) {
    final lowerSummary = summary.toLowerCase();
    if (lowerSummary.contains('exam') || lowerSummary.contains('ujian')) return Colors.orange;
    if (lowerSummary.contains('holiday') || lowerSummary.contains('libur')) return Colors.blue;
    if (lowerSummary.contains('natal') || lowerSummary.contains('christmas')) return Colors.green;
    if (lowerSummary.contains('idul') || lowerSummary.contains('fitri')) return Colors.teal;
    if (lowerSummary.contains('kemerdekaan') || lowerSummary.contains('independence')) return Colors.red;
    if (lowerSummary.contains('buruh') || lowerSummary.contains('labor')) return Colors.purple;
    if (lowerSummary.contains('paskah') || lowerSummary.contains('easter')) return Colors.pink;
    return Colors.blueGrey;
  }

  static String formatEventDate(DateTime start, DateTime end) {
    final dateFormat = DateFormat('d MMM yyyy', 'id_ID');
    final dayFormat = DateFormat('EEEE', 'id_ID');

    final isSameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;

    if (isSameDay) {
      return '${dayFormat.format(start)}, ${dateFormat.format(start)}';
    }
    return '${dayFormat.format(start)}, ${dateFormat.format(start)} - ${dayFormat.format(end)}, ${dateFormat.format(end)}';
  }
}