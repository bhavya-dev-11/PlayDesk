import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:playdesk_owner_stories/core/theme.dart';
import 'package:playdesk_owner_stories/data.dart';
import 'package:playdesk_owner_stories/state/providers.dart';

void showDataEditorSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DataEditorSheet(),
  );
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _DataEditorSheet extends ConsumerWidget {
  const _DataEditorSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(venueSnapshotProvider);
    final clock = ref.watch(clockProvider);
    final notifier = ref.read(venueSnapshotProvider.notifier);

    final unitsByItem = _yesterdayUnits(snapshot, clock.yesterday);
    final foodRows = unitsByItem.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final visitRows = _visitCounts(snapshot);

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Edit demo data',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _Heading(
                  title: 'Food units sold yesterday',
                  hint: 'Plus ya minus dabao, phir stories dobara kholo.',
                ),
                if (foodRows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Is din koi food order nahi hai.'),
                  ),
                for (var i = 0; i < foodRows.length; i++)
                  _EditRow(
                    leading: '#${i + 1}',
                    highlight: i == 0,
                    title: foodRows[i].key,
                    value: '${foodRows[i].value}',
                    onMinus: () => _changeFood(notifier, foodRows[i].key, clock.yesterday, -1),
                    onPlus: () => _changeFood(notifier, foodRows[i].key, clock.yesterday, 1),
                  ),
                const SizedBox(height: 24),
                const _Heading(
                  title: 'Player visits',
                  hint: '-1 visit us player ka sabse latest visit-day hata deta hai. '
                      'Wapas laane ke liye Reset dabao.',
                ),
                for (final row in visitRows.take(6))
                  _EditRow(
                    leading: '',
                    highlight: row.visits == 10,
                    title: row.name,
                    value: '${row.visits}',
                    valueSuffix: ' visits',
                    onMinus: () => _dropLatestVisit(notifier, row.playerId),
                  ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () async {
                    await notifier.reset();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data reset ho gaya')),
                      );
                    }
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset data'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _yesterdayUnits(VenueSnapshot snapshot, DateTime day) {
    final units = <String, int>{};
    for (final bill in snapshot.bills) {
      for (final item in bill.items) {
        if (_sameDay(item.orderedAt, day)) {
          units[item.itemName] = (units[item.itemName] ?? 0) + item.qty;
        }
      }
    }
    return units;
  }

  List<_VisitRow> _visitCounts(VenueSnapshot snapshot) {
    final rows = <_VisitRow>[];
    for (final player in snapshot.players) {
      final days = <String>{};
      for (final s in snapshot.sessionsForPlayer(player.id)) {
        days.add('${s.start.year}-${s.start.month}-${s.start.day}');
      }
      rows.add(_VisitRow(player.id, player.name, days.length));
    }
    rows.sort((a, b) => b.visits.compareTo(a.visits));
    return rows;
  }

  // Sirf ek order line ko +/-1 karte hain. Pehle wale code mein har line ki qty
  // newQty set ho rahi thi, isse total bigad jata tha.
  void _changeFood(VenueSnapshotNotifier notifier, String itemName, DateTime day, int delta) {
    final data = notifier.modifyData((d) {
      var changed = false;
      final bills = d.bills.map((bill) {
        if (changed) return bill;
        final idx = bill.items.lastIndexWhere(
          (i) => i.itemName == itemName && _sameDay(i.orderedAt, day),
        );
        if (idx == -1) return bill;

        final items = [...bill.items];
        final old = items[idx];
        final newQty = old.qty + delta;
        if (newQty <= 0) {
          items.removeAt(idx);
        } else {
          items[idx] = FoodOrder(
            itemName: old.itemName,
            qty: newQty,
            unitPrice: old.unitPrice,
            orderedAt: old.orderedAt,
          );
        }
        changed = true;

        return Bill(
          id: bill.id,
          sessionId: bill.sessionId,
          playerId: bill.playerId,
          gamingAmount: bill.gamingAmount,
          items: items,
          total: bill.gamingAmount + items.fold(0, (sum, i) => sum + i.lineTotal),
          paidAmount: bill.paidAmount,
          payments: bill.payments,
          closedAt: bill.closedAt,
          closedBy: bill.closedBy,
        );
      }).toList();
      return d.copyWith(bills: bills);
    });
    notifier.updateData(data);
  }

  void _dropLatestVisit(VenueSnapshotNotifier notifier, String playerId) {
    final data = notifier.modifyData((d) {
      final mine = d.sessions.where((s) => s.playerId == playerId).toList()
        ..sort((a, b) => b.start.compareTo(a.start));
      if (mine.isEmpty) return d;

      final lastDay = mine.first.start;
      final goneIds = mine
          .where((s) => _sameDay(s.start, lastDay))
          .map((s) => s.id)
          .toSet();

      return d.copyWith(
        sessions: d.sessions.where((s) => !goneIds.contains(s.id)).toList(),
        bills: d.bills.where((b) => !goneIds.contains(b.sessionId)).toList(),
      );
    });
    notifier.updateData(data);
  }
}

class _VisitRow {
  const _VisitRow(this.playerId, this.name, this.visits);

  final String playerId;
  final String name;
  final int visits;
}

class _Heading extends StatelessWidget {
  const _Heading({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            hint,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditRow extends StatelessWidget {
  const _EditRow({
    required this.leading,
    required this.title,
    required this.value,
    required this.onMinus,
    this.onPlus,
    this.highlight = false,
    this.valueSuffix = '',
  });

  final String leading;
  final String title;
  final String value;
  final String valueSuffix;
  final bool highlight;
  final VoidCallback onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: highlight
            ? AppTheme.accent.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: highlight ? Border.all(color: AppTheme.accent.withValues(alpha: 0.5)) : null,
      ),
      child: Row(
        children: [
          if (leading.isNotEmpty)
            SizedBox(
              width: 30,
              child: Text(
                leading,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: highlight ? AppTheme.accentLight : Colors.white54,
                ),
              ),
            ),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppTheme.accentLight,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            '$value$valueSuffix',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (onPlus != null)
            IconButton(
              onPressed: onPlus,
              icon: const Icon(Icons.add_circle_outline),
              color: AppTheme.accentLight,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}