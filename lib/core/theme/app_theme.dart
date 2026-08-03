import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────────────────────────
//  THRYVE THEME
//  Usage in app.dart:
//
//    MaterialApp(
//      theme:      ThryvTheme.light,
//      darkTheme:  ThryvTheme.dark,
//      themeMode:  ThemeMode.system,
//    )
// ─────────────────────────────────────────────────────────────────

class ThryvTheme {
  ThryvTheme._();

  // ── Light ───────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3:  true,
    colorScheme:   ThryvColorScheme.light,
    brightness:    Brightness.light,
    scaffoldBackgroundColor: ThryvColors.background,
    textTheme:     _textTheme(ThryvColors.onSurface),
    appBarTheme:   _appBarTheme(Brightness.light),
    elevatedButtonTheme: _elevatedButtonTheme(
      bg:   ThryvColors.primary,
      fg:   ThryvColors.onPrimary,
    ),
    outlinedButtonTheme: _outlinedButtonTheme(ThryvColors.primary),
    textButtonTheme:     _textButtonTheme(ThryvColors.primary),
    inputDecorationTheme: _inputDecorationTheme(
      fill:    ThryvColors.surfaceContainerLow,
      border:  ThryvColors.outlineVariant,
      focused: ThryvColors.primary,
    ),
    cardTheme:     _cardTheme(
      color:  ThryvColors.surface,
      border: ThryvColors.outlineVariant,
    ),
    chipTheme:     _chipTheme(
      bg:   ThryvColors.secondaryContainer,
      fg:   ThryvColors.onSecondaryContainer,
    ),
    dividerTheme: const DividerThemeData(
      color: ThryvColors.outlineVariant,
      thickness: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color:            ThryvColors.primary,
      linearTrackColor: ThryvColors.surfaceContainerHigh,
    ),
    iconTheme: const IconThemeData(color: ThryvColors.onSurfaceVariant),
    bottomNavigationBarTheme: _bottomNavTheme(
      bg:       ThryvColors.surface,
      selected: ThryvColors.primary,
      unselected: ThryvColors.outline,
    ),
  );

  // ── Dark ────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3:  true,
    colorScheme:   ThryvColorScheme.dark,
    brightness:    Brightness.dark,
    scaffoldBackgroundColor: ThryvColors.backgroundDark,
    textTheme:     _textTheme(ThryvColors.onSurfaceDark),
    appBarTheme:   _appBarTheme(Brightness.dark),
    elevatedButtonTheme: _elevatedButtonTheme(
      bg:   ThryvColors.primaryDark,
      fg:   ThryvColors.onPrimaryDark,
    ),
    outlinedButtonTheme: _outlinedButtonTheme(ThryvColors.primaryDark),
    textButtonTheme:     _textButtonTheme(ThryvColors.primaryDark),
    inputDecorationTheme: _inputDecorationTheme(
      fill:    ThryvColors.surfaceContainerLowDark,
      border:  ThryvColors.outlineVariantDark,
      focused: ThryvColors.primaryDark,
    ),
    cardTheme:     _cardTheme(
      color:  ThryvColors.surfaceDark,
      border: ThryvColors.outlineVariantDark,
    ),
    chipTheme:     _chipTheme(
      bg:   ThryvColors.secondaryContainerDark,
      fg:   ThryvColors.onSecondaryContainerDark,
    ),
    dividerTheme: const DividerThemeData(
      color: ThryvColors.outlineVariantDark,
      thickness: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color:            ThryvColors.primaryDark,
      linearTrackColor: ThryvColors.surfaceContainerHighDark,
    ),
    iconTheme: const IconThemeData(color: ThryvColors.onSurfaceVariantDark),
    bottomNavigationBarTheme: _bottomNavTheme(
      bg:         ThryvColors.surfaceDark,
      selected:   ThryvColors.primaryDark,
      unselected: ThryvColors.outlineDark,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
//  PRIVATE HELPERS
// ─────────────────────────────────────────────────────────────────

TextTheme _textTheme(Color baseColor) => TextTheme(
  // Headlines — Inter (swap to Geist once bundled in assets)
  displayLarge:   GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w600,
      height: 1.2, letterSpacing: -0.02, color: baseColor),
  displayMedium:  GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600,
      height: 1.25, letterSpacing: -0.02, color: baseColor),
  displaySmall:   GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600,
      height: 1.3, letterSpacing: -0.01, color: baseColor),
  headlineLarge:  GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700,
      height: 1.3, letterSpacing: -0.01, color: baseColor),
  headlineMedium: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600,
      height: 1.35, color: baseColor),
  headlineSmall:  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600,
      height: 1.4, color: baseColor),

  // Body — Inter
  bodyLarge:   GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400,
      height: 1.55, color: baseColor),
  bodyMedium:  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400,
      height: 1.5, color: baseColor),
  bodySmall:   GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400,
      height: 1.43, color: baseColor),

  // Labels — Inter semi-bold / JetBrains Mono for dark (swap in app_text_styles)
  labelLarge:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
      height: 1.43, letterSpacing: 0.01, color: baseColor),
  labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
      height: 1.33, letterSpacing: 0.05, color: baseColor),
  labelSmall:  GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500,
      height: 1.45, letterSpacing: 0.05, color: baseColor),
);

AppBarTheme _appBarTheme(Brightness brightness) => AppBarTheme(
  backgroundColor: Colors.transparent,
  elevation: 0,
  scrolledUnderElevation: 0,
  centerTitle: false,
  iconTheme: IconThemeData(
    color: brightness == Brightness.light
        ? ThryvColors.onSurface
        : ThryvColors.onSurfaceDark,
  ),
  titleTextStyle: GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w800,
    color: brightness == Brightness.light
        ? ThryvColors.primary
        : ThryvColors.primaryDark,
    letterSpacing: -0.5,
  ),
);

ElevatedButtonThemeData _elevatedButtonTheme({
  required Color bg,
  required Color fg,
}) =>
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 4,
        shadowColor: bg.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        textStyle: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );

OutlinedButtonThemeData _outlinedButtonTheme(Color primary) =>
    OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );

TextButtonThemeData _textButtonTheme(Color primary) =>
    TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );

InputDecorationTheme _inputDecorationTheme({
  required Color fill,
  required Color border,
  required Color focused,
}) =>
    InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: focused, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(
          fontSize: 16, color: border, fontWeight: FontWeight.w400),
    );

CardThemeData _cardTheme({required Color color, required Color border}) =>
    CardThemeData(
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
      margin: EdgeInsets.zero,
    );

ChipThemeData _chipTheme({required Color bg, required Color fg}) =>
    ChipThemeData(
      backgroundColor: bg,
      labelStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: const StadiumBorder(),
    );

BottomNavigationBarThemeData _bottomNavTheme({
  required Color bg,
  required Color selected,
  required Color unselected,
}) =>
    BottomNavigationBarThemeData(
      backgroundColor: bg,
      selectedItemColor: selected,
      unselectedItemColor: unselected,
      selectedLabelStyle:
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
