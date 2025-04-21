import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarUtils {
  static IconData getEventIcon(String summary) {
    final lowerSummary = summary.toLowerCase();
    if (lowerSummary.contains('exam')) return Icons.school;
    if (lowerSummary.contains('holiday')) return Icons.celebration;
    if (lowerSummary.contains('meeting')) return Icons.people;
    if (lowerSummary.contains('natal') || lowerSummary.contains('christmas')) return Icons.celebration;
    if (lowerSummary.contains('idul') || lowerSummary.contains('fitri')) return Icons.mosque;
    if (lowerSummary.contains('tahun baru') || lowerSummary.contains('new year')) return Icons.confirmation_number;
    if (lowerSummary.contains('kemerdekaan') || lowerSummary.contains('independence')) return Icons.flag;
    if (lowerSummary.contains('buruh') || lowerSummary.contains('labor') || lowerSummary.contains('labour')) return Icons.work;
    if (lowerSummary.contains('paskah') || lowerSummary.contains('easter')) return Icons.church;
    if (lowerSummary.contains('imlek') || lowerSummary.contains('chinese new year')) return Icons.light;
    if (lowerSummary.contains('nyepi')) return Icons.spa;
    if (lowerSummary.contains('waisak') || lowerSummary.contains('vesak')) return Icons.lightbulb;
    if (lowerSummary.contains('kurban') || lowerSummary.contains('adha')) return Icons.star;
    if (lowerSummary.contains('maulid') || lowerSummary.contains('mawlid')) return Icons.mosque;
    return Icons.event_available; // Default icon for better distinction
  }

  static Color getEventColor(String summary) {
    final lowerSummary = summary.toLowerCase();
    if (lowerSummary.contains('natal') || lowerSummary.contains('christmas')) return Colors.green[600]!;
    if (lowerSummary.contains('idul') || lowerSummary.contains('fitri') || lowerSummary.contains('kurban') || lowerSummary.contains('adha')) return Colors.teal[600]!;
    if (lowerSummary.contains('kemerdekaan') || lowerSummary.contains('independence')) return Colors.red[600]!;
    if (lowerSummary.contains('exam')) return Colors.orange[600]!;
    if (lowerSummary.contains('buruh') || lowerSummary.contains('labor') || lowerSummary.contains('labour')) return Colors.purple[600]!;
    if (lowerSummary.contains('paskah') || lowerSummary.contains('easter')) return Colors.pink[400]!;
    if (lowerSummary.contains('imlek') || lowerSummary.contains('chinese new year')) return Colors.red[400]!;
    if (lowerSummary.contains('nyepi')) return Colors.amber[600]!;
    if (lowerSummary.contains('waisak') || lowerSummary.contains('vesak')) return Colors.yellow[700]!;
    if (lowerSummary.contains('maulid') || lowerSummary.contains('mawlid')) return Colors.cyan[600]!;
    if (lowerSummary.contains('holiday')) return Colors.indigo[400]!;
    return Colors.blueGrey[400]!; // Default color for other events
  }

  static String formatEventDate(DateTime start, DateTime end) {
    final dateFormat = DateFormat('d MMM yyyy', 'id_ID');
    final dayName = DateFormat('EEEE', 'id_ID').format(start);
    
    // Check if the event spans only one day
    final isSameDay = start.year == end.year &&
                      start.month == end.month &&
                      (start.day == end.day || 
                       (end.difference(start).inDays <= 1 && end.hour == 0 && end.minute == 0));

    if (isSameDay) {
      return '${dateFormat.format(start)} ($dayName)';
    }
    return '${dateFormat.format(start)} - ${dateFormat.format(end)} ($dayName)';
  }
}