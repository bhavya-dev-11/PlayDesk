import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:playdesk_owner_stories/data/venue_repository.dart';
import 'package:playdesk_owner_stories/data/models.dart';

/// Local JSON-based venue repository.
/// Loads from assets/data/sample_data.json and keeps edits in memory.
class LocalVenueRepository implements VenueRepository {
  static const String _assetPath = 'assets/data/sample_data.json';

  VenueData? _cachedData;
  VenueData? _initialData;

  @override
  Future<VenueData> load() async {
    if (_cachedData != null) return _cachedData!;

    final jsonString = await rootBundle.loadString(_assetPath);
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    _cachedData = _parseVenueData(jsonMap);
    _initialData = _cachedData;
    return _cachedData!;
  }

  @override
  Future<void> save(VenueData data) async {
    _cachedData = data;
  }

  @override
  Future<void> reset() async {
    if (_initialData != null) {
      _cachedData = _initialData;
    } else {
      // Reload from asset if no initial data cached
      _cachedData = null;
      await load();
    }
  }

  /// Get current cached data (for synchronous access in providers).
  VenueData? get currentData => _cachedData;

  /// Update data in memory (used by debug panel).
  void updateData(VenueData data) {
    _cachedData = data;
  }

  VenueData _parseVenueData(Map<String, dynamic> json) {
    return VenueData(
      devices: (json['devices'] as List)
          .map((e) => Device.fromJson(e as Map<String, dynamic>))
          .toList(),
      players: (json['players'] as List)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      sessions: (json['sessions'] as List)
          .map((e) => Session.fromJson(e as Map<String, dynamic>))
          .toList(),
      bills: (json['bills'] as List)
          .map((e) => Bill.fromJson(e as Map<String, dynamic>))
          .toList(),
      bookings: (json['bookings'] as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList(),
      packages: (json['packages'] as List)
          .map((e) => Package.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}