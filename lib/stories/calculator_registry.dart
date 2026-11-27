// Calculator registry - separate file to avoid analyzer issues with stories.dart exports
import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/calculators/money_collected_yesterday.dart';
import 'package:playdesk_owner_stories/stories/calculators/best_selling_food_yesterday.dart';
import 'package:playdesk_owner_stories/stories/calculators/top_pc_playtime_yesterday.dart';
import 'package:playdesk_owner_stories/stories/calculators/group_bookings_tonight.dart';
import 'package:playdesk_owner_stories/stories/calculators/extended_sessions_today.dart';
import 'package:playdesk_owner_stories/stories/calculators/packages_expiring_weekend.dart';
import 'package:playdesk_owner_stories/stories/calculators/quiet_time_offer.dart';
import 'package:playdesk_owner_stories/stories/calculators/most_played_game_yesterday.dart';
import 'package:playdesk_owner_stories/stories/calculators/busiest_hour_closer_yesterday.dart';
import 'package:playdesk_owner_stories/stories/calculators/free_ps5_walkins_7_8pm.dart';
import 'package:playdesk_owner_stories/stories/calculators/bills_with_food_today.dart';
import 'package:playdesk_owner_stories/stories/calculators/unpaid_completed_sessions.dart';
import 'package:playdesk_owner_stories/stories/calculators/second_visit_returners_yesterday.dart';
import 'package:playdesk_owner_stories/stories/calculators/common_session_length.dart';
import 'package:playdesk_owner_stories/stories/calculators/collections_upi_cash_yesterday.dart';
import 'package:playdesk_owner_stories/stories/calculators/tenth_visit_milestone_today.dart';
import 'package:playdesk_owner_stories/stories/calculators/cancellation_freed_time_evening.dart';
import 'package:playdesk_owner_stories/stories/calculators/collections_vs_last_week_530pm.dart';

/// Registry of all story calculators by ID.
final Map<String, StoryCalculator> allCalculators = {
  MoneyCollectedYesterdayCalculator().id: MoneyCollectedYesterdayCalculator(),
  BestSellingFoodYesterdayCalculator().id: BestSellingFoodYesterdayCalculator(),
  TopPcPlaytimeYesterdayCalculator().id: TopPcPlaytimeYesterdayCalculator(),
  GroupBookingsTonightCalculator().id: GroupBookingsTonightCalculator(),
  ExtendedSessionsTodayCalculator().id: ExtendedSessionsTodayCalculator(),
  PackagesExpiringWeekendCalculator().id: PackagesExpiringWeekendCalculator(),
  QuietTimeOfferCalculator().id: QuietTimeOfferCalculator(),
  MostPlayedGameYesterdayCalculator().id: MostPlayedGameYesterdayCalculator(),
  BusiestHourCloserYesterdayCalculator().id: BusiestHourCloserYesterdayCalculator(),
  FreePs5Walkins78pmCalculator().id: FreePs5Walkins78pmCalculator(),
  BillsWithFoodTodayCalculator().id: BillsWithFoodTodayCalculator(),
  UnpaidCompletedSessionsCalculator().id: UnpaidCompletedSessionsCalculator(),
  SecondVisitReturnersYesterdayCalculator().id: SecondVisitReturnersYesterdayCalculator(),
  CommonSessionLengthCalculator().id: CommonSessionLengthCalculator(),
  CollectionsUpiCashYesterdayCalculator().id: CollectionsUpiCashYesterdayCalculator(),
  TenthVisitMilestoneTodayCalculator().id: TenthVisitMilestoneTodayCalculator(),
  CancellationFreedTimeEveningCalculator().id: CancellationFreedTimeEveningCalculator(),
  CollectionsVsLastWeek530pmCalculator().id: CollectionsVsLastWeek530pmCalculator(),
};