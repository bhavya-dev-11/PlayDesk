import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/theme.dart';
import 'package:playdesk_owner_stories/state/providers.dart';
import 'package:playdesk_owner_stories/ui/debug/data_editor_sheet.dart';
import 'package:playdesk_owner_stories/ui/home/owner_stories_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.watch(clockProvider);
    final hasStories = ref.watch(hasStoriesProvider);
    final batch = ref.watch(storyBatchProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _HeroAppBar(
            slot: clock.slot,
            onDebug: () => showDataEditorSheet(context),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _VenueCard(),
                  const SizedBox(height: 14),
                  _ScheduleCard(clock: clock),
                  const SizedBox(height: 30),
                  _SectionTitle(
                    title: 'Owner Stories',
                    subtitle: hasStories
                        ? '${batch.length} new ${batch.length == 1 ? 'story' : 'stories'} ready'
                        : 'No new batch right now',
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Center(
                      key: ValueKey('${clock.day}-${clock.slot.name}-${batch.length}'),
                      child: OwnerStoriesTile(
                        clock: clock,
                        hasStories: hasStories,
                        storyCount: batch.length,
                        firstStory: batch.isNotEmpty ? batch.first : null,
                      ),
                    ),
                  ),
                  if (hasStories) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final card in batch) _HeadlineChip(text: card.headline),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinned SliverAppBar. Khula ho toh badi photo + greeting, scroll karne par
/// photo ghul jaati hai aur chhota title bar bachta hai.
class _HeroAppBar extends StatelessWidget {
  const _HeroAppBar({required this.slot, required this.onDebug});

  final Slot slot;
  final VoidCallback onDebug;

  static const double _expanded = 250;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final topInset = MediaQuery.of(context).padding.top;
    final minHeight = topInset + kToolbarHeight;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: _expanded,
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Material(
            color: Colors.black.withValues(alpha: 0.35),
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Edit demo data',
              onPressed: onDebug,
              icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = _expanded + topInset;
          final t = ((constraints.maxHeight - minHeight) / (maxHeight - minHeight))
              .clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: t,
                child: Image.asset(
                  'assets/photos/header-gif.gif',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.accent.withValues(alpha: 0.5), bg],
                      ),
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.2),
                      bg,
                    ],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
              // khula hua title, thoda upar rakha hai taaki fade wale hisse mein na jaye
              Positioned(
                left: 20,
                right: 70,
                bottom: 64,
                child: Opacity(
                  opacity: Curves.easeOut.transform(t),
                  child: Transform.translate(
                    offset: Offset(0, (1 - t) * 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              slot == Slot.morning
                                  ? Icons.wb_sunny_rounded
                                  : Icons.nightlight_round,
                              size: 16,
                              color: AppTheme.accentLight,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              slot == Slot.morning ? 'Good morning' : 'Good evening',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Level Up Arena',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 14, color: Colors.black54)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // collapse hone par chhota title
              Positioned(
                left: 20,
                top: topInset,
                height: kToolbarHeight,
                child: Opacity(
                  opacity: (1 - t * 2.2).clamp(0.0, 1.0),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Level Up Arena',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard();

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return _Panel(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.sports_esports_rounded, color: AppTheme.accentLight, size: 26),
          ),
          const SizedBox(width: 16),
          const _Stat(value: '10', label: 'PCs'),
          _VerticalDivider(color: muted),
          const _Stat(value: '4', label: 'PS5s'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                SizedBox(width: 6),
                Text(
                  'Open',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      color: color.withValues(alpha: 0.25),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ScheduleCard extends ConsumerWidget {
  const _ScheduleCard({required this.clock});

  final SimClock clock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(clockProvider.notifier);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final timeLabel = clock.slot == Slot.morning ? '10:00 am' : '5:30 pm';

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: muted),
              const SizedBox(width: 6),
              Text(
                'Demo time  ·  Day ${clock.day}, $timeLabel',
                style: TextStyle(fontSize: 13, color: muted, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final day in [1, 2, 3]) ...[
                Expanded(
                  child: _Choice(
                    label: 'Day $day',
                    selected: clock.day == day,
                    onTap: () => notifier.setDay(day),
                  ),
                ),
                if (day != 3) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Choice(
                  label: 'Morning',
                  icon: Icons.wb_sunny_outlined,
                  selected: clock.slot == Slot.morning,
                  onTap: () => notifier.setSlot(Slot.morning),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Choice(
                  label: 'Evening',
                  icon: Icons.nightlight_round,
                  selected: clock.slot == Slot.evening,
                  onTap: () => notifier.setSlot(Slot.evening),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected ? Colors.white : scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const Spacer(),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _HeadlineChip extends StatelessWidget {
  const _HeadlineChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accentLight),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: child,
    );
  }
}