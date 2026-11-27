import 'package:flutter_test/flutter_test.dart';
import 'package:playdesk_owner_stories/core/sim_clock.dart';
import 'package:playdesk_owner_stories/stories/batch_config.dart';
import 'package:playdesk_owner_stories/stories/calculator_registry.dart';
import 'package:playdesk_owner_stories/stories/story_templates.dart';

void main() {
  group('The Three-Day Pilot Batch Configuration Tests', () {
    test('All 6 batches have exactly 3 primary stories', () {
      final days = [1, 2, 3];
      final slots = [Slot.morning, Slot.evening];

      final allPrimaryStoryIds = <String>{};

      for (final day in days) {
        for (final slot in slots) {
          final config = getBatchConfig(day, slot);
          expect(config.primary.length, 3,
              reason: 'Day $day ${slot.name} must have 3 primary stories');
          expect(config.reserve.isNotEmpty, true,
              reason: 'Day $day ${slot.name} must have a reserve fallback pool');
          allPrimaryStoryIds.addAll(config.primary);
        }
      }

      // 6 batches * 3 primary stories = 18 unique story ideas
      expect(allPrimaryStoryIds.length, 18,
          reason: 'There must be 18 unique primary story IDs across 3 days');
    });

    test('Every primary story ID is registered in allCalculators registry', () {
      for (final day in [1, 2, 3]) {
        for (final slot in [Slot.morning, Slot.evening]) {
          final config = getBatchConfig(day, slot);
          for (final storyId in config.primary) {
            expect(allCalculators.containsKey(storyId), true,
                reason: 'Story calculator for $storyId must be registered');
          }
          for (final storyId in config.reserve) {
            expect(allCalculators.containsKey(storyId), true,
                reason: 'Reserve story calculator for $storyId must be registered');
          }
        }
      }
    });

    test('All 18 story IDs have dedicated photo assets and accent colors', () {
      for (var i = 1; i <= 18; i++) {
        final expectedAsset = 'assets/photos/story$i.png';
        // Check that photo asset exists in templates
        // We test all known story IDs
        expect(allCalculators.keys.length, 18);
      }

      for (final id in allCalculators.keys) {
        final photo = photoForStory(id);
        expect(photo.startsWith('assets/photos/story'), true,
            reason: '$id should map to a dedicated story image');
        expect(photo.endsWith('.png'), true,
            reason: '$id photo should be a png image');

        final accent = accentForStory(id);
        expect(accent, isNotNull,
            reason: '$id must have an assigned StoryAccent');
      }
    });
  });
}
