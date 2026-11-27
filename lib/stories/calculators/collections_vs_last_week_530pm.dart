import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Collections by 5:30 PM vs same time last week.
class CollectionsVsLastWeek530pmCalculator extends StoryCalculator {
  @override
  String get id => 'collections_vs_last_week_530pm';

  @override
  bool supportedAt(SimClock clock) => clock.slot == Slot.evening;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final todayStart = clock.today;
    final now = clock.now; // 5:30 PM today

    final lastWeekSameDayStart = clock.lastWeekSameDay;
    final lastWeekSameDayNow = clock.lastWeekSameDay.add(
      Duration(hours: now.hour, minutes: now.minute),
    );

    // Collections today up to 5:30 PM
    final todayPayments = snapshot.allPayments.where((p) {
      return !p.paidAt.isBefore(todayStart) && !p.paidAt.isAfter(now);
    }).toList();

    final todayTotal = todayPayments.fold(0, (sum, p) => sum + p.amount);

    // Collections last week same day up to 5:30 PM
    final lastWeekPayments = snapshot.allPayments.where((p) {
      return !p.paidAt.isBefore(lastWeekSameDayStart) && !p.paidAt.isAfter(lastWeekSameDayNow);
    }).toList();

    final lastWeekTotal = lastWeekPayments.fold(0, (sum, p) => sum + p.amount);

    final diff = todayTotal - lastWeekTotal;
    final pct = lastWeekTotal > 0 ? (diff / lastWeekTotal * 100).abs() : 0.0;

    return StoryCard(
      id: id,
      headline: formatHeadlineCollectionsVsLastWeek(),
      mainValue: formatINR(todayTotal),
      period: 'Today vs Last Week (till 5:30 PM)',
      details: [
        StoryDetail(
          label: 'vs Last Week',
          value: formatDetailWeeklyDiff(diff, pct),
        ),
        StoryDetail(
          label: 'Last Week',
          value: formatINR(lastWeekTotal),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }
}