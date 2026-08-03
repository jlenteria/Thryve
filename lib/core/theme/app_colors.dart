import 'dart:ui';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
//  THRYVE COLOR TOKENS
//  Source: Google Stitch export
//  Light  → Emerald Clarity
//  Dark   → Emerald Nocturne
// ─────────────────────────────────────────────────────────────────

class ThryvColors {
  ThryvColors._();
  
  // ── Light theme (Emerald Clarity) ──────────────────────────────
  static const Color background             = Color(0xFFFAFBFA);
  static const Color surface                = Color(0xFFFFFFFF);
  static const Color surfaceContainer       = Color(0xFFF4F5F4);
  static const Color surfaceContainerLow    = Color(0xFFF0F1F0);
  static const Color surfaceContainerHigh   = Color(0xFFE2E3E2);
  static const Color primary                = Color(0xFF006D41);
  static const Color onPrimary              = Color(0xFFFFFFFF);
  static const Color primaryContainer       = Color(0xFF60F3A6);
  static const Color onPrimaryContainer     = Color(0xFF003920);
  static const Color secondaryContainer     = Color(0xFFD7E6DF);
  static const Color onSecondaryContainer   = Color(0xFF0F1E19);
  static const Color onSurface             = Color(0xFF1A1C1B);
  static const Color onSurfaceVariant      = Color(0xFF404943);
  static const Color outlineVariant         = Color(0xFFC0C9C1);
  static const Color outline               = Color(0xFF707973);
  static const Color error                  = Color(0xFFBA1A1A);
  static const Color onError                = Color(0xFFFFFFFF);
 

  // ── Dark theme (Emerald Nocturne) ──────────────────────────────
  static const Color backgroundDark             = Color(0xFF101413);
  static const Color surfaceDark                = Color(0xFF1C201F);
  static const Color surfaceContainerDark       = Color(0xFF1C201F);
  static const Color surfaceContainerLowDark    = Color(0xFF181C1B);
  static const Color surfaceContainerHighDark   = Color(0xFF272B2A);
  static const Color primaryDark                = Color(0xFF60F3A6);
  static const Color onPrimaryDark              = Color(0xFF003920);
  static const Color primaryContainerDark       = Color(0xFF3DD68C);
  static const Color onPrimaryContainerDark     = Color(0xFF005834);
  static const Color secondaryContainerDark     = Color(0xFF3F4C47);
  static const Color onSecondaryContainerDark   = Color(0xFFADBCB5);
  static const Color onSurfaceDark             = Color(0xFFE0E3E1);
  static const Color onSurfaceVariantDark      = Color(0xFFBBCABD);
  static const Color outlineVariantDark         = Color(0xFF3C4A40);
  static const Color outlineDark               = Color(0xFF869488);
  static const Color errorDark                  = Color(0xFFFFB4AB);
  static const Color onErrorDark                = Color(0xFF690005);

  // ── Shared accent (same in both themes) ────────────────────────
  static const Color emeraldAccent             = Color(0xFF3DD68C);
  static const Color emeraldAccentDim          = Color(0xFF49E095);
}


// ─────────────────────────────────────────────────────────────────
//  COLOR SCHEME FACTORIES
//  Usage:
//    ThemeData.light().copyWith(colorScheme: ThryvColorScheme.light)
//    ThemeData.dark().copyWith(colorScheme:  ThryvColorScheme.dark)
// ─────────────────────────────────────────────────────────────────

class ThryvColorScheme {
  ThryvColorScheme._();
 
  static const ColorScheme light = ColorScheme(
    brightness:            Brightness.light,
    surface:               ThryvColors.surface,
    surfaceContainerLow:   ThryvColors.surfaceContainerLow,
    surfaceContainer:      ThryvColors.surfaceContainer,
    surfaceContainerHigh:  ThryvColors.surfaceContainerHigh,
    primary:               ThryvColors.primary,
    onPrimary:             ThryvColors.onPrimary,
    primaryContainer:      ThryvColors.primaryContainer,
    onPrimaryContainer:    ThryvColors.onPrimaryContainer,
    secondary:             ThryvColors.secondaryContainer,
    onSecondary:           ThryvColors.onSecondaryContainer,
    secondaryContainer:    ThryvColors.secondaryContainer,
    onSecondaryContainer:  ThryvColors.onSecondaryContainer,
    onSurface:             ThryvColors.onSurface,
    onSurfaceVariant:      ThryvColors.onSurfaceVariant,
    outline:               ThryvColors.outline,
    outlineVariant:        ThryvColors.outlineVariant,
    error:                 ThryvColors.error,
    onError:               ThryvColors.onError,
    tertiary:              ThryvColors.emeraldAccent,
    onTertiary:            ThryvColors.onPrimary,
  );
 
  static const ColorScheme dark = ColorScheme(
    brightness:            Brightness.dark,
    surface:               ThryvColors.surfaceDark,
    surfaceContainerLow:   ThryvColors.surfaceContainerLowDark,
    surfaceContainer:      ThryvColors.surfaceContainerDark,
    surfaceContainerHigh:  ThryvColors.surfaceContainerHighDark,
    primary:               ThryvColors.primaryDark,
    onPrimary:             ThryvColors.onPrimaryDark,
    primaryContainer:      ThryvColors.primaryContainerDark,
    onPrimaryContainer:    ThryvColors.onPrimaryContainerDark,
    secondary:             ThryvColors.secondaryContainerDark,
    onSecondary:           ThryvColors.onSecondaryContainerDark,
    secondaryContainer:    ThryvColors.secondaryContainerDark,
    onSecondaryContainer:  ThryvColors.onSecondaryContainerDark,
    onSurface:             ThryvColors.onSurfaceDark,
    onSurfaceVariant:      ThryvColors.onSurfaceVariantDark,
    outline:               ThryvColors.outlineDark,
    outlineVariant:        ThryvColors.outlineVariantDark,
    error:                 ThryvColors.errorDark,
    onError:               ThryvColors.onErrorDark,
    tertiary:              ThryvColors.emeraldAccent,
    onTertiary:            ThryvColors.onPrimaryDark,
  );
}
