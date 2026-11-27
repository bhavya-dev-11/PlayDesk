import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Gaming bills with food/drinks today.
class BillsWithFoodTodayCalculator extends StoryCalculator {
  @override
  String get id => 'bills_with_food_today';

  @override
  bool supportedAt(SimClock clock) => clock.slot == Slot.evening;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final todayStart = clock.today;
    final todayEnd = clock.today.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    // Bills closed today that have food items
    final todayBillsWithFood = snapshot.closedBills.where((b) {
      return b.closedAt != null &&
          !b.closedAt!.isBefore(todayStart) &&
          !b.closedAt!.isAfter(todayEnd) &&
          b.hasFood;
    }).toList();

    final todayGamingBills = snapshot.closedBills.where((b) {
      return b.closedAt != null &&
          !b.closedAt!.isBefore(todayStart) &&
          !b.closedAt!.isAfter(todayEnd) &&
          b.gamingAmount > 0;
    }).toList();

    if (todayGamingBills.isEmpty) return null;

    final count = todayBillsWithFood.length;
    final total = todayGamingBills.length;
    final percent = (count / total * 100);

    return StoryCard(
      id: id,
      headline: formatHeadlineBillsWithFood(),
      mainValue: formatNumber(count),
      period: 'Today',
      details: [
        StoryDetail(
          label: 'With Food',
          value: formatDetailFoodPercent(percent),
        ),
        StoryDetail(
          label: 'Gaming Bills',
          value: formatRatio(count, total),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }
}