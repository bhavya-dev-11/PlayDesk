import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Booked time freed by evening cancellations today.
class CancellationFreedTimeEveningCalculator extends StoryCalculator {
  @override
  String get id => 'cancellation_freed_time_evening';

  @override
  bool supportedAt(SimClock clock) => clock.slot == Slot.evening;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final todayStart = clock.today;
    final now = clock.now; // 5:30 PM

    // Bookings cancelled today (after morning, up to now)
    final cancelledBookings = snapshot.bookings.where((b) {
      return b.isCancelled &&
          b.cancelledAt != null &&
          !b.cancelledAt!.isBefore(todayStart) &&
          !b.cancelledAt!.isAfter(now);
    }).toList();

    if (cancelledBookings.isEmpty) return null;

    // Sum the duration of cancelled bookings
    Duration totalFreed = Duration.zero;
    for (final booking in cancelledBookings) {
      totalFreed += booking.duration;
    }

    return StoryCard(
      id: id,
      headline: formatHeadlineCancellationFreed(),
      mainValue: formatDuration(totalFreed),
      period: 'Today (till 5:30 PM)',
      details: [
        StoryDetail(
          label: 'Freed Up',
          value: formatDetailFreedHours(totalFreed),
        ),
        StoryDetail(
          label: 'Cancellations',
          value: formatNumber(cancelledBookings.length),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }
}