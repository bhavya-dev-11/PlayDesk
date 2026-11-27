import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/data.dart';
import 'package:playdesk_owner_stories/stories.dart';

/// Repository provider
final venueRepositoryProvider = Provider<VenueRepository>((ref) {
  return LocalVenueRepository();
});

/// Simulated clock state (day + slot)
final clockProvider = StateNotifierProvider<ClockNotifier, SimClock>((ref) {
  return ClockNotifier();
});

class ClockNotifier extends StateNotifier<SimClock> {
  ClockNotifier() : super(const SimClock(day: 1, slot: Slot.morning));

  void setDay(int day) {
    state = SimClock(day: day, slot: state.slot);
  }

  void setSlot(Slot slot) {
    state = SimClock(day: state.day, slot: slot);
  }

  void setClock(SimClock clock) {
    state = clock;
  }
}

/// Venue data snapshot notifier (holds in-memory edits)
final venueSnapshotProvider = StateNotifierProvider<VenueSnapshotNotifier, VenueSnapshot>((ref) {
  final repo = ref.watch(venueRepositoryProvider);
  return VenueSnapshotNotifier(repo);
});

class VenueSnapshotNotifier extends StateNotifier<VenueSnapshot> {
  final VenueRepository _repository;
  VenueData? _currentData;

  VenueSnapshotNotifier(this._repository) : super(VenueSnapshot.fromData(const VenueData(
    devices: [],
    players: [],
    sessions: [],
    bills: [],
    bookings: [],
    packages: [],
  ))) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final data = await _repository.load();
    _currentData = data;
    state = VenueSnapshot.fromData(data);
  }

  /// Update data in memory (for debug panel edits)
  void updateData(VenueData newData) {
    _currentData = newData;
    state = VenueSnapshot.fromData(newData);
    _repository.save(newData);
  }

  /// Reset to initial data
  Future<void> reset() async {
    await _repository.reset();
    await _loadInitialData();
  }

  /// Get current data for editing
  VenueData? get currentData => _currentData;

  /// Helper to create a modified copy of current data
  VenueData modifyData(VenueData Function(VenueData) modifier) {
    final current = _currentData ?? VenueData(
      devices: [],
      players: [],
      sessions: [],
      bills: [],
      bookings: [],
      packages: [],
    );
    return modifier(current);
  }
}

/// Story batch provider (auto-recomputes when clock or data changes)
final storyBatchProvider = Provider<List<StoryCard>>((ref) {
  final snapshot = ref.watch(venueSnapshotProvider);
  final clock = ref.watch(clockProvider);
  final builder = BatchBuilder(allCalculators);
  return builder.build(snapshot, clock);
});

/// Provider for checking if batch is empty
final hasStoriesProvider = Provider<bool>((ref) {
  final batch = ref.watch(storyBatchProvider);
  return batch.isNotEmpty;
});