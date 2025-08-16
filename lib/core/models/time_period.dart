enum TimePeriod {
  week,
  month,
  threeMonths,
  sixMonths,
  year,
}

extension TimePeriodExtension on TimePeriod {
  String get displayName {
    switch (this) {
      case TimePeriod.week:
        return '1 Week';
      case TimePeriod.month:
        return '1 Month';
      case TimePeriod.threeMonths:
        return '3 Months';
      case TimePeriod.sixMonths:
        return '6 Months';
      case TimePeriod.year:
        return '1 Year';
    }
  }

  int get days {
    switch (this) {
      case TimePeriod.week:
        return 7;
      case TimePeriod.month:
        return 30;
      case TimePeriod.threeMonths:
        return 90;
      case TimePeriod.sixMonths:
        return 180;
      case TimePeriod.year:
        return 365;
    }
  }

  int get months {
    switch (this) {
      case TimePeriod.week:
        return 1;
      case TimePeriod.month:
        return 1;
      case TimePeriod.threeMonths:
        return 3;
      case TimePeriod.sixMonths:
        return 6;
      case TimePeriod.year:
        return 12;
    }
  }
}
