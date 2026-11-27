import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Money collected yesterday (payments received yesterday).
class MoneyCollectedYesterdayCalculator extends StoryCalculator {
  @override
  String get id => 'money_collected_yesterday';

  @override
  bool supportedAt(SimClock clock) => true;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final yesterdayStart = clock.yesterday;
    final yesterdayEnd = clock.yesterdayEnd;

    // Filter payments that occurred yesterday
    final yesterdayPayments = snapshot.allPayments.where((p) {
      return !p.paidAt.isBefore(yesterdayStart) && !p.paidAt.isAfter(yesterdayEnd);
    }).toList();

    if (yesterdayPayments.isEmpty) return null;

    final totalCollected = yesterdayPayments.fold(0, (sum, p) => sum + p.amount);

    // Calculate gaming vs food by looking at bills closed yesterday
    final yesterdayClosedBills = snapshot.closedBills.where((b) {
      return b.closedAt != null &&
          !b.closedAt!.isBefore(yesterdayStart) &&
          !b.closedAt!.isAfter(yesterdayEnd);
    }).toList();

    int gamingTotal = 0;
    int foodTotal = 0;

    if (yesterdayClosedBills.isNotEmpty) {
      for (final bill in yesterdayClosedBills) {
        gamingTotal += bill.gamingAmount;
        foodTotal += bill.foodAmount;
      }
    } else {
      // Fallback: estimate from payment ratio if no bills closed yesterday
      // This shouldn't normally happen but handles edge cases
      final totalBills = snapshot.bills.where((b) => b.isClosed).toList();
      if (totalBills.isNotEmpty) {
        final totalGaming = totalBills.fold(0, (sum, b) => sum + b.gamingAmount);
        final totalFood = totalBills.fold(0, (sum, b) => sum + b.foodAmount);
        final totalAll = totalGaming + totalFood;
        if (totalAll > 0) {
          gamingTotal = (totalCollected * totalGaming / totalAll).round();
          foodTotal = totalCollected - gamingTotal;
        }
      }
    }

    return StoryCard(
      id: id,
      headline: formatHeadlineMoneyCollected(),
      mainValue: formatINR(totalCollected),
      period: 'Yesterday',
      details: [
        StoryDetail(
          label: 'Breakdown',
          value: formatDetailYesterdayGamingFood(gamingTotal, foodTotal),
        ),
        StoryDetail(
          label: 'Transactions',
          value: formatNumber(yesterdayPayments.length),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }
}