import 'dart:ui';

/// Centralized visual tokens derived strictly from docs/DESIGN.md.
abstract final class AppTokens {
  // Brand and surface colors
  static const primary = Color(0xFF1D4ED8);
  static const primaryDark = Color(0xFF1E3A8A);
  static const primarySoft = Color(0xFFDBE7FB);
  static const background = Color(0xFFF3F7FE);
  static const surface = Color(0xFFFFFFFF);
  static const outline = Color(0xFFC9D6EC);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const onPrimary = Color(0xFFFFFFFF);

  // Semantic status colors
  static const statusOnSite = Color(0xFF15803D);
  static const statusOnSiteSoft = Color(0xFFDCFCE7);
  static const statusHousingOnly = Color(0xFFB45309);
  static const statusHousingOnlySoft = Color(0xFFFEF3C7);
  static const statusUnknown = Color(0xFFB91C1C);
  static const statusUnknownSoft = Color(0xFFFEE2E2);
  static const statusJustified = Color(0xFF0E7490);
  static const statusJustifiedSoft = Color(0xFFCFFAFE);
  static const statusNotRecorded = Color(0xFF64748B);
  static const statusNotRecordedSoft = Color(0xFFE2E8F0);

  // Translucent so row state colours (present/absent) remain visible.
  static const searchHighlight = Color(0x40F59E0B);

  // Spacing & Layout
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  static const double radius12 = 12.0;
  static const double radiusChip = 999.0;

  static const double minTouchTarget = 56.0;
  static const double minRowHeight = 64.0;
}
