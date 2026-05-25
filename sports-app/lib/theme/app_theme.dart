import 'package:flutter/material.dart';
import '../models/academy_theme.dart';
import 'app_colors.dart';

/// Centralized sport product theme used by mobile screens.
/// All colors are imported from app_colors.dart
class AppTheme {
  // Legacy color references - import from AppColors instead
  static const Color teal = AppColors.primaryTeal;
  static const Color tealDark = AppColors.primaryTealDark;
  static const Color tealLight = AppColors.primaryTealLight;
  static const Color orange = AppColors.secondaryOrange;
  static const Color pitch = AppColors.accentPitch;
  static const Color lime = AppColors.accentLime;
  static const Color violet = AppColors.secondaryViolet;
  static const Color electricBlue = AppColors.secondaryElectricBlue;
  static const Color bg = AppColors.bgLight;
  static const Color lightSurface = AppColors.surfaceLight;
  static const Color darkSurface = AppColors.surfaceDark;
  static const Color darkScaffold = AppColors.bgDark;

  static const BorderRadius _radiusLarge = BorderRadius.all(
    Radius.circular(18),
  );
  static const BorderRadius _radiusMedium = BorderRadius.all(
    Radius.circular(14),
  );

  static List<BoxShadow> _softShadow({required bool isDark}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.36 : 0.08),
        blurRadius: isDark ? 26 : 22,
        offset: const Offset(0, 14),
      ),
    ];
  }

  static TextTheme _homeTextTheme(
    TextTheme base,
    ColorScheme cs, {
    required bool isDark,
  }) {
    final baseApplied = base.apply(
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
    );

    return baseApplied.copyWith(
      displayLarge: baseApplied.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      displayMedium: baseApplied.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: baseApplied.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: baseApplied.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      titleLarge: baseApplied.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: baseApplied.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleSmall: baseApplied.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      bodyMedium: baseApplied.bodyMedium?.copyWith(
        color: cs.onSurface.withValues(alpha: isDark ? 0.9 : 0.86),
        height: 1.25,
      ),
      bodySmall: baseApplied.bodySmall?.copyWith(
        color: cs.onSurface.withValues(alpha: isDark ? 0.74 : 0.64),
        height: 1.2,
      ),
      labelLarge: baseApplied.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      labelMedium: baseApplied.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      labelSmall: baseApplied.labelSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  static ColorScheme _homeColorScheme({
    required bool isDark,
    AcademyTheme? academyTheme,
  }) {
    final primary = academyTheme?.primaryColor ?? teal;
    final secondary = academyTheme?.secondaryColor ?? tealDark;
    final accent = academyTheme?.accentColor ?? orange;
    final background = academyTheme?.backgroundColor ?? bg;
    final text = academyTheme?.textColor ?? const Color(0xFF152724);

    final seed = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    if (isDark) {
      final darkPrimary = Color.lerp(primary, Colors.white, 0.22) ?? tealLight;
      final darkSecondary =
          Color.lerp(secondary, electricBlue, 0.28) ?? electricBlue;
      final darkAccent = Color.lerp(accent, orange, 0.24) ?? orange;
      return seed.copyWith(
        primary: darkPrimary,
        secondary: darkSecondary,
        tertiary: darkAccent,
        error: const Color(0xFFFF6B6B),
        surface: darkSurface,
        surfaceContainerHighest: const Color(0xFF25304A),
        surfaceContainerHigh: const Color(0xFF1B2538),
        surfaceContainer: const Color(0xFF141D2C),
        onSurface: const Color(0xFFF6F8FB),
        onSurfaceVariant: const Color(0xFFBAC4D5),
        outline: const Color(0xFF59667A),
        outlineVariant: const Color(0xFF2D3A50),
        surfaceTint: darkPrimary,
      );
    }

    return seed.copyWith(
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      surface: Color.lerp(background, Colors.white, 0.70) ?? lightSurface,
      surfaceContainerHighest:
          Color.lerp(background, primary, 0.08) ?? const Color(0xFFEAF1F0),
      surfaceContainerHigh:
          Color.lerp(background, Colors.white, 0.55) ?? const Color(0xFFF0F5F4),
      surfaceContainer:
          Color.lerp(background, Colors.white, 0.75) ?? const Color(0xFFF4F8F7),
      onSurface: text,
      onSurfaceVariant: const Color(0xFF536B74),
      outline: const Color(0xFF8AA0A7),
      outlineVariant: const Color(0xFFD5E0E3),
      surfaceTint: primary,
    );
  }

  static ThemeData _buildTheme({
    required bool isDark,
    AcademyTheme? academyTheme,
  }) {
    final resolvedFontFamily =
        academyTheme?.fontFamily.isNotEmpty == true
            ? academyTheme!.fontFamily
            : null;
    final base = ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    final cs = _homeColorScheme(isDark: isDark, academyTheme: academyTheme);
    final themedTextBase =
        resolvedFontFamily == null
            ? base.textTheme
            : base.textTheme.apply(fontFamily: resolvedFontFamily);
    final textTheme = _homeTextTheme(themedTextBase, cs, isDark: isDark);
    final cardColor =
        isDark
            ? const Color(0xE61A2335)
            : Colors.white.withValues(alpha: 0.90);
    final scaffoldBg = isDark ? darkScaffold : (academyTheme?.backgroundColor ?? bg);

    return base.copyWith(
      colorScheme: cs,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      primaryTextTheme:
          (resolvedFontFamily == null
                  ? base.primaryTextTheme
                  : base.primaryTextTheme.apply(fontFamily: resolvedFontFamily))
              .apply(bodyColor: cs.onSurface, displayColor: cs.onSurface),

      iconTheme: IconThemeData(color: cs.onSurface),
      splashColor: cs.primary.withValues(alpha: isDark ? 0.16 : 0.08),
      highlightColor: cs.primary.withValues(alpha: isDark ? 0.10 : 0.05),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant.withValues(alpha: isDark ? 0.55 : 0.7),
        thickness: 1,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: cs.onSurface,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),

      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: _radiusLarge,
          side: BorderSide(
            color: cs.outlineVariant.withValues(alpha: isDark ? 0.32 : 0.18),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        shape: RoundedRectangleBorder(borderRadius: _radiusMedium),
        tileColor: cs.surface.withValues(alpha: isDark ? 0.62 : 0.84),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),

      tabBarTheme: TabBarTheme(
        indicator: BoxDecoration(
          color: cs.primary.withValues(alpha: isDark ? 0.22 : 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withValues(alpha: 0.28)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurface.withValues(alpha: 0.68),
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
      ),

      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: isDark ? 0.55 : 0.7),
        ),
        backgroundColor: cs.surfaceContainer,
        selectedColor: cs.primary.withValues(alpha: isDark ? 0.25 : 0.14),
        secondarySelectedColor: cs.primary.withValues(
          alpha: isDark ? 0.25 : 0.14,
        ),
        checkmarkColor: cs.primary,
        labelStyle: textTheme.labelMedium,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.56),
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.74),
        ),
        border: OutlineInputBorder(
          borderRadius: _radiusMedium,
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _radiusMedium,
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: isDark ? 0.72 : 0.88),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _radiusMedium,
          borderSide: BorderSide(color: cs.primary, width: 1.6),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: _radiusMedium),
          textStyle: textTheme.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: _radiusMedium),
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: BorderSide(
            color: cs.outlineVariant.withValues(alpha: isDark ? 0.7 : 0.92),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: _radiusMedium),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: _radiusMedium),
          textStyle: textTheme.labelLarge,
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return cs.primary.withValues(alpha: isDark ? 0.26 : 0.14);
            }
            return cs.surfaceContainer;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return cs.primary;
            return cs.onSurface;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: cs.outlineVariant.withValues(alpha: 0.75)),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: _radiusMedium),
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.tertiary,
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.surfaceContainerHighest,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor.withValues(alpha: isDark ? 0.88 : 0.84),
        elevation: 0,
        indicatorColor: cs.primary.withValues(alpha: isDark ? 0.24 : 0.13),
        height: 68,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? cs.primary : cs.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? cs.primary : cs.onSurfaceVariant,
          );
        }),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor.withValues(alpha: isDark ? 0.88 : 0.84),
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: cardColor,
        selectedIconTheme: IconThemeData(color: cs.primary),
        unselectedIconTheme: IconThemeData(color: cs.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: cs.primary,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: cs.onSurfaceVariant,
        ),
      ),

      dialogTheme: DialogTheme(
        backgroundColor: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: _radiusLarge,
          side: BorderSide(
            color: cs.outlineVariant.withValues(alpha: isDark ? 0.4 : 0.22),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: cs.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: _radiusMedium),
      ),

      dataTableTheme: DataTableThemeData(
        headingTextStyle: textTheme.labelLarge,
        dataTextStyle: textTheme.bodyMedium,
        headingRowColor: WidgetStateProperty.all(
          cs.surfaceContainerHigh.withValues(alpha: 0.7),
        ),
        dataRowColor: WidgetStateProperty.all(
          cs.surface.withValues(alpha: isDark ? 0.68 : 0.9),
        ),
        dividerThickness: 0.8,
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(false),
        radius: const Radius.circular(14),
        thickness: WidgetStateProperty.all(6),
        thumbColor: WidgetStateProperty.all(
          cs.outline.withValues(alpha: isDark ? 0.62 : 0.52),
        ),
        trackColor: WidgetStateProperty.all(cs.surfaceContainerHighest),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: cs.inverseSurface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _softShadow(isDark: isDark),
        ),
        textStyle: textTheme.labelMedium?.copyWith(color: cs.onInverseSurface),
      ),
    );
  }

  static ThemeData light({AcademyTheme? academyTheme}) {
    return _buildTheme(isDark: false, academyTheme: academyTheme);
  }

  static ThemeData dark({AcademyTheme? academyTheme}) {
    return _buildTheme(isDark: true, academyTheme: academyTheme);
  }
}


