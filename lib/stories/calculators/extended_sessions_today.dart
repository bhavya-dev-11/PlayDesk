import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Players who extended a session today.
class ExtendedSessionsTodayCalculator extends StoryCalculator {
  @override
  String get id => 'extended_sessions_today';

  @override
  bool supportedAt(SimClock clock) => clock.slot == Slot.evening;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final todayStart = clock.today;
    final todayEnd = clock.today.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    // Find sessions today that were extended
    final extendedPlayers = <String>{};
    for (final session in snapshot.sessions) {
      // Session must have started today
      if (session.start.isBefore(todayStart) || session.start.isAfter(todayEnd)) continue;
      // Session must have been extended
      if (!session.wasExtended) continue;
      // Extension must have happened today
      final todayExtensions = session.extendedAt.where((ext) {
        return !ext.isBefore(todayStart) && !ext.isAfter(todayEnd);
      }).toList();
      if (todayExtensions.isNotEmpty) {
        extendedPlayers.add(session.playerId);
      }
    }

    if (extendedPlayers.isEmpty) return null;

    return StoryCard(
      id: id,
      headline: formatHeadlineExtendedSessions(),
      mainValue: formatNumber(extendedPlayers.length),
      period: 'Today',
      details: [
        StoryDetail(
          label: 'Players Extended',
          value: formatDetailPlayersExtended(extendedPlayers.length),
        ),
        StoryDetail(
          label: 'Extensions',
          value: _countTotalExtensions(snapshot, todayStart, todayEnd, extendedPlayers).toString(),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }

  int _countTotalExtensions(VenueSnapshot snapshot, DateTime start, DateTime end, Set<String> playerIds) {
    int count = 0;
    for (final session in snapshot.sessions) {
      if (!playerIds.contains(session.playerId)) continue;
      if (session.start.isBefore(start) || session.start.isAfter(end)) continue;
      count += session.extendedAt.where((ext) => !ext.isBefore(start) && !ext.isAfter(end)).length;
    }
    return count;
  }
}