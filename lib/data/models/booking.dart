/// Booking status.
enum BookingStatus { confirmed, cancelled }

/// A group booking for devices.
class Booking {
  final String id;
  final List<String> deviceIds;
  final int groupSize;
  final DateTime start;
  final DateTime end;
  final BookingStatus status;
  final DateTime? cancelledAt;

  const Booking({
    required this.id,
    required this.deviceIds,
    required this.groupSize,
    required this.start,
    required this.end,
    this.status = BookingStatus.confirmed,
    this.cancelledAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        deviceIds: (json['deviceIds'] as List).cast<String>(),
        groupSize: json['groupSize'] as int,
        start: DateTime.parse(json['start'] as String),
        end: DateTime.parse(json['end'] as String),
        status: BookingStatus.values.byName(json['status'] as String),
        cancelledAt: json['cancelledAt'] != null
            ? DateTime.parse(json['cancelledAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceIds': deviceIds,
        'groupSize': groupSize,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'status': status.name,
        'cancelledAt': cancelledAt?.toIso8601String(),
      };

  /// Whether this booking is confirmed (not cancelled).
  bool get isConfirmed => status == BookingStatus.confirmed;

  /// Whether this booking was cancelled.
  bool get isCancelled => status == BookingStatus.cancelled;

  /// Duration of the booking.
  Duration get duration => end.difference(start);

  /// Check if booking overlaps with a time range.
  bool overlaps(DateTime rangeStart, DateTime rangeEnd) {
    return start.isBefore(rangeEnd) && end.isAfter(rangeStart);
  }

  @override
  String toString() => 'Booking($id, ${deviceIds.length} devices, $groupSize ppl)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Booking && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}