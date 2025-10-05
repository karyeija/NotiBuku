import 'package:intl/intl.dart';

class FormatDate {
  static String dayOrToday(dynamic date) {
    final dt = _parseDate(date);
    if (dt == null) return 'Unknown Date';

    final now = DateTime.now();

    // Check if same calendar day (before midnight)
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }

    // Otherwise return formatted month and day
    final month = DateFormat.MMM().format(dt);
    final day = DateFormat.d().format(dt);
    return '$month $day';
  }

  static String day(dynamic date) {
    final dt = _parseDate(date);
    return dt != null ? DateFormat.d().format(dt) : 'Unknown Date';
  }

  static String month(dynamic date) {
    final dt = _parseDate(date);
    return dt != null ? DateFormat.MMM().format(dt) : 'Unknown Date';
  }

  static String year(dynamic date) {
    final dt = _parseDate(date);
    return dt != null ? DateFormat.y().format(dt) : 'Unknown Date';
  }

  static String hour(dynamic date) {
    final dt = _parseDate(date);
    return dt != null
        ? DateFormat.jm().format(dt)
        : 'Unknown Time'; // e.g. 5:30 PM
  }

  static String fullDateTime(dynamic date) {
    final dt = _parseDate(date);
    return dt != null
        ? DateFormat.yMMMd().add_jm().format(dt)
        : 'Unknown DateTime';
  }

  static DateTime? _parseDate(dynamic date) {
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    return null;
  }
}
