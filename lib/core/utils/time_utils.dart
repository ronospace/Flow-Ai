import 'package:intl/intl.dart';

/// Time utilities for cross-platform time formatting and calculations
class TimeUtils {
  static const int minutesPerHour = 60;
  static const int hoursPerDay = 24;
  static const int daysPerWeek = 7;
  static const int daysPerMonth = 30; // Average
  static const int daysPerYear = 365; // Average
  
  /// Gets a human-readable "time ago" string
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '${minutes}m ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '${hours}h ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '${days}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).round();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).round();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).round();
      return '${years}y ago';
    }
  }

  /// Formats a date to a readable string
  static String formatDate(DateTime dateTime, {String pattern = 'MMM dd, yyyy'}) {
    return DateFormat(pattern).format(dateTime);
  }

  /// Formats time to a readable string
  static String formatTime(DateTime dateTime, {bool use24Hour = false}) {
    final pattern = use24Hour ? 'HH:mm' : 'h:mm a';
    return DateFormat(pattern).format(dateTime);
  }

  /// Formats date and time together
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy h:mm a').format(dateTime);
  }

  /// Gets the start of the day for a given date
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Gets the end of the day for a given date
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }

  /// Gets the start of the week for a given date (Monday)
  static DateTime startOfWeek(DateTime dateTime) {
    final daysFromMonday = dateTime.weekday - 1;
    return startOfDay(dateTime.subtract(Duration(days: daysFromMonday)));
  }

  /// Gets the start of the month for a given date
  static DateTime startOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  /// Gets the end of the month for a given date
  static DateTime endOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month + 1, 0);
  }

  /// Checks if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Checks if a date is today
  static bool isToday(DateTime dateTime) {
    return isSameDay(dateTime, DateTime.now());
  }

  /// Checks if a date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(dateTime, yesterday);
  }

  /// Checks if a date is tomorrow
  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(dateTime, tomorrow);
  }

  /// Gets the number of days between two dates
  static int daysBetween(DateTime date1, DateTime date2) {
    final startDate = startOfDay(date1);
    final endDate = startOfDay(date2);
    return endDate.difference(startDate).inDays;
  }

  /// Gets the number of weeks between two dates
  static int weeksBetween(DateTime date1, DateTime date2) {
    return (daysBetween(date1, date2) / 7).floor();
  }

  /// Gets the number of months between two dates (approximate)
  static int monthsBetween(DateTime date1, DateTime date2) {
    return (daysBetween(date1, date2) / 30).floor();
  }

  /// Adds days to a date
  static DateTime addDays(DateTime dateTime, int days) {
    return dateTime.add(Duration(days: days));
  }

  /// Subtracts days from a date
  static DateTime subtractDays(DateTime dateTime, int days) {
    return dateTime.subtract(Duration(days: days));
  }

  /// Gets a list of dates in a range
  static List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = startOfDay(start);
    final endDate = startOfDay(end);

    while (!current.isAfter(endDate)) {
      dates.add(current);
      current = addDays(current, 1);
    }

    return dates;
  }

  /// Gets a human-readable duration string
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Gets the week number of the year
  static int getWeekNumber(DateTime dateTime) {
    final firstDayOfYear = DateTime(dateTime.year, 1, 1);
    final daysSinceFirstDay = daysBetween(firstDayOfYear, dateTime) + 1;
    return ((daysSinceFirstDay - dateTime.weekday + 10) / 7).floor();
  }

  /// Checks if a year is a leap year
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Gets the number of days in a month
  static int getDaysInMonth(int year, int month) {
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && isLeapYear(year)) {
      return 29;
    }
    return daysInMonth[month - 1];
  }

  /// Converts a DateTime to ISO 8601 string
  static String toIso8601String(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Parses an ISO 8601 string to DateTime
  static DateTime fromIso8601String(String dateString) {
    return DateTime.parse(dateString);
  }

  /// Gets the current Unix timestamp
  static int getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// Converts Unix timestamp to DateTime
  static DateTime fromTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Gets a relative date string (e.g., "Today", "Yesterday", "Tomorrow")
  static String getRelativeDateString(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'Today';
    } else if (isYesterday(dateTime)) {
      return 'Yesterday';
    } else if (isTomorrow(dateTime)) {
      return 'Tomorrow';
    } else {
      final difference = daysBetween(DateTime.now(), dateTime);
      if (difference > 0) {
        if (difference <= 7) {
          return 'In $difference days';
        } else {
          return formatDate(dateTime);
        }
      } else {
        final absDifference = difference.abs();
        if (absDifference <= 7) {
          return '$absDifference days ago';
        } else {
          return formatDate(dateTime);
        }
      }
    }
  }

  /// Gets the age in years from a birth date
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
}
