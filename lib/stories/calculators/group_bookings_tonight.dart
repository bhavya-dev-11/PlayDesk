import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Tonight's upcoming group bookings (after 5:30 PM).
class GroupBookingsTonightCalculator extends StoryCalculator {
  @override
  String get id => 'group_bookings_tonight';

  @override
  bool supportedAt(SimClock clock) => clock.slot == Slot.evening;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final now = clock.now; // 5:30 PM today
    final todayEnd = clock.today.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    // Confirmed bookings starting after now (5:30 PM) today
    final tonightBookings = snapshot.confirmedBookings.where((b) {
      return b.start.isAfter(now) && !b.start.isAfter(todayEnd) && b.groupSize >= 2;
    }).toList();

    if (tonightBookings.isEmpty) return null;

    // Sort by start time
    tonightBookings.sort((a, b) => a.start.compareTo(b.start));

    final count = tonightBookings.length;
    final firstBooking = tonightBookings.first;

    return StoryCard(
      id: id,
      headline: formatHeadlineGroupBookings(),
      mainValue: formatNumber(count),
      period: 'Tonight',
      details: [
        StoryDetail(
          label: 'Group Bookings',
          value: formatDetailBillsClosed(count),
        ),
        StoryDetail(
          label: 'First Starts',
          value: formatDetailFirstStartsAt(firstBooking.start),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }
}