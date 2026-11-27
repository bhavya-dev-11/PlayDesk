import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';
import 'package:playdesk_owner_stories/data/models.dart';

/// Story: PC with most playing time yesterday.
/// Clips sessions at day boundaries.
class TopPcPlaytimeYesterdayCalculator extends StoryCalculator {
  @override
  String get id => 'top_pc_playtime_yesterday';

  @override
  bool supportedAt(SimClock clock) => true;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final yesterdayStart = clock.yesterday;
    final yesterdayEnd = clock.yesterdayEnd;

    // Get PC devices
    final pcDevices = snapshot.pcDevices;
    if (pcDevices.isEmpty) return null;

    // Calculate playtime per PC for yesterday
    final Map<String, Duration> playtimeByPc = {};
    for (final device in pcDevices) {
      playtimeByPc[device.id] = Duration.zero;
    }

    for (final session in snapshot.sessions) {
      // Only PC sessions
      final device = snapshot.device(session.deviceId);
      if (device == null || device.type != DeviceType.pc) continue;

      // Check if session overlaps with yesterday
      if (!session.overlaps(yesterdayStart, yesterdayEnd)) continue;

      // Calculate overlap duration (clipped at day boundaries)
      final overlap = session.overlapDuration(yesterdayStart, yesterdayEnd);
      if (overlap > Duration.zero) {
        playtimeByPc[device.id] = playtimeByPc[device.id]! + overlap;
      }
    }

    // Find PC with most playtime
    final entries = playtimeByPc.entries.where((e) => e.value > Duration.zero).toList();
    if (entries.isEmpty) return null;

    entries.sort((a, b) => b.value.compareTo(a.value));
    final topEntry = entries.first;
    final topDevice = snapshot.device(topEntry.key)!;

    return StoryCard(
      id: id,
      headline: formatHeadlineTopPcPlaytime(),
      mainValue: topDevice.label,
      period: 'Yesterday',
      details: [
        StoryDetail(
          label: 'Play Time',
          value: formatDetailHoursPlayed(topEntry.value),
        ),
        StoryDetail(
          label: 'Sessions',
          value: formatNumber(_countSessionsForDevice(snapshot, topEntry.key, yesterdayStart, yesterdayEnd)),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }

  int _countSessionsForDevice(VenueSnapshot snapshot, String deviceId, DateTime start, DateTime end) {
    return snapshot.sessionsForDevice(deviceId).where((s) => s.overlaps(start, end)).length;
  }
}