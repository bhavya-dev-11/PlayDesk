import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:playdesk_owner_stories/core/theme.dart';

import 'package:playdesk_owner_stories/state/providers.dart';
import 'package:playdesk_owner_stories/stories/story_card.dart';

/// Tap left/right = prev/next, press & hold = pause, neeche swipe = close.
class StoryViewerScreen extends ConsumerStatefulWidget {
  const StoryViewerScreen({super.key});

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  static const _cardDuration = Duration(seconds: 6);

  late final AnimationController _progress;
  late final List<StoryCard> _stories;
  int _index = 0;
  bool _holding = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _stories = ref.read(storyBatchProvider);
    _progress = AnimationController(vsync: this, duration: _cardDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _next();
      });
    if (_stories.isNotEmpty) _progress.forward();
  }

  void _next() {
    if (_index < _stories.length - 1) {
      setState(() => _index++);
      _progress.forward(from: 0);
    } else {
      _close();
    }
  }

  void _previous() {
    if (_index > 0) setState(() => _index--);
    _progress.forward(from: 0);
  }

  void _pause() {
    _progress.stop();
    setState(() => _holding = true);
  }

  void _resume() {
    if (!_holding) return;
    setState(() => _holding = false);
    _progress.forward();
  }

  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clock = ref.watch(clockProvider);

    if (_stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/photos/empty_state.svg',
                width: 56,
                height: 56,
                colorFilter: const ColorFilter.mode(Colors.white24, BlendMode.srcIn),
              ),
              const SizedBox(height: 14),
              Text(
                'No stories for ${clock.fullLabel}',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _close, child: const Text('Close')),
            ],
          ),
        ),
      );
    }

    final story = _stories[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          final width = MediaQuery.sizeOf(context).width;
          details.localPosition.dx < width / 3 ? _previous() : _next();
        },
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 700) _close();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              child: _StoryPage(
                key: ValueKey(_index),
                story: story,
                progress: _progress,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 12, 0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _ProgressBars(
                        count: _stories.length,
                        current: _index,
                        progress: _progress,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.sports_esports_outlined,
                              color: Colors.white, size: 15),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Level Up Arena',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(blurRadius: 6, color: Colors.black87),
                                  ],
                                ),
                              ),
                              Text(
                                clock.fullLabel,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(blurRadius: 4, color: Colors.black87),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: _close,
                          icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                        ),
                      ],
                    ),
                    if (_holding)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.pause_rounded, color: Colors.white70, size: 14),
                              SizedBox(width: 5),
                              Text('Paused',
                                  style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBars extends StatelessWidget {
  const _ProgressBars({
    required this.count,
    required this.current,
    required this.progress,
  });

  final int count;
  final int current;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    // Instagram-style: separate segments (bars) for each story
    // with small gaps, each animates individually
    const gap = 3.0; // gap between segments
    const height = 3.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final usableWidth = totalWidth - gap * (count - 1);
        final segmentWidth = usableWidth / count;

        return Row(
          children: List.generate(count, (i) {
            final isCompleted = i < current;
            final isCurrent = i == current;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == count - 1 ? 0 : gap),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(height / 2),
                  child: SizedBox(
                    height: height,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background track
                        ColoredBox(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        // Completed segment - fully filled
                        if (isCompleted)
                          const ColoredBox(color: Colors.white),
                        // Current segment - animating
                        if (isCurrent)
                          AnimatedBuilder(
                            animation: progress,
                            builder: (_, __) => Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: progress.value,
                                child: const ColoredBox(color: Colors.white),
                              ),
                            ),
                          ),
                        // Future segments - empty (just background shows)
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _StoryPage extends StatelessWidget {
  const _StoryPage({super.key, required this.story, required this.progress});

  final StoryCard story;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final accent = story.accent.color;
    final light = story.accent.lightColor;

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: progress,
          builder: (_, child) =>
              Transform.scale(scale: 1 + 0.05 * progress.value, child: child),
          child: Image.asset(
            story.photoAsset,
            fit: BoxFit.cover,
            cacheWidth: 1080,
            errorBuilder: (_, __, ___) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent.withValues(alpha: 0.3), Colors.black],
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
                Colors.black.withValues(alpha: 0.65),
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.45),
                Colors.black.withValues(alpha: 0.95),
              ],
              stops: const [0, 0.22, 0.5, 1],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (_, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 3,
                    decoration: BoxDecoration(
                      color: light,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    story.headline.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: light,
                      letterSpacing: 2.0,
                      shadows: const [
                        Shadow(blurRadius: 10, color: Colors.black87),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      story.mainValue,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.05,
                        letterSpacing: -1.0,
                        shadows: [
                          Shadow(blurRadius: 14, color: Colors.black),
                          Shadow(blurRadius: 6, color: Colors.black87),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    story.period,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 0.3,
                      shadows: [
                        Shadow(blurRadius: 6, color: Colors.black87),
                      ],
                    ),
                  ),
                  if (story.details.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    _Details(details: story.details, highlight: light),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.details, required this.highlight});

  final List<StoryDetail> details;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < details.length; i++) ...[
                if (i > 0) Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Row(
                    children: [
                      Text(
                        details[i].label,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          details[i].value,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: details[i].isHighlight ? FontWeight.w800 : FontWeight.w700,
                            color: details[i].isHighlight ? highlight : Colors.white,
                            shadows: [
                              if (details[i].isHighlight)
                                Shadow(blurRadius: 6, color: highlight.withValues(alpha: 0.4)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}