import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/stories/batch_config.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/data/venue_snapshot.dart';

/// Builds a story batch for a given clock time.
/// Handles primary -> reserve fallback and eligibility filtering.
class BatchBuilder {
  final Map<String, StoryCalculator> _calculators;

  const BatchBuilder(this._calculators);

  /// Build the story batch for the given snapshot and clock.
  /// Returns up to 3 eligible stories, or empty list if none eligible.
  List<StoryCard> build(VenueSnapshot snapshot, SimClock clock) {
    final config = getBatchConfig(clock.day, clock.slot);
    final results = <StoryCard>[];
    final usedIds = <String>{};

    // Try primary stories first
    for (final id in config.primary) {
      if (results.length >= 3) break;
      final card = _tryCompute(id, snapshot, clock);
      if (card != null) {
        results.add(card);
        usedIds.add(id);
      }
    }

    // Fill from reserve pool if needed
    if (results.length < 3) {
      for (final id in config.reserve) {
        if (results.length >= 3) break;
        if (usedIds.contains(id)) continue;
        final card = _tryCompute(id, snapshot, clock);
        if (card != null) {
          results.add(card);
          usedIds.add(id);
        }
      }
    }

    return results;
  }

  /// Try to compute a story, returning null if not eligible or calculator missing.
  StoryCard? _tryCompute(String id, VenueSnapshot snapshot, SimClock clock) {
    final calculator = _calculators[id];
    if (calculator == null) return null;
    if (!calculator.supportedAt(clock)) return null;
    return calculator.compute(snapshot, clock);
  }
}