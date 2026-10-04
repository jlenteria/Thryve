import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
//  THRYVE COLOR TOKENS
//  Light → Emerald Clarity   Dark → Emerald Nocturne
//
//  Widgets never read these directly — use `context.colors` (the active
//  ColorScheme) so every screen follows the selected theme.
// ─────────────────────────────────────────────────────────────────

abstract final class AppColorSchemes {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF006D41),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF3DD68C),
    onPrimaryContainer: Color(0xFF005834),
    inversePrimary: Color(0xFF49E095),
    secondary: Color(0xFF5D5F5D),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD7E6DF),
    onSecondaryContainer: Color(0xFF0F1E19),
    tertiary: Color(0xFF5B5F5E),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFBBBEBC),
    onTertiaryContainer: Color(0xFF494D4C),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFF8FAF9),
    onSurface: Color(0xFF191C1C),
    onSurfaceVariant: Color(0xFF3C4A40),
    surfaceDim: Color(0xFFD9DAD9),
    surfaceBright: Color(0xFFF8FAF9),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF3F4F3),
    surfaceContainer: Color(0xFFEDEEED),
    surfaceContainerHigh: Color(0xFFE7E8E7),
    surfaceContainerHighest: Color(0xFFE1E3E2),
    outline: Color(0xFF6C7B6F),
    outlineVariant: Color(0xFFBBCABD),
    inverseSurface: Color(0xFF2E3131),
    onInverseSurface: Color(0xFFF0F1F0),
    surfaceTint: Color(0xFF006D41),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF60F3A6),
    onPrimary: Color(0xFF003920),
    primaryContainer: Color(0xFF005231),
    onPrimaryContainer: Color(0xFF72F7A9),
    inversePrimary: Color(0xFF006D41),
    secondary: Color(0xFFB8CCBC),
    onSecondary: Color(0xFF233329),
    secondaryContainer: Color(0xFF3F4C47),
    onSecondaryContainer: Color(0xFFD3E8DA),
    tertiary: Color(0xFF3DD68C),
    onTertiary: Color(0xFF003920),
    tertiaryContainer: Color(0xFF2D3A33),
    onTertiaryContainer: Color(0xFFC6D3CB),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF101413),
    onSurface: Color(0xFFE0E3E1),
    onSurfaceVariant: Color(0xFFBBCABD),
    surfaceDim: Color(0xFF101413),
    surfaceBright: Color(0xFF363A39),
    surfaceContainerLowest: Color(0xFF1A201C),
    surfaceContainerLow: Color(0xFF181C1B),
    surfaceContainer: Color(0xFF1C201F),
    surfaceContainerHigh: Color(0xFF272B2A),
    surfaceContainerHighest: Color(0xFF323634),
    outline: Color(0xFF869488),
    outlineVariant: Color(0xFF3C4A40),
    inverseSurface: Color(0xFFE0E3E1),
    onInverseSurface: Color(0xFF2E3131),
    surfaceTint: Color(0xFF60F3A6),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
}
