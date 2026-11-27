import 'package:flutter/material.dart';

/// App theme configuration.
/// Dark theme with a single accent color (amber).
class AppTheme {
  static const Color _accent = Color(0xFFFFB300); // Amber 600
  static const Color _accentLight = Color(0xFFFFD54F); // Amber 300
  static const Color _accentDark = Color(0xFFF57F17); // Amber 900

  static const Color _surface = Color(0xFF1E1E1E);
  static const Color _surfaceContainerHighest = Color(0xFF2A2A2A);
  static const Color _onSurface = Color(0xFFFFFFFF);
  static const Color _onSurfaceVariant = Color(0xFFB0B0B0);

  /// The single accent color used throughout the app.
  static Color get accent => _accent;

  /// Light variant of accent for highlights.
  static Color get accentLight => _accentLight;

  /// Dark variant of accent for pressed states.
  static Color get accentDark => _accentDark;

  /// Main dark theme.
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: _surface,
      colorScheme: const ColorScheme.dark(
        primary: _accent,
        secondary: _accentLight,
        surface: _surface,
        surfaceContainerHighest: _surfaceContainerHighest,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: _onSurface,
        onSurfaceVariant: _onSurfaceVariant,
        error: Color(0xFFCF6679),
        onError: Colors.black,
        outline: Color(0xFF444444),
        outlineVariant: Color(0xFF333333),
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF333333), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _accentLight,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 2),
        ),
        labelStyle: const TextStyle(color: _onSurfaceVariant),
        hintStyle: const TextStyle(color: Color(0xFF888888)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF333333),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceContainerHighest,
        selectedColor: _accent.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: _onSurface),
        secondaryLabelStyle: const TextStyle(color: _accent),
        side: const BorderSide(color: Color(0xFF333333)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _accent,
        linearTrackColor: Color(0xFF333333),
        circularTrackColor: Color(0xFF333333),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _accent,
        inactiveTrackColor: _surfaceContainerHighest,
        thumbColor: _accent,
        overlayColor: _accent.withValues(alpha: 0.1),
        valueIndicatorColor: _accent,
        valueIndicatorTextStyle: const TextStyle(color: Colors.black),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: _accent,
        unselectedLabelColor: _onSurfaceVariant,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: _accent, width: 3),
          insets: EdgeInsets.symmetric(horizontal: 16),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _accent.withValues(alpha: 0.2);
            }
            return _surfaceContainerHighest;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _accent;
            }
            return _onSurface;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const BorderSide(color: _accent, width: 2);
            }
            return const BorderSide(color: Color(0xFF333333));
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: base.textTheme.displayLarge?.copyWith(
          color: _onSurface,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: base.textTheme.displayMedium?.copyWith(
          color: _onSurface,
          fontWeight: FontWeight.w700,
        ),
        displaySmall: base.textTheme.displaySmall?.copyWith(
          color: _onSurface,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          color: _onSurface,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: _onSurface,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          color: _onSurface,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: _onSurface,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: _onSurface,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          color: _onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: _onSurface,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: _onSurfaceVariant,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: _onSurfaceVariant,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          color: _onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Gradient overlay for story cards (dark photo + readable text).
class StoryGradients {
  static const LinearGradient photoOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x88000000), // 50% black
      Color(0xCC000000), // 80% black
      Colors.black,
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
  );

  static const LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x99000000),
      Color(0xCC000000),
    ],
  );

  static const LinearGradient accentGlow = LinearGradient(
    colors: [
      AppTheme._accent,
      AppTheme._accentLight,
    ],
  );
}

/// Semantic colors for story accents (mapped from enum in story_templates.dart).
enum StoryAccent {
  amber,
  blue,
  green,
  purple,
  red,
  teal,
  orange,
  pink,
}

extension StoryAccentColor on StoryAccent {
  Color get color {
    switch (this) {
      case StoryAccent.amber:
        return const Color(0xFFFFB300);
      case StoryAccent.blue:
        return const Color(0xFF29B6F6);
      case StoryAccent.green:
        return const Color(0xFF66BB6A);
      case StoryAccent.purple:
        return const Color(0xFFBA68C8);
      case StoryAccent.red:
        return const Color(0xFFEF5350);
      case StoryAccent.teal:
        return const Color(0xFF26C6DA);
      case StoryAccent.orange:
        return const Color(0xFFFFA726);
      case StoryAccent.pink:
        return const Color(0xFFEC407A);
    }
  }

  Color get lightColor {
    switch (this) {
      case StoryAccent.amber:
        return const Color(0xFFFFD54F);
      case StoryAccent.blue:
        return const Color(0xFF4FC3F7);
      case StoryAccent.green:
        return const Color(0xFF81C784);
      case StoryAccent.purple:
        return const Color(0xFFCE93D8);
      case StoryAccent.red:
        return const Color(0xFFE57373);
      case StoryAccent.teal:
        return const Color(0xFF4DD0E1);
      case StoryAccent.orange:
        return const Color(0xFFFFB74D);
      case StoryAccent.pink:
        return const Color(0xFFF06292);
    }
  }
}