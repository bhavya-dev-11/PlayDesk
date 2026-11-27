/// A prepaid package for a player.
class Package {
  final String id;
  final String playerId;
  final String name; // e.g., "Pro Gamer 50h"
  final DateTime expiresOn;
  final int remainingHours;

  const Package({
    required this.id,
    required this.playerId,
    required this.name,
    required this.expiresOn,
    required this.remainingHours,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
        id: json['id'] as String,
        playerId: json['playerId'] as String,
        name: json['name'] as String,
        expiresOn: DateTime.parse(json['expiresOn'] as String),
        remainingHours: json['remainingHours'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'playerId': playerId,
        'name': name,
        'expiresOn': expiresOn.toIso8601String(),
        'remainingHours': remainingHours,
      };

  /// Whether this package expires within a given date range (inclusive).
  bool expiresBetween(DateTime start, DateTime end) {
    final expiryDate = DateTime(expiresOn.year, expiresOn.month, expiresOn.day);
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return !expiryDate.isBefore(startDate) && !expiryDate.isAfter(endDate);
  }

  /// Whether this package is expired as of a given date.
  bool isExpiredAsOf(DateTime date) {
    final expiryDate = DateTime(expiresOn.year, expiresOn.month, expiresOn.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return expiryDate.isBefore(checkDate);
  }

  @override
  String toString() => 'Package($name, player: $playerId, expires: $expiresOn)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Package && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}