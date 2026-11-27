import '../core/sim_clock.dart';
import '../core/theme.dart';
import '../data.dart';

/// A detail row for a story card.
class StoryDetail {
  final String label;
  final String value;
  final bool isHighlight;

  const StoryDetail({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });
}

/// A complete story card ready for display.
class StoryCard {
  final String id;
  final String headline;
  final String mainValue;
  final String period; // e.g., "Yesterday", "Today till 5:30 PM"
  final List<StoryDetail> details;
  final StoryAccent accent;
  final String photoAsset;

  const StoryCard({
    required this.id,
    required this.headline,
    required this.mainValue,
    required this.period,
    required this.details,
    required this.accent,
    required this.photoAsset,
  });

  @override
  String toString() => 'StoryCard($id: $headline = $mainValue)';
}

/// Abstract base for story calculators.
/// Pure Dart, no Flutter dependencies.
abstract class StoryCalculator {
  /// Unique identifier for this calculator.
  String get id;

  /// Whether this calculator is supported at the given clock time.
  /// Some stories only make sense at certain times (e.g., evening-only).
  bool supportedAt(SimClock clock);

  /// Compute the story card from the data snapshot and clock.
  /// Returns null if the story is not eligible (no data, conditions not met).
  StoryCard? compute(VenueSnapshot snapshot, SimClock clock);
}