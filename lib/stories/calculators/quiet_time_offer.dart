import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Regularly quiet time for an offer (based on last 4 weeks weekday hourly occupancy).
class QuietTimeOfferCalculator extends StoryCalculator {
  @override
  String get id => 'quiet_time_offer';

  @override
  bool supportedAt(SimClock clock) => clock.slot == Slot.morning && clock.day >= 2;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    // Need at least 3 weeks of data (per spec: minimum data threshold)
    final fourWeeksAgo = clock.today.subtract(const Duration(days: 28));
    final todayEnd = clock.today.subtract(const Duration(milliseconds: 1));

    // Get sessions in the last 4 weeks (excluding today)
    final recentSessions = snapshot.sessions.where((s) {
      return !s.start.isBefore(fourWeeksAgo) && s.start.isBefore(todayEnd);
    }).toList();

    if (recentSessions.isEmpty) return null;

    // Calculate occupancy per weekday (Mon-Fri) per hour (10:00-22:00)
    // Occupancy = devices in use / total devices
    final totalDevices = snapshot.devices.length;
    if (totalDevices == 0) return null;

    // weekday (1-5 for Mon-Fri) -> hour (10-22) -> total occupied device-hours
    final Map<int, Map<int, double>> deviceHoursByWeekdayHour = {};
    final Map<int, Map<int, int>> daysWithData = {};

    for (final session in recentSessions) {
      final weekday = session.start.weekday;
      if (weekday > 5) continue; // Only Mon-Fri

      final sessionEnd = session.end ?? session.start.add(const Duration(hours: 2)); // estimate if active

      // For each hour slot (10-22) that this session overlaps
      for (int hour = 10; hour <= 22; hour++) {
        final slotStart = DateTime(session.start.year, session.start.month, session.start.day, hour);
        final slotEnd = slotStart.add(const Duration(hours: 1));

        if (session.overlaps(slotStart, slotEnd)) {
          final overlap = session.overlapDuration(slotStart, slotEnd);
          final hours = overlap.inMinutes / 60.0;

          deviceHoursByWeekdayHour
              .putIfAbsent(weekday, () => {})
              .update(hour, (v) => v + hours, ifAbsent: () => hours);

          daysWithData
              .putIfAbsent(weekday, () => {})
              .update(hour, (v) => v + 1, ifAbsent: () => 1);
        }
      }
    }

    // Find the weekday/hour with lowest average occupancy (need at least 3 days of data)
    double minOccupancy = 1.0;
    int bestWeekday = 1;
    int bestHour = 10;
    bool found = false;

    for (int weekday = 1; weekday <= 5; weekday++) {
      for (int hour = 10; hour <= 22; hour++) {
        final days = daysWithData[weekday]?[hour] ?? 0;
        if (days < 3) continue; // Minimum 3 weeks of data

        final totalDeviceHours = deviceHoursByWeekdayHour[weekday]?[hour] ?? 0;
        final avgOccupancy = totalDeviceHours / (days * totalDevices);

        if (avgOccupancy < minOccupancy) {
          minOccupancy = avgOccupancy;
          bestWeekday = weekday;
          bestHour = hour;
          found = true;
        }
      }
    }

    if (!found) return null;

    final occupancyPct = (minOccupancy * 100).round();

    return StoryCard(
      id: id,
      headline: formatHeadlineQuietTime(),
      mainValue: '${_weekdayName(bestWeekday)} at ${bestHour}:00',
      period: 'Last 4 Weeks (Weekdays)',
      details: [
        StoryDetail(
          label: 'Occupancy',
          value: formatDetailQuietSlot(bestWeekday, bestHour, occupancyPct),
        ),
        StoryDetail(
          label: 'Devices Free',
          value: '${((1 - minOccupancy) * totalDevices).round()} of $totalDevices',
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }

  String _weekdayName(int weekday) {
    const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday];
  }
}