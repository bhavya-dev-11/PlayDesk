import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Amount still unpaid on completed sessions.
class UnpaidCompletedSessionsCalculator extends StoryCalculator {
  @override
  String get id => 'unpaid_completed_sessions';

  @override
  bool supportedAt(SimClock clock) => clock.slot == Slot.evening;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    // All completed sessions (closed bills) with outstanding balance
    final unpaidBills = snapshot.closedBills.where((b) => b.outstanding > 0).toList();

    if (unpaidBills.isEmpty) return null;

    final totalUnpaid = unpaidBills.fold(0, (sum, b) => sum + b.outstanding);
    final count = unpaidBills.length;

    return StoryCard(
      id: id,
      headline: formatHeadlineUnpaidCompleted(),
      mainValue: formatINR(totalUnpaid),
      period: 'All Time',
      details: [
        StoryDetail(
          label: 'Outstanding',
          value: formatDetailUnpaidAmount(totalUnpaid),
        ),
        StoryDetail(
          label: 'Unpaid Bills',
          value: formatNumber(count),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }
}