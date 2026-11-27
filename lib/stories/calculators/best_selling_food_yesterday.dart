import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Best-selling food item yesterday (by units sold).
/// Tie-break: revenue, then alphabetical.
class BestSellingFoodYesterdayCalculator extends StoryCalculator {
  @override
  String get id => 'best_selling_food_yesterday';

  @override
  bool supportedAt(SimClock clock) => true;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final yesterdayStart = clock.yesterday;
    final yesterdayEnd = clock.yesterdayEnd;

    // Get food orders from yesterday
    final yesterdayFoodOrders = snapshot.allFoodOrders.where((o) {
      return !o.orderedAt.isBefore(yesterdayStart) && !o.orderedAt.isAfter(yesterdayEnd);
    }).toList();

    if (yesterdayFoodOrders.isEmpty) return null;

    // Group by item name
    final Map<String, _ItemStats> statsByItem = {};
    for (final order in yesterdayFoodOrders) {
      final stats = statsByItem.putIfAbsent(order.itemName, () => _ItemStats());
      stats.units += order.qty;
      stats.revenue += order.lineTotal;
    }

    // Find top item: most units, then revenue, then alphabetical
    final entries = statsByItem.entries.toList();
    entries.sort((a, b) {
      // Most units first
      if (b.value.units != a.value.units) {
        return b.value.units.compareTo(a.value.units);
      }
      // Then revenue
      if (b.value.revenue != a.value.revenue) {
        return b.value.revenue.compareTo(a.value.revenue);
      }
      // Then alphabetical
      return a.key.compareTo(b.key);
    });

    final topItem = entries.first;
    final topStats = topItem.value;

    return StoryCard(
      id: id,
      headline: formatHeadlineBestSellingFood(),
      mainValue: topItem.key,
      period: 'Yesterday',
      details: [
        StoryDetail(
          label: 'Units Sold',
          value: formatDetailUnitsSold(topStats.units, topItem.key),
        ),
        StoryDetail(
          label: 'Revenue',
          value: formatDetailRevenue(topStats.revenue),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }
}

class _ItemStats {
  int units = 0;
  int revenue = 0;
}