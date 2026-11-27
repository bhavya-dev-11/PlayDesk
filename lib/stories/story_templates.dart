import 'package:intl/intl.dart';

import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/theme.dart';

/// Reusable text templates for story cards.
/// All user-facing strings should come from here.

/// Headline templates
const String _headlineMoneyCollected = 'Money Collected';
const String _headlineBestSellingFood = 'Top Seller';
const String _headlineTopPcPlaytime = 'Most Played PC';
const String _headlineGroupBookings = 'Group Bookings Tonight';
const String _headlineExtendedSessions = 'Extended Sessions';
const String _headlinePackagesExpiring = 'Packages Expiring';
const String _headlineQuietTime = 'Quiet Time for Offer';
const String _headlineMostPlayedGame = 'Most Played Game';
const String _headlineBusiestHourCloser = 'Busiest Hour Closer';
const String _headlineFreePs5Walkins = 'Free PS5s for Walk-ins';
const String _headlineBillsWithFood = 'Gaming Bills with Food';
const String _headlineUnpaidCompleted = 'Unpaid on Completed';
const String _headlineSecondVisit = '2nd Visit Returners';
const String _headlineCommonSessionLength = 'Popular Session Length';
const String _headlineCollectionsUpiCash = 'Collections: UPI vs Cash';
const String _headlineTenthVisit = '10th Visit Milestone';
const String _headlineCancellationFreed = 'Time Freed by Cancellations';
const String _headlineCollectionsVsLastWeek = 'Collections vs Last Week';

/// Detail templates
const String _detailYesterdayGamingFood =
    'Gaming: {gaming} • Food: {food}';
const String _detailUnitsSold = '{units} {unitLabel} sold';
const String _detailRevenue = 'Revenue: {revenue}';
const String _detailHoursPlayed = '{hours} played';
const String _detailFirstStartsAt = 'First at {time}';
const String _detailPlayersExtended = '{count} {playerLabel} extended';
const String _detailExpiringCount = '{count} {packageLabel} expiring {period}';
const String _detailQuietSlot = 'Weekday {day} at {hour}:00 — {occupancy}% occupancy';
const String _detailGameHours = '{hours} hrs total';
const String _detailBillsClosed = '{count} bills closed';
const String _detailFreeCount = '{free} of {total} PS5s free';
const String _detailFoodPercent = '{percent}% of gaming bills';
const String _detailUnpaidAmount = '{amount} outstanding';
const String _detailPlayersCount = '{count} {playerLabel}';
const String _detailMostBooked = '{length} — {count} bookings';
const String _detailUpiCashSplit = 'UPI: {upi}% • Cash: {cash}%';
const String _detailMilestonePlayers = '{count} {playerLabel} hit 10 visits';
const String _detailFreedHours = '{hours} freed up';
const String _detailWeeklyDiff = '{diff} ({pct}%) vs last week';

/// Singular/plural labels
const String _labelPlayer = 'player';
const String _labelPlayers = 'players';
const String _labelSession = 'session';
const String _labelSessions = 'sessions';
const String _labelBooking = 'booking';
const String _labelBookings = 'bookings';
const String _labelPackage = 'package';
const String _labelPackages = 'packages';
const String _labelHour = 'hour';
const String _labelHours = 'hours';
const String _labelUnit = 'unit';
const String _labelUnits = 'units';

/// Accent color assignments for each story (for visual variety)
const Map<String, StoryAccent> _storyAccents = {
  'money_collected_yesterday': StoryAccent.amber,
  'best_selling_food_yesterday': StoryAccent.orange,
  'top_pc_playtime_yesterday': StoryAccent.blue,
  'group_bookings_tonight': StoryAccent.purple,
  'extended_sessions_today': StoryAccent.green,
  'packages_expiring_weekend': StoryAccent.red,
  'quiet_time_offer': StoryAccent.teal,
  'most_played_game_yesterday': StoryAccent.pink,
  'busiest_hour_closer_yesterday': StoryAccent.amber,
  'free_ps5_walkins_7_8pm': StoryAccent.blue,
  'bills_with_food_today': StoryAccent.orange,
  'unpaid_completed_sessions': StoryAccent.red,
  'second_visit_returners_yesterday': StoryAccent.green,
  'common_session_length': StoryAccent.purple,
  'collections_upi_cash_yesterday': StoryAccent.teal,
  'tenth_visit_milestone_today': StoryAccent.pink,
  'cancellation_freed_time_evening': StoryAccent.amber,
  'collections_vs_last_week_530pm': StoryAccent.blue,
};

/// Get the accent color for a story ID.
StoryAccent accentForStory(String storyId) {
  return _storyAccents[storyId] ?? StoryAccent.amber;
}

/// Get photo asset for a story (maps to assets/photos/).
String photoForStory(String storyId) {
  // Map story IDs to photo filenames
  const photoMap = {
    'money_collected_yesterday': 'story1.png',
    'best_selling_food_yesterday': 'story2.png',
    'top_pc_playtime_yesterday': 'story3.png',
    'group_bookings_tonight': 'story4.png',
    'extended_sessions_today': 'story5.png',
    'packages_expiring_weekend': 'story6.png',
    'quiet_time_offer': 'story7.png',
    'most_played_game_yesterday': 'story8.png',
    'busiest_hour_closer_yesterday': 'story9.png',
    'free_ps5_walkins_7_8pm': 'story10.png',
    'bills_with_food_today': 'story11.png',
    'unpaid_completed_sessions': 'story12.png',
    'second_visit_returners_yesterday': 'story13.png',
    'common_session_length': 'story14.png',
    'collections_upi_cash_yesterday': 'story15.png',
    'tenth_visit_milestone_today': 'story16.png',
    'cancellation_freed_time_evening': 'story17.png',
    'collections_vs_last_week_530pm': 'story18.png',
  };
  return 'assets/photos/${photoMap[storyId] ?? 'default.jpg'}';
}

/// Format helpers for templates

String formatHeadlineMoneyCollected() => _headlineMoneyCollected;

String formatHeadlineBestSellingFood() => _headlineBestSellingFood;

String formatHeadlineTopPcPlaytime() => _headlineTopPcPlaytime;

String formatHeadlineGroupBookings() => _headlineGroupBookings;

String formatHeadlineExtendedSessions() => _headlineExtendedSessions;

String formatHeadlinePackagesExpiring() => _headlinePackagesExpiring;

String formatHeadlineQuietTime() => _headlineQuietTime;

String formatHeadlineMostPlayedGame() => _headlineMostPlayedGame;

String formatHeadlineBusiestHourCloser() => _headlineBusiestHourCloser;

String formatHeadlineFreePs5Walkins() => _headlineFreePs5Walkins;

String formatHeadlineBillsWithFood() => _headlineBillsWithFood;

String formatHeadlineUnpaidCompleted() => _headlineUnpaidCompleted;

String formatHeadlineSecondVisit() => _headlineSecondVisit;

String formatHeadlineCommonSessionLength() => _headlineCommonSessionLength;

String formatHeadlineCollectionsUpiCash() => _headlineCollectionsUpiCash;

String formatHeadlineTenthVisit() => _headlineTenthVisit;

String formatHeadlineCancellationFreed() => _headlineCancellationFreed;

String formatHeadlineCollectionsVsLastWeek() => _headlineCollectionsVsLastWeek;

/// Detail formatters

String formatDetailYesterdayGamingFood(int gaming, int food) => _detailYesterdayGamingFood
    .replaceAll('{gaming}', formatINR(gaming))
    .replaceAll('{food}', formatINR(food));

String formatDetailUnitsSold(int units, String itemName) {
  final unitLabel = units == 1 ? _labelUnit : _labelUnits;
  return _detailUnitsSold
      .replaceAll('{units}', formatNumber(units))
      .replaceAll('{unitLabel}', unitLabel);
}

String formatDetailRevenue(int revenue) => _detailRevenue
    .replaceAll('{revenue}', formatINR(revenue));

String formatDetailHoursPlayed(Duration duration) => _detailHoursPlayed
    .replaceAll('{hours}', formatDuration(duration));

String formatDetailFirstStartsAt(DateTime time) => _detailFirstStartsAt
    .replaceAll('{time}', formatTime(time));

String formatDetailPlayersExtended(int count) {
  final label = count == 1 ? _labelPlayer : _labelPlayers;
  return _detailPlayersExtended
      .replaceAll('{count}', formatNumber(count))
      .replaceAll('{playerLabel}', label);
}

String formatDetailExpiringCount(int count, String period) {
  final label = count == 1 ? _labelPackage : _labelPackages;
  return _detailExpiringCount
      .replaceAll('{count}', formatNumber(count))
      .replaceAll('{packageLabel}', label)
      .replaceAll('{period}', period);
}

String formatDetailQuietSlot(int weekday, int hour, int occupancy) {
  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return _detailQuietSlot
      .replaceAll('{day}', dayNames[weekday - 1])
      .replaceAll('{hour}', hour.toString().padLeft(2, '0'))
      .replaceAll('{occupancy}', occupancy.toString());
}

String formatDetailGameHours(Duration duration) => _detailGameHours
    .replaceAll('{hours}', formatDuration(duration));

String formatDetailBillsClosed(int count) => _detailBillsClosed
    .replaceAll('{count}', formatNumber(count));

String formatDetailFreeCount(int free, int total) => _detailFreeCount
    .replaceAll('{free}', formatNumber(free))
    .replaceAll('{total}', formatNumber(total));

String formatDetailFoodPercent(double percent) => _detailFoodPercent
    .replaceAll('{percent}', formatDecimal(percent, fractionDigits: 1));

String formatDetailUnpaidAmount(int amount) => _detailUnpaidAmount
    .replaceAll('{amount}', formatINR(amount));

String formatDetailPlayersCount(int count) {
  final label = count == 1 ? _labelPlayer : _labelPlayers;
  return _detailPlayersCount
      .replaceAll('{count}', formatNumber(count))
      .replaceAll('{playerLabel}', label);
}

String formatDetailMostBooked(String length, int count) => _detailMostBooked
    .replaceAll('{length}', length)
    .replaceAll('{count}', formatNumber(count));

String formatDetailUpiCashSplit(double upiPct, double cashPct) => _detailUpiCashSplit
    .replaceAll('{upi}', formatDecimal(upiPct, fractionDigits: 1))
    .replaceAll('{cash}', formatDecimal(cashPct, fractionDigits: 1));

String formatDetailMilestonePlayers(int count) {
  final label = count == 1 ? _labelPlayer : _labelPlayers;
  return _detailMilestonePlayers
      .replaceAll('{count}', formatNumber(count))
      .replaceAll('{playerLabel}', label);
}

String formatDetailFreedHours(Duration duration) => _detailFreedHours
    .replaceAll('{hours}', formatDuration(duration));

String formatDetailWeeklyDiff(int diff, double pct) => _detailWeeklyDiff
    .replaceAll('{diff}', formatChange(diff))
    .replaceAll('{pct}', formatDecimal(pct.abs(), fractionDigits: 1));