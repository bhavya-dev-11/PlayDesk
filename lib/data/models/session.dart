/// A gaming session for a player on a device.
class Session {
  final String id;
  final String playerId;
  final String deviceId;
  final String game; // Game name
  final DateTime start;
  final DateTime? end; // null = currently running
  final List<DateTime> extendedAt; // timestamps when session was extended
  final String? bookingId; // if this session was from a booking

  const Session({
    required this.id,
    required this.playerId,
    required this.deviceId,
    required this.game,
    required this.start,
    this.end,
    this.extendedAt = const [],
    this.bookingId,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as String,
        playerId: json['playerId'] as String,
        deviceId: json['deviceId'] as String,
        game: json['game'] as String,
        start: DateTime.parse(json['start'] as String),
        end: json['end'] != null ? DateTime.parse(json['end'] as String) : null,
        extendedAt: (json['extendedAt'] as List? ?? [])
            .map((e) => DateTime.parse(e as String))
            .toList(),
        bookingId: json['bookingId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'playerId': playerId,
        'deviceId': deviceId,
        'game': game,
        'start': start.toIso8601String(),
        'end': end?.toIso8601String(),
        'extendedAt': extendedAt.map((e) => e.toIso8601String()).toList(),
        'bookingId': bookingId,
      };

  /// Whether this session is currently active (not ended).
  bool get isActive => end == null;

  /// Duration of the session (up to now if still active).
  Duration duration(DateTime now) {
    final effectiveEnd = end ?? now;
    return effectiveEnd.difference(start);
  }

  /// Whether this session was extended at least once.
  bool get wasExtended => extendedAt.isNotEmpty;

  /// Check if session overlaps with a time range [rangeStart, rangeEnd).
  bool overlaps(DateTime rangeStart, DateTime rangeEnd) {
    final sessionEnd = end ?? rangeEnd.add(const Duration(days: 365)); // far future if active
    return start.isBefore(rangeEnd) && sessionEnd.isAfter(rangeStart);
  }

  /// Get overlap duration with a time range.
  Duration overlapDuration(DateTime rangeStart, DateTime rangeEnd) {
    final sessionEnd = end ?? rangeEnd;
    final overlapStart = start.isAfter(rangeStart) ? start : rangeStart;
    final overlapEnd = sessionEnd.isBefore(rangeEnd) ? sessionEnd : rangeEnd;
    if (overlapStart.isBefore(overlapEnd)) {
      return overlapEnd.difference(overlapStart);
    }
    return Duration.zero;
  }

  @override
  String toString() => 'Session($id, player: $playerId, device: $deviceId, $game)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}