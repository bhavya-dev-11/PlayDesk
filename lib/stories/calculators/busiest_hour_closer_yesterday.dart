import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Who closed most bills in the busiest hour yesterday.
/// Tie-break: alphabetical by staff name.
class BusiestHourCloserYesterdayCalculator extends StoryCalculator {
  @override
  String get id => 'busiest_hour_closer_yesterday';

  @override
  bool supportedAt(SimClock clock) => true;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final yesterdayStart = clock.yesterday;
    final yesterdayEnd = clock.yesterdayEnd;

    // Get bills closed yesterday
    final yesterdayClosedBills = snapshot.closedBills.where((b) {
      return b.closedAt != null &&
          !b.closedAt!.isBefore(yesterdayStart) &&
          !b.closedAt!.isAfter(yesterdayEnd) &&
          b.closedBy != null &&
          b.closedBy!.isNotEmpty;
    }).toList();

    if (yesterdayClosedBills.isEmpty) return null;

    // Count bills per hour (0-23)
    final Map<int, int> billsPerHour = {};
    for (final bill in yesterdayClosedBills) {
      final hour = bill.closedAt!.hour;
      billsPerHour[hour] = (billsPerHour[hour] ?? 0) + 1;
    }

    // Find busiest hour
    int busiestHour = 0;
    int maxBills = 0;
    for (final entry in billsPerHour.entries) {
      if (entry.value > maxBills || (entry.value == maxBills && entry.key < busiestHour)) {
        maxBills = entry.value;
        busiestHour = entry.key;
      }
    }

    // In that hour, count bills per closer
    final Map<String, int> closerCounts = {};
    for (final bill in yesterdayClosedBills) {
      if (bill.closedAt!.hour == busiestHour && bill.closedBy != null) {
        closerCounts[bill.closedBy!] = (closerCounts[bill.closedBy!] ?? 0) + 1;
      }
    }

    if (closerCounts.isEmpty) return null;

    // Find top closer (tie-break: alphabetical)
    final closerEntries = closerCounts.entries.toList();
    closerEntries.sort((a, b) {
      if (b.value != a.value) return b.value.compareTo(a.value);
      return a.key.compareTo(b.key);
    });

    final topCloser = closerEntries.first;

    return StoryCard(
      id: id,
      headline: formatHeadlineBusiestHourCloser(),
      mainValue: topCloser.key,
      period: 'Yesterday (${busiestHour}:00-${busiestHour + 1}:00)',
      details: [
        StoryDetail(
          label: 'Bills Closed',
          value: formatDetailBillsClosed(topCloser.value),
        ),
        StoryDetail(
          label: 'Hour Total',
          value: formatDetailBillsClosed(maxBills),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }
}