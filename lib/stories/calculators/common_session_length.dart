import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Most frequently booked session length (buckets).
class CommonSessionLengthCalculator extends StoryCalculator {
  @override
  String get id => 'common_session_length';

  @override
  bool supportedAt(SimClock clock) => true;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    // Use all completed sessions (closed bills) for session length
    final sessions = snapshot.sessions.where((s) => s.end != null).toList();

    if (sessions.isEmpty) return null;

    // Bucket durations: 30m, 1h, 2h, 3h, 4h, 5h+
    final Map<String, int> buckets = {
      '30 min': 0,
      '1 hour': 0,
      '2 hours': 0,
      '3 hours': 0,
      '4 hours': 0,
      '5+ hours': 0,
    };

    for (final session in sessions) {
      final duration = session.end!.difference(session.start);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;

      String bucket;
      if (hours == 0 && minutes <= 45) {
        bucket = '30 min';
      } else if (hours == 1 && minutes <= 30) {
        bucket = '1 hour';
      } else if (hours == 2 && minutes <= 30) {
        bucket = '2 hours';
      } else if (hours == 3 && minutes <= 30) {
        bucket = '3 hours';
      } else if (hours == 4 && minutes <= 30) {
        bucket = '4 hours';
      } else {
        bucket = '5+ hours';
      }

      buckets[bucket] = buckets[bucket]! + 1;
    }

    // Find most common
    final entries = buckets.entries.where((e) => e.value > 0).toList();
    if (entries.isEmpty) return null;

    entries.sort((a, b) => b.value.compareTo(a.value));
    final top = entries.first;

    return StoryCard(
      id: id,
      headline: formatHeadlineCommonSessionLength(),
      mainValue: top.key,
      period: 'All Sessions',
      details: [
        StoryDetail(
          label: 'Bookings',
          value: formatDetailMostBooked(top.key, top.value),
        ),
        StoryDetail(
          label: 'Total Sessions',
          value: formatNumber(sessions.length),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }
}