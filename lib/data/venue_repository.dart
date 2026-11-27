import 'package:playdesk_owner_stories/data/models.dart';

/// Abstract repository for venue data.
/// Allows swapping implementations (local JSON, Firestore, etc.)
abstract class VenueRepository {
  /// Load all data from the source.
  Future<VenueData> load();

  /// Save data (for local implementation, updates in-memory cache).
  Future<void> save(VenueData data);

  /// Reset to initial state (for demo "Reset data" button).
  Future<void> reset();
}

/// Complete venue data snapshot (immutable).
class VenueData {
  final List<Device> devices;
  final List<Player> players;
  final List<Session> sessions;
  final List<Bill> bills;
  final List<Booking> bookings;
  final List<Package> packages;

  const VenueData({
    required this.devices,
    required this.players,
    required this.sessions,
    required this.bills,
    required this.bookings,
    required this.packages,
  });

  /// Create a copy with some fields replaced.
  VenueData copyWith({
    List<Device>? devices,
    List<Player>? players,
    List<Session>? sessions,
    List<Bill>? bills,
    List<Booking>? bookings,
    List<Package>? packages,
  }) =>
      VenueData(
        devices: devices ?? this.devices,
        players: players ?? this.players,
        sessions: sessions ?? this.sessions,
        bills: bills ?? this.bills,
        bookings: bookings ?? this.bookings,
        packages: packages ?? this.packages,
      );

  @override
  String toString() =>
      'VenueData(devices: ${devices.length}, players: ${players.length}, '
      'sessions: ${sessions.length}, bills: ${bills.length}, '
      'bookings: ${bookings.length}, packages: ${packages.length})';
}