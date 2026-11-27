import 'package:intl/intl.dart';

enum Slot { morning, evening }

/// Simulated clock for the demo.
/// Day 1 is anchored to a fixed date (2026-12-01).
/// Morning = 10:00, Evening = 17:30 on that day.
class SimClock {
  static final DateTime _day1Anchor = DateTime(2026, 12, 1);
  static const int _morningHour = 10;
  static const int _morningMinute = 0;
  static const int _eveningHour = 17;
  static const int _eveningMinute = 30;

  final int day; // 1, 2, or 3
  final Slot slot;

  const SimClock({required this.day, required this.slot});

  /// Current simulated "now" for the selected day and slot.
  DateTime get now {
    final baseDate = _day1Anchor.add(Duration(days: day - 1));
    final hour = slot == Slot.morning ? _morningHour : _eveningHour;
    final minute = slot == Slot.morning ? _morningMinute : _eveningMinute;
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  /// Start of the selected day (00:00).
  DateTime get today {
    final baseDate = _day1Anchor.add(Duration(days: day - 1));
    return DateTime(baseDate.year, baseDate.month, baseDate.day);
  }

  /// Start of yesterday (00:00).
  DateTime get yesterday {
    return today.subtract(const Duration(days: 1));
  }

  /// End of yesterday (23:59:59.999).
  DateTime get yesterdayEnd {
    return today.subtract(const Duration(milliseconds: 1));
  }

  /// Start of the same day last week.
  DateTime get lastWeekSameDay {
    return today.subtract(const Duration(days: 7));
  }

  /// End of the same day last week (23:59:59.999).
  DateTime get lastWeekSameDayEnd {
    return lastWeekSameDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
  }

  /// Start of this week (Monday).
  DateTime get weekStart {
    final d = today;
    final daysFromMonday = (d.weekday - DateTime.monday) % 7;
    return d.subtract(Duration(days: daysFromMonday));
  }

  /// End of this week (Sunday 23:59:59.999).
  DateTime get weekEnd {
    return weekStart.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));
  }

  /// Start of the weekend (Saturday 00:00) for package expiry.
  DateTime get weekendStart {
    final d = today;
    final daysUntilSaturday = (DateTime.saturday - d.weekday) % 7;
    return d.add(Duration(days: daysUntilSaturday));
  }

  /// End of the weekend (Sunday 23:59:59.999).
  DateTime get weekendEnd {
    return weekendStart.add(const Duration(days: 2)).subtract(const Duration(milliseconds: 1));
  }

  /// Label for the slot (e.g., "Morning", "Evening").
  String get slotLabel => slot == Slot.morning ? 'Morning' : 'Evening';

  /// Full label for display (e.g., "Day 1 Morning").
  String get fullLabel => 'Day $day $slotLabel';

  /// Period label for story cards (e.g., "Yesterday", "Today till 5:30 PM").
  String get periodLabel {
    if (slot == Slot.morning) {
      return 'Yesterday';
    } else {
      return 'Today till 5:30 PM';
    }
  }

  @override
  String toString() => 'SimClock(day: $day, slot: $slot, now: $now)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimClock && runtimeType == other.runtimeType && day == other.day && slot == other.slot;

  @override
  int get hashCode => Object.hash(day, slot);
}

/// Extension for formatting SimClock for display.
extension SimClockFormat on SimClock {
  String formatDate(DateTime dt) => DateFormat('EEE, MMM d').format(dt);
  String formatTime(DateTime dt) => DateFormat('h:mm a').format(dt);
  String formatDateTime(DateTime dt) => DateFormat('EEE, MMM d \'at\' h:mm a').format(dt);
}