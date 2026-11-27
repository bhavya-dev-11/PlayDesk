import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/stories/story_card.dart';

/// Configuration for which stories appear in which time slot.
/// Primary stories are tried first; reserve pool fills gaps.
class BatchConfig {
  final List<String> primary;
  final List<String> reserve;

  const BatchConfig({
    required this.primary,
    required this.reserve,
  });

  /// All story IDs in order (primary first, then reserve).
  List<String> get all => [...primary, ...reserve];
}

/// Story batch configurations for each day/slot combination.
/// Day 1 Morning (10:00) - 3 primary stories
const _day1Morning = BatchConfig(
  primary: [
    'money_collected_yesterday',
    'best_selling_food_yesterday',
    'top_pc_playtime_yesterday',
  ],
  reserve: [
    'most_played_game_yesterday',
    'collections_upi_cash_yesterday',
    'busiest_hour_closer_yesterday',
  ],
);

/// Day 1 Evening (17:30) - 3 primary stories
const _day1Evening = BatchConfig(
  primary: [
    'group_bookings_tonight',
    'extended_sessions_today',
    'packages_expiring_weekend',
  ],
  reserve: [
    'free_ps5_walkins_7_8pm',
    'bills_with_food_today',
    'unpaid_completed_sessions',
  ],
);

/// Day 2 Morning (10:00) - 3 primary stories
const _day2Morning = BatchConfig(
  primary: [
    'quiet_time_offer',
    'most_played_game_yesterday',
    'busiest_hour_closer_yesterday',
  ],
  reserve: [
    'money_collected_yesterday',
    'best_selling_food_yesterday',
    'top_pc_playtime_yesterday',
    'collections_upi_cash_yesterday',
  ],
);

/// Day 2 Evening (17:30) - 3 primary stories
const _day2Evening = BatchConfig(
  primary: [
    'free_ps5_walkins_7_8pm',
    'bills_with_food_today',
    'unpaid_completed_sessions',
  ],
  reserve: [
    'group_bookings_tonight',
    'extended_sessions_today',
    'packages_expiring_weekend',
  ],
);

/// Day 3 Morning (10:00) - 3 primary stories
const _day3Morning = BatchConfig(
  primary: [
    'second_visit_returners_yesterday',
    'common_session_length',
    'collections_upi_cash_yesterday',
  ],
  reserve: [
    'money_collected_yesterday',
    'best_selling_food_yesterday',
    'top_pc_playtime_yesterday',
    'most_played_game_yesterday',
    'busiest_hour_closer_yesterday',
  ],
);

/// Day 3 Evening (17:30) - 3 primary stories
const _day3Evening = BatchConfig(
  primary: [
    'tenth_visit_milestone_today',
    'cancellation_freed_time_evening',
    'collections_vs_last_week_530pm',
  ],
  reserve: [
    'group_bookings_tonight',
    'extended_sessions_today',
    'packages_expiring_weekend',
    'free_ps5_walkins_7_8pm',
    'bills_with_food_today',
    'unpaid_completed_sessions',
  ],
);

/// Get the batch configuration for a given day and slot.
BatchConfig getBatchConfig(int day, Slot slot) {
  switch (day) {
    case 1:
      return slot == Slot.morning ? _day1Morning : _day1Evening;
    case 2:
      return slot == Slot.morning ? _day2Morning : _day2Evening;
    case 3:
      return slot == Slot.morning ? _day3Morning : _day3Evening;
    default:
      throw ArgumentError('Invalid day: $day (must be 1, 2, or 3)');
  }
}