import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _displayDateFormat = DateFormat('EEE, d MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('d MMM');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEEE');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');

  static String formatDisplayDate(DateTime date) => _displayDateFormat.format(date);
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);
  static String formatDayOfWeek(DateTime date) => _dayOfWeekFormat.format(date);
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);

  static int? normalizeDay(dynamic value) {
    if (value is int && value >= 0 && value <= 6) return value;
    final s = value?.toString().trim().toLowerCase() ?? '';
    final intVal = int.tryParse(s);
    if (intVal != null && intVal >= 0 && intVal <= 6) return intVal;

    switch (s) {
      case 'sunday':
      case 'sun':
        return 0;
      case 'monday':
      case 'mon':
        return 1;
      case 'tuesday':
      case 'tue':
      case 'tues':
        return 2;
      case 'wednesday':
      case 'wed':
        return 3;
      case 'thursday':
      case 'thu':
      case 'thur':
      case 'thurs':
        return 4;
      case 'friday':
      case 'fri':
        return 5;
      case 'saturday':
      case 'sat':
        return 6;
      default:
        return null;
    }
  }

  static DateTime? parseLiveDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    final s = raw.toString().trim();
    if (s.isEmpty) return null;

    // Try standard ISO
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;

    // Try yyyy-MM-dd or yyyy/MM/dd
    final dashParts = s.split(RegExp(r'[-/]'));
    if (dashParts.length == 3) {
      if (dashParts[0].length == 4) {
        final y = int.tryParse(dashParts[0]);
        final m = int.tryParse(dashParts[1]);
        final d = int.tryParse(dashParts[2]);
        if (y != null && m != null && d != null) {
          return DateTime(y, m, d);
        }
      } else if (dashParts[2].length == 4) {
        // dd-MM-yyyy or dd/MM/yyyy
        final d = int.tryParse(dashParts[0]);
        final m = int.tryParse(dashParts[1]);
        final y = int.tryParse(dashParts[2]);
        if (y != null && m != null && d != null) {
          return DateTime(y, m, d);
        }
      }
    }
    return null;
  }

  static DateTime nextDateForWeekday(int dayIndex, {DateTime? fromDate}) {
    final base = fromDate ?? DateTime.now();
    final cleanBase = DateTime(base.year, base.month, base.day);
    // In Dart, DateTime.weekday is 1 for Mon..7 for Sun. Convert dayIndex (0 for Sun..6 for Sat)
    final baseDayIndex = cleanBase.weekday % 7;
    final delta = (dayIndex - baseDayIndex + 7) % 7;
    return cleanBase.add(Duration(days: delta));
  }

  static DateTime combineDateAndTime(DateTime date, String? rawTime) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    if (rawTime == null || rawTime.trim().isEmpty) return cleanDate;

    final s = rawTime.trim().toLowerCase();
    final match = RegExp(r'(\d{1,2})(?:(?::|\.)(\d{2}))?\s*(am|pm)?').firstMatch(s);
    if (match == null) return cleanDate;

    var h = int.tryParse(match.group(1) ?? '0') ?? 0;
    final min = int.tryParse(match.group(2) ?? '0') ?? 0;
    final ap = match.group(3);

    if (ap == 'pm' && h < 12) h += 12;
    if (ap == 'am' && h == 12) h = 0;

    if (h >= 0 && h <= 23 && min >= 0 && min <= 59) {
      return DateTime(date.year, date.month, date.day, h, min);
    }
    return cleanDate;
  }

  static String relativeTime(dynamic raw) {
    final dt = parseLiveDate(raw);
    if (dt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 45) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('d MMM').format(dt);
  }
}
