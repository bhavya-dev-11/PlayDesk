import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Players who reached 10th visit today.
/// Visit definition: distinct calendar days with sessions.
/// Returns null if no players hit exactly 10 visits today (card drops).
class TenthVisitMilestoneTodayCalculator extends StoryCalculator {
  @override
  String get id => 'tenth_visit_milestone_today';

  @override
  bool supportedAt(SimClock clock) => clock.slot == Slot.evening;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final todayStart = clock.today;
    final todayEnd = clock.today.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    // Get players who had a session today
    final todayPlayers = <String>{};
    for (final session in snapshot.sessions) {
      if (session.overlaps(todayStart, todayEnd)) {
        todayPlayers.add(session.playerId);
      }
    }

    final milestonePlayers = <String>[];

    for (final playerId in todayPlayers) {
      // Count lifetime visits (distinct days) up to today end
      final allSessions = snapshot.sessionsForPlayer(playerId)
          .where((s) => !s.start.isAfter(todayEnd))
          .toList();

      final visitDays = <String>{};
      for (final session in allSessions) {
        final dayKey = '${session.start.year}-${session.start.month}-${session.start.day}';
        visitDays.add(dayKey);
      }

      if (visitDays.length == 10) {
        milestonePlayers.add(playerId);
      }
    }

    // If no one hit 10th visit, return null (card drops from batch)
    if (milestonePlayers.isEmpty) return null;

    return StoryCard(
      id: id,
      headline: formatHeadlineTenthVisit(),
      mainValue: formatNumber(milestonePlayers.length),
      period: 'Today',
      details: [
        StoryDetail(
          label: 'Milestone Hit',
          value: formatDetailMilestonePlayers(milestonePlayers.length),
        ),
        StoryDetail(
          label: 'Players',
          value: milestonePlayers
              .map((id) => snapshot.player(id)?.name ?? id)
              .take(3)
              .join(', '),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }
}