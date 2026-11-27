import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Players who came back for a 2nd visit yesterday.
/// Visit definition: A player's sessions on a single calendar day = 1 visit.
/// So we count distinct days a player had sessions.
class SecondVisitReturnersYesterdayCalculator extends StoryCalculator {
  @override
  String get id => 'second_visit_returners_yesterday';

  @override
  bool supportedAt(SimClock clock) => true;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final yesterdayStart = clock.yesterday;
    final yesterdayEnd = clock.yesterdayEnd;

    // Get all sessions yesterday grouped by player
    final Map<String, List<DateTime>> sessionsByPlayer = {};
    for (final session in snapshot.sessions) {
      if (!session.overlaps(yesterdayStart, yesterdayEnd)) continue;
      sessionsByPlayer.putIfAbsent(session.playerId, () => []).add(session.start);
    }

    // For each player, count their lifetime visits (distinct days with sessions) up to yesterday end
    final secondVisitPlayers = <String>[];

    for (final entry in sessionsByPlayer.entries) {
      final playerId = entry.key;
      final player = snapshot.player(playerId);
      if (player == null) continue;

      // Get all sessions for this player up to yesterday end
      final allSessions = snapshot.sessionsForPlayer(playerId)
          .where((s) => !s.start.isAfter(yesterdayEnd))
          .toList();

      // Count distinct days (visits)
      final visitDays = <String>{};
      for (final session in allSessions) {
        final dayKey = '${session.start.year}-${session.start.month}-${session.start.day}';
        visitDays.add(dayKey);
      }

      if (visitDays.length == 2) {
        secondVisitPlayers.add(playerId);
      }
    }

    if (secondVisitPlayers.isEmpty) return null;

    return StoryCard(
      id: id,
      headline: formatHeadlineSecondVisit(),
      mainValue: formatNumber(secondVisitPlayers.length),
      period: 'Yesterday',
      details: [
        StoryDetail(
          label: 'Returners',
          value: formatDetailPlayersCount(secondVisitPlayers.length),
        ),
        StoryDetail(
          label: 'Names',
          value: secondVisitPlayers
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