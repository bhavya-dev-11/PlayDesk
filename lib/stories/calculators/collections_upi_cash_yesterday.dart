import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';
import 'package:playdesk_owner_stories/data/models.dart';

/// Story: Yesterday's collections by UPI and cash.
class CollectionsUpiCashYesterdayCalculator extends StoryCalculator {
  @override
  String get id => 'collections_upi_cash_yesterday';

  @override
  bool supportedAt(SimClock clock) => true;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final yesterdayStart = clock.yesterday;
    final yesterdayEnd = clock.yesterdayEnd;

    final yesterdayPayments = snapshot.allPayments.where((p) {
      return !p.paidAt.isBefore(yesterdayStart) && !p.paidAt.isAfter(yesterdayEnd);
    }).toList();

    if (yesterdayPayments.isEmpty) return null;

    int upiTotal = 0;
    int cashTotal = 0;

    for (final payment in yesterdayPayments) {
      if (payment.method == PaymentMethod.upi) {
        upiTotal += payment.amount;
      } else {
        cashTotal += payment.amount;
      }
    }

    final total = upiTotal + cashTotal;
    final upiPct = total > 0 ? (upiTotal / total * 100) : 0.0;
    final cashPct = total > 0 ? (cashTotal / total * 100) : 0.0;

    return StoryCard(
      id: id,
      headline: formatHeadlineCollectionsUpiCash(),
      mainValue: formatINR(total),
      period: 'Yesterday',
      details: [
        StoryDetail(
          label: 'Split',
          value: formatDetailUpiCashSplit(upiPct, cashPct),
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