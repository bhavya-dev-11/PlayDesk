/// A player/customer in the venue.
class Player {
  final String id;
  final String name;
  final DateTime joinedOn;

  const Player({
    required this.id,
    required this.name,
    required this.joinedOn,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        joinedOn: DateTime.parse(json['joinedOn'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'joinedOn': joinedOn.toIso8601String(),
      };

  @override
  String toString() => 'Player($name, $id)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}