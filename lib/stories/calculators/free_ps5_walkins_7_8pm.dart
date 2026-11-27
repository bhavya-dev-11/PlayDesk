import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: PS5s free for walk-ins 7-8 PM today.
class FreePs5Walkins78pmCalculator extends StoryCalculator {
  @override
  String get id => 'free_ps5_walkins_7_8pm';

  @override
  bool supportedAt(SimClock clock) => clock.slot == Slot.evening;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final today = clock.today;
    final windowStart = DateTime(today.year, today.month, today.day, 19, 0); // 7:00 PM
    final windowEnd = DateTime(today.year, today.month, today.day, 20, 0); // 8:00 PM

    final ps5Devices = snapshot.ps5Devices;
    if (ps5Devices.isEmpty) return null;

    int freeCount = 0;
    for (final device in ps5Devices) {
      bool isOccupied = false;

      // Check sessions overlapping 7-8 PM
      for (final session in snapshot.sessionsForDevice(device.id)) {
        if (session.overlaps(windowStart, windowEnd)) {
          isOccupied = true;
          break;
        }
      }

      // Check bookings overlapping 7-8 PM
      if (!isOccupied) {
        for (final booking in snapshot.bookingsForDevice(device.id)) {
          if (booking.isConfirmed && booking.overlaps(windowStart, windowEnd)) {
            isOccupied = true;
            break;
          }
        }
      }

      if (!isOccupied) freeCount++;
    }

    return StoryCard(
      id: id,
      headline: formatHeadlineFreePs5Walkins(),
      mainValue: formatNumber(freeCount),
      period: 'Today 7-8 PM',
      details: [
        StoryDetail(
          label: 'Free PS5s',
          value: formatDetailFreeCount(freeCount, ps5Devices.length),
        ),
        StoryDetail(
          label: 'Total PS5s',
          value: formatNumber(ps5Devices.length),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }
}