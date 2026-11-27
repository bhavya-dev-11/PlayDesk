import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:intl/intl.dart';

/// Generates seeded sample data for the PlayDesk demo.
/// Run with: dart run tool/generate_sample_data.dart

void main() {
  final random = Random(42); // Fixed seed for reproducibility
  final day1Anchor = DateTime(2026, 12, 1);

  // Devices: 10 PCs + 4 PS5s
  final devices = <Map<String, dynamic>>[];
  for (int i = 1; i <= 10; i++) {
    devices.add({'id': 'pc-$i', 'type': 'pc', 'label': 'PC-$i'});
  }
  for (int i = 1; i <= 4; i++) {
    devices.add({'id': 'ps5-$i', 'type': 'ps5', 'label': 'PS5-$i'});
  }

  // Players: 30 players joined over the last 4 weeks
  final players = <Map<String, dynamic>>[];
  final playerNames = [
    'Alex', 'Sam', 'Jordan', 'Taylor', 'Casey', 'Riley', 'Avery', 'Quinn',
    'Morgan', 'Cameron', 'Drew', 'Peyton', 'Reese', 'Rowan', 'Sage',
    'Dakota', 'Finley', 'Hayden', 'Jamie', 'Kai', 'Logan', 'Marley',
    'Nova', 'Oakley', 'Phoenix', 'Quinn', 'River', 'Skyler', 'Tatum', 'Wren',
  ];

  for (int i = 0; i < 30; i++) {
    final joinDaysAgo = random.nextInt(28) + 1; // 1-28 days ago
    final joinedOn = day1Anchor.subtract(Duration(days: joinDaysAgo));
    players.add({
      'id': 'player-${i + 1}',
      'name': playerNames[i],
      'joinedOn': joinedOn.toIso8601String(),
    });
  }

  // Sessions: Generate sessions over 4 weeks (Day 1 = Dec 1)
  // We need data from 4 weeks before Day 1 up to Day 3 evening
  final sessions = <Map<String, dynamic>>[];
  final games = ['Valorant', 'CS2', 'Apex Legends', 'Fortnite', 'Minecraft', 'Roblox', 'FIFA 24', 'NBA 2K24'];
  final pcDevices = devices.where((d) => d['type'] == 'pc').map((d) => d['id'] as String).toList();
  final ps5Devices = devices.where((d) => d['type'] == 'ps5').map((d) => d['id'] as String).toList();
  final allDevices = [...pcDevices, ...ps5Devices];

  // Generate ~200 sessions over 4 weeks
  for (int dayOffset = -28; dayOffset <= 2; dayOffset++) {
    final date = day1Anchor.add(Duration(days: dayOffset));
    final sessionsThisDay = random.nextInt(8) + 5; // 5-12 sessions per day

    for (int s = 0; s < sessionsThisDay; s++) {
      final player = players[random.nextInt(players.length)];
      final deviceType = random.nextDouble() < 0.7 ? 'pc' : 'ps5'; // 70% PC
      final device = deviceType == 'pc'
          ? pcDevices[random.nextInt(pcDevices.length)]
          : ps5Devices[random.nextInt(ps5Devices.length)];
      final game = games[random.nextInt(games.length)];

      // Start time between 10:00 and 22:00
      final startHour = 10 + random.nextInt(12);
      final startMinute = random.nextInt(60);
      final start = DateTime(date.year, date.month, date.day, startHour, startMinute);

      // Duration 30 min to 4 hours
      final durationMinutes = 30 + random.nextInt(210);
      final end = start.add(Duration(minutes: durationMinutes));

      // Some sessions get extended
      final extendedAt = <String>[];
      if (random.nextDouble() < 0.15) { // 15% chance of extension
        final extCount = 1 + random.nextInt(2);
        for (int e = 0; e < extCount; e++) {
          final extMinutes = 30 + random.nextInt(60);
          final extTime = end.add(Duration(minutes: extMinutes));
          extendedAt.add(extTime.toIso8601String());
        }
      }

      sessions.add({
        'id': 'session-${sessions.length + 1}',
        'playerId': player['id'],
        'deviceId': device,
        'game': game,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'extendedAt': extendedAt,
        'bookingId': random.nextDouble() < 0.2 ? 'booking-${random.nextInt(50) + 1}' : null,
      });
    }
  }

  // Bills: One per completed session
  final bills = <Map<String, dynamic>>[];
  final foodItems = [
    {'name': 'Burger', 'price': 180},
    {'name': 'Fries', 'price': 90},
    {'name': 'Chicken Wings', 'price': 220},
    {'name': 'Pizza Slice', 'price': 150},
    {'name': 'Coke', 'price': 50},
    {'name': 'Coffee', 'price': 60},
    {'name': 'Sandwich', 'price': 120},
    {'name': 'Nachos', 'price': 160},
  ];

  for (final session in sessions) {
    if (session['end'] == null) continue; // Skip active sessions

    final gamingAmount = 50 + random.nextInt(200); // ₹50-250 per hour
    final itemCount = random.nextInt(3); // 0-2 food items
    final items = <Map<String, dynamic>>[];
    int foodTotal = 0;

    for (int i = 0; i < itemCount; i++) {
      final food = foodItems[random.nextInt(foodItems.length)];
      final qty = 1 + random.nextInt(2);
      items.add({
        'itemName': food['name'],
        'qty': qty,
        'unitPrice': food['price'],
        'orderedAt': DateTime.parse(session['start'] as String).add(Duration(minutes: 15 + random.nextInt(60))).toIso8601String(),
      });
      foodTotal += qty * (food['price'] as int);
    }

    final total = gamingAmount + foodTotal;
    final isPaid = random.nextDouble() < 0.85; // 85% paid
    final paidAmount = isPaid ? total : (total * (0.3 + random.nextDouble() * 0.4)).round(); // Partial payment

    // Payments
    final payments = <Map<String, dynamic>>[];
    if (paidAmount > 0) {
      final method = random.nextDouble() < 0.7 ? 'upi' : 'cash'; // 70% UPI
      payments.add({
        'method': method,
        'amount': paidAmount,
        'paidAt': DateTime.parse(session['end'] as String).add(const Duration(minutes: 5)).toIso8601String(),
      });
    }

    final closedAt = DateTime.parse(session['end'] as String).add(const Duration(minutes: 10));
    final staff = ['Rahul', 'Priya', 'Amit', 'Sneha'][random.nextInt(4)];

    bills.add({
      'id': 'bill-${bills.length + 1}',
      'sessionId': session['id'],
      'playerId': session['playerId'],
      'gamingAmount': gamingAmount,
      'items': items,
      'total': total,
      'paidAmount': paidAmount,
      'payments': payments,
      'closedAt': closedAt.toIso8601String(),
      'closedBy': staff,
    });
  }

  // Bookings: Group bookings for the next few days
  final bookings = <Map<String, dynamic>>[];
  for (int dayOffset = 0; dayOffset <= 3; dayOffset++) {
    final date = day1Anchor.add(Duration(days: dayOffset));
    final bookingsThisDay = random.nextInt(3); // 0-2 bookings per day
    for (int b = 0; b < bookingsThisDay; b++) {
      final startHour = 17 + random.nextInt(4); // 5-8 PM
      final start = DateTime(date.year, date.month, date.day, startHour, 0);
      final durationHours = 2 + random.nextInt(3); // 2-4 hours
      final end = start.add(Duration(hours: durationHours));
      final groupSize = 2 + random.nextInt(4); // 2-5 people
      final deviceCount = (groupSize / 2).ceil();
      final shuffledDevices = List<String>.from(allDevices)..shuffle(random);
      final deviceIds = shuffledDevices.take(deviceCount).toList();

      bookings.add({
        'id': 'booking-${bookings.length + 1}',
        'deviceIds': deviceIds,
        'groupSize': groupSize,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'status': random.nextDouble() < 0.9 ? 'confirmed' : 'cancelled',
        'cancelledAt': random.nextDouble() < 0.1
            ? start.subtract(Duration(hours: 1 + random.nextInt(3))).toIso8601String()
            : null,
      });
    }
  }

  // Add some specific cancellations for Day 3 evening demo
  // Cancelled today (Day 3) evening
  final day3 = day1Anchor.add(const Duration(days: 2));
  bookings.add({
    'id': 'booking-cancel-1',
    'deviceIds': ['ps5-1', 'ps5-2'],
    'groupSize': 4,
    'start': DateTime(day3.year, day3.month, day3.day, 19, 0).toIso8601String(),
    'end': DateTime(day3.year, day3.month, day3.day, 22, 0).toIso8601String(),
    'status': 'cancelled',
    'cancelledAt': DateTime(day3.year, day3.month, day3.day, 16, 30).toIso8601String(),
  });
  bookings.add({
    'id': 'booking-cancel-2',
    'deviceIds': ['pc-5', 'pc-6', 'pc-7'],
    'groupSize': 3,
    'start': DateTime(day3.year, day3.month, day3.day, 18, 0).toIso8601String(),
    'end': DateTime(day3.year, day3.month, day3.day, 21, 0).toIso8601String(),
    'status': 'cancelled',
    'cancelledAt': DateTime(day3.year, day3.month, day3.day, 17, 0).toIso8601String(),
  });

  // Packages: Prepaid packages for some players
  final packages = <Map<String, dynamic>>[];
  for (int i = 0; i < 15; i++) {
    final player = players[random.nextInt(players.length)];
    final expiresDays = random.nextInt(14) + 1; // Expires in 1-14 days
    final expiresOn = day1Anchor.add(Duration(days: expiresDays));
    packages.add({
      'id': 'package-${packages.length + 1}',
      'playerId': player['id'],
      'name': ['Starter 10h', 'Pro Gamer 50h', 'Elite 100h'][random.nextInt(3)],
      'expiresOn': expiresOn.toIso8601String(),
      'remainingHours': 5 + random.nextInt(20),
    });
  }

  // Ensure some packages expire this weekend (Day 1 weekend = Dec 6-7)
  final weekendStart = DateTime(2026, 12, 6); // Saturday
  final weekendEnd = DateTime(2026, 12, 7); // Sunday
  for (int i = 0; i < 3; i++) {
    final player = players[random.nextInt(players.length)];
    packages.add({
      'id': 'package-weekend-${i + 1}',
      'playerId': player['id'],
      'name': 'Weekend Pass 20h',
      'expiresOn': weekendStart.add(Duration(days: random.nextInt(2))).toIso8601String(),
      'remainingHours': 10 + random.nextInt(10),
    });
  }

  // Ensure one player has exactly 10th visit on Day 3
  // Player-1 will have sessions on 9 distinct days before Day 3, and one on Day 3
  final targetPlayer = players.firstWhere((p) => p['id'] == 'player-1');
  // Add sessions for player-1 on 9 distinct days before Day 3
  final visitDays = <DateTime>[];
  for (int d = -28; d < 0; d += 3) {
    if (visitDays.length >= 9) break;
    visitDays.add(day1Anchor.add(Duration(days: d)));
  }
  // Add one session on Day 3
  visitDays.add(day1Anchor.add(const Duration(days: 2)));

  for (final visitDay in visitDays) {
    final startHour = 10 + random.nextInt(10);
    final start = DateTime(visitDay.year, visitDay.month, visitDay.day, startHour, 0);
    final end = start.add(Duration(hours: 1 + random.nextInt(3)));
    sessions.add({
      'id': 'session-milestone-${sessions.length + 1}',
      'playerId': 'player-1',
      'deviceId': pcDevices[random.nextInt(pcDevices.length)],
      'game': games[random.nextInt(games.length)],
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'extendedAt': [],
      'bookingId': null,
    });
  }

  // Ensure another player has 9th visit on Day 3 (negative case)
  final player9 = players.firstWhere((p) => p['id'] == 'player-2');
  final visitDays9 = <DateTime>[];
  for (int d = -28; d < 0; d += 3) {
    if (visitDays9.length >= 8) break;
    visitDays9.add(day1Anchor.add(Duration(days: d)));
  }
  visitDays9.add(day1Anchor.add(const Duration(days: 2)));

  for (final visitDay in visitDays9) {
    final startHour = 10 + random.nextInt(10);
    final start = DateTime(visitDay.year, visitDay.month, visitDay.day, startHour, 0);
    final end = start.add(Duration(hours: 1 + random.nextInt(3)));
    sessions.add({
      'id': 'session-milestone9-${sessions.length + 1}',
      'playerId': 'player-2',
      'deviceId': pcDevices[random.nextInt(pcDevices.length)],
      'game': games[random.nextInt(games.length)],
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'extendedAt': [],
      'bookingId': null,
    });
  }

  // Adjust food quantities for demo: Burger vs Fries close gap
  // Find yesterday's bills (Day 0 = Nov 30) and adjust
  final yesterdayBills = bills.where((b) {
    final closedAt = DateTime.parse(b['closedAt'] as String);
    final yesterday = day1Anchor.subtract(const Duration(days: 1));
    return closedAt.year == yesterday.year &&
        closedAt.month == yesterday.month &&
        closedAt.day == yesterday.day;
  }).toList();

  // Make Burger and Fries quantities close (Burger: 24, Fries: 22)
  // We'll adjust in the JSON manually after generation

  // Final data
  final data = {
    'devices': devices,
    'players': players,
    'sessions': sessions,
    'bills': bills,
    'bookings': bookings,
    'packages': packages,
  };

  // Write to file
  const outputPath = 'assets/data/sample_data.json';
  final file = File(outputPath);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  print('Sample data written to $outputPath');
  print('Devices: ${devices.length}');
  print('Players: ${players.length}');
  print('Sessions: ${sessions.length}');
  print('Bills: ${bills.length}');
  print('Bookings: ${bookings.length}');
  print('Packages: ${packages.length}');
}