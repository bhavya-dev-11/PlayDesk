import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Most-played game by hours yesterday.
class MostPlayedGameYesterdayCalculator extends StoryCalculator {
  @override
  String get id => 'most_played_game_yesterday';

  @override
  bool supportedAt(SimClock clock) => true;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final yesterdayStart = clock.yesterday;
    final yesterdayEnd = clock.yesterdayEnd;

    // Game -> total hours played yesterday
    final Map<String, Duration> gameHours = {};

    for (final session in snapshot.sessions) {
      if (!session.overlaps(yesterdayStart, yesterdayEnd)) continue;

      final overlap = session.overlapDuration(yesterdayStart, yesterdayEnd);
      if (overlap > Duration.zero) {
        gameHours.update(
          session.game,
          (v) => v + overlap,
          ifAbsent: () => overlap,
        );
      }
    }

    if (gameHours.isEmpty) return null;

    // Sort by hours descending
    final entries = gameHours.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    final topGame = entries.first;

    return StoryCard(
      id: id,
      headline: formatHeadlineMostPlayedGame(),
      mainValue: topGame.key,
      period: 'Yesterday',
      details: [
        StoryDetail(
          label: 'Play Time',
          value: formatDetailGameHours(topGame.value),
        ),
        StoryDetail(
          label: 'Sessions',
          value: formatNumber(_countSessionsForGame(snapshot, topGame.key, yesterdayStart, yesterdayEnd)),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }

  int _countSessionsForGame(VenueSnapshot snapshot, String game, DateTime start, DateTime end) {
    return snapshot.sessions.where((s) {
      return s.game == game && s.overlaps(start, end);
    }).length;
  }
}