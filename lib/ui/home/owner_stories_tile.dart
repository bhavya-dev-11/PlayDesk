import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/core/theme.dart';
import 'package:playdesk_owner_stories/stories/story_card.dart';
import 'package:playdesk_owner_stories/ui/viewer/story_viewer.dart';

class OwnerStoriesTile extends StatelessWidget {
  const OwnerStoriesTile({
    super.key,
    required this.clock,
    required this.hasStories,
    required this.storyCount,
    this.firstStory,
  });

  final SimClock clock;
  final bool hasStories;
  final int storyCount;
  final StoryCard? firstStory;

  @override
  Widget build(BuildContext context) {
    final story = firstStory;
    if (!hasStories || story == null) return _EmptyState(clock: clock);

    final accent = story.accent.color;
    final light = story.accent.lightColor;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 220,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                story.photoAsset,
                fit: BoxFit.cover,
                cacheWidth: 900,
                errorBuilder: (_, __, ___) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [accent.withValues(alpha: 0.35), Colors.black],
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
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0, 0.4, 1],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'OWNER STORIES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 1.8,
                          ),
                        ),
                        const Spacer(),
                        _Segments(count: storyCount),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      story.headline.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: light,
                        letterSpacing: 1.5,
                        shadows: const [
                          Shadow(blurRadius: 8, color: Colors.black87),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        story.mainValue,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1,
                          shadows: [
                            Shadow(blurRadius: 10, color: Colors.black87),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${story.period}  ·  ${clock.fullLabel}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                              shadows: [
                                Shadow(blurRadius: 6, color: Colors.black87),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black26,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 17),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: () => _openViewer(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openViewer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => const StoryViewerScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }
}

/// Viewer ke progress bars ka chhota preview.
class _Segments extends StatelessWidget {
  const _Segments({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 16,
            height: 2,
            margin: const EdgeInsets.only(left: 3),
            decoration: BoxDecoration(
              color: i == 0 ? Colors.white : Colors.white30,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.clock});

  final SimClock clock;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/photos/empty_state.svg',
            width: 40,
            height: 40,
            colorFilter: ColorFilter.mode(
              AppTheme.accentLight.withValues(alpha: 0.8),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No new stories',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            'Nothing eligible for ${clock.fullLabel}.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}