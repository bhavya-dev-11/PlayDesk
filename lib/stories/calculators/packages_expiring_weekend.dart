import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/formatters.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Story: Prepaid packages expiring this weekend (Saturday-Sunday).
class PackagesExpiringWeekendCalculator extends StoryCalculator {
  @override
  String get id => 'packages_expiring_weekend';

  @override
  bool supportedAt(SimClock clock) => clock.slot == Slot.evening;

  @override
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock) {
    final weekendStart = clock.weekendStart; // Saturday 00:00
    final weekendEnd = clock.weekendEnd; // Sunday 23:59:59

    // Packages expiring this weekend
    final expiringPackages = snapshot.packages.where((p) {
      return p.expiresBetween(weekendStart, weekendEnd);
    }).toList();

    if (expiringPackages.isEmpty) return null;

    return StoryCard(
      id: id,
      headline: formatHeadlinePackagesExpiring(),
      mainValue: formatNumber(expiringPackages.length),
      period: 'This Weekend',
      details: [
        StoryDetail(
          label: 'Expiring',
          value: formatDetailExpiringCount(expiringPackages.length, 'Sat-Sun'),
        ),
        StoryDetail(
          label: 'Hours Left',
          value: formatDetailHoursPlayed(
            Duration(hours: expiringPackages.fold(0, (sum, p) => sum + p.remainingHours)),
          ),
          isHighlight: true,
        ),
      ],
      accent: accentForStory(id),
      photoAsset: photoForStory(id),
    );
  }
}