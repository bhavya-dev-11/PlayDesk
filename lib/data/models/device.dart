/// Device type in the venue.
enum DeviceType { pc, ps5 }

/// A gaming device (PC or PS5) in the venue.
class Device {
  final String id;
  final DeviceType type;
  final String label; // e.g., "PC-01", "PS5-01"

  const Device({
    required this.id,
    required this.type,
    required this.label,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'] as String,
        type: DeviceType.values.byName(json['type'] as String),
        label: json['label'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'label': label,
      };

  @override
  String toString() => 'Device($label, ${type.name})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Device && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}