import 'package:playdesk_owner_stories/data/venue_repository.dart';
import 'package:playdesk_owner_stories/data/models.dart';

/// Immutable snapshot of all venue data for a specific point in time.
/// Used by story calculators to avoid direct repository dependency.
class VenueSnapshot {
  final List<Device> devices;
  final List<Player> players;
  final List<Session> sessions;
  final List<Bill> bills;
  final List<Booking> bookings;
  final List<Package> packages;

  // Lookup maps for O(1) access
  final Map<String, Device> _deviceById;
  final Map<String, Player> _playerById;
  final Map<String, List<Session>> _sessionsByPlayer;
  final Map<String, List<Session>> _sessionsByDevice;
  final Map<String, List<Bill>> _billsByPlayer;
  final Map<String, Bill> _billBySession;
  final Map<String, List<Booking>> _bookingsByDevice;
  final Map<String, List<Package>> _packagesByPlayer;

  const VenueSnapshot._({
    required this.devices,
    required this.players,
    required this.sessions,
    required this.bills,
    required this.bookings,
    required this.packages,
    required Map<String, Device> deviceById,
    required Map<String, Player> playerById,
    required Map<String, List<Session>> sessionsByPlayer,
    required Map<String, List<Session>> sessionsByDevice,
    required Map<String, List<Bill>> billsByPlayer,
    required Map<String, Bill> billBySession,
    required Map<String, List<Booking>> bookingsByDevice,
    required Map<String, List<Package>> packagesByPlayer,
  })  : _deviceById = deviceById,
        _playerById = playerById,
        _sessionsByPlayer = sessionsByPlayer,
        _sessionsByDevice = sessionsByDevice,
        _billsByPlayer = billsByPlayer,
        _billBySession = billBySession,
        _bookingsByDevice = bookingsByDevice,
        _packagesByPlayer = packagesByPlayer;

  /// Create a snapshot from VenueData.
  factory VenueSnapshot.fromData(VenueData data) {
    final deviceById = {for (var d in data.devices) d.id: d};
    final playerById = {for (var p in data.players) p.id: p};

    final sessionsByPlayer = <String, List<Session>>{};
    for (final s in data.sessions) {
      sessionsByPlayer.putIfAbsent(s.playerId, () => []).add(s);
    }

    final sessionsByDevice = <String, List<Session>>{};
    for (final s in data.sessions) {
      sessionsByDevice.putIfAbsent(s.deviceId, () => []).add(s);
    }

    final billsByPlayer = <String, List<Bill>>{};
    for (final b in data.bills) {
      billsByPlayer.putIfAbsent(b.playerId, () => []).add(b);
    }

    final billBySession = {for (var b in data.bills) b.sessionId: b};

    final bookingsByDevice = <String, List<Booking>>{};
    for (final b in data.bookings) {
      for (final dId in b.deviceIds) {
        bookingsByDevice.putIfAbsent(dId, () => []).add(b);
      }
    }

    final packagesByPlayer = <String, List<Package>>{};
    for (final p in data.packages) {
      packagesByPlayer.putIfAbsent(p.playerId, () => []).add(p);
    }

    return VenueSnapshot._(
      devices: data.devices,
      players: data.players,
      sessions: data.sessions,
      bills: data.bills,
      bookings: data.bookings,
      packages: data.packages,
      deviceById: deviceById,
      playerById: playerById,
      sessionsByPlayer: sessionsByPlayer,
      sessionsByDevice: sessionsByDevice,
      billsByPlayer: billsByPlayer,
      billBySession: billBySession,
      bookingsByDevice: bookingsByDevice,
      packagesByPlayer: packagesByPlayer,
    );
  }

  // Convenience getters

  /// Get device by ID.
  Device? device(String id) => _deviceById[id];

  /// Get player by ID.
  Player? player(String id) => _playerById[id];

  /// Get all sessions for a player.
  List<Session> sessionsForPlayer(String playerId) =>
      _sessionsByPlayer[playerId] ?? const [];

  /// Get all sessions for a device.
  List<Session> sessionsForDevice(String deviceId) =>
      _sessionsByDevice[deviceId] ?? const [];

  /// Get all bills for a player.
  List<Bill> billsForPlayer(String playerId) => _billsByPlayer[playerId] ?? const [];

  /// Get bill for a session.
  Bill? billForSession(String sessionId) => _billBySession[sessionId];

  /// Get all bookings for a device.
  List<Booking> bookingsForDevice(String deviceId) =>
      _bookingsByDevice[deviceId] ?? const [];

  /// Get all packages for a player.
  List<Package> packagesForPlayer(String playerId) =>
      _packagesByPlayer[playerId] ?? const [];

  /// Get all PC devices.
  List<Device> get pcDevices =>
      devices.where((d) => d.type == DeviceType.pc).toList();

  /// Get all PS5 devices.
  List<Device> get ps5Devices =>
      devices.where((d) => d.type == DeviceType.ps5).toList();

  /// Get all confirmed bookings.
  List<Booking> get confirmedBookings =>
      bookings.where((b) => b.isConfirmed).toList();

  /// Get all completed (closed) bills.
  List<Bill> get closedBills => bills.where((b) => b.isClosed).toList();

  /// Get all open bills.
  List<Bill> get openBills => bills.where((b) => !b.isClosed).toList();

  /// Get all payments from closed bills.
  List<Payment> get allPayments =>
      bills.expand((b) => b.payments).toList();

  /// Get all food orders from all bills.
  List<FoodOrder> get allFoodOrders =>
      bills.expand((b) => b.items).toList();
}