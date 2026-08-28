import 'package:flutter/material.dart';

/// Official Professional Financial Theme Color Palette.
class AppColors {
  AppColors._();

  // ─── Mandatory Official Palette ──────────────────────────────────────────────
  static const Color primaryLight = Color(0xFF00875A);
  static const Color primaryDark = Color(0xFF10B981);
  static const Color systemBackgroundLight = Color(0xFFFDFDFD);
  static const Color systemBackgroundDark = Color(0xFF0F0F0F);
  static const Color systemGroupedBackgroundLight = Color(0xFFF7F7F7);
  static const Color systemGroupedBackgroundDark = Color(0xFF141414);

  // ─── Dark Terminal Trading Palette ───────────────────────────────────────────
  static const Color background = systemBackgroundDark; // #0F0F0F
  static const Color canvasBg = systemGroupedBackgroundDark; // #141414
  static const Color sidebarBg = Color(0xFF111111);
  static const Color headerBg = Color(0xFF141414);
  static const Color cardBg = Color(0xFF191919);
  static const Color cardSurface = Color(0xFF1F1F1F);
  static const Color cardHeader = Color(0xFF181818);
  static const Color tableRowAlt = Color(0xFF161616);
  static const Color tableRowHover = Color(0xFF242424);

  // ─── Borders & Dividers ──────────────────────────────────────────────────────
  static const Color border = Color(0xFF282828);
  static const Color borderLight = Color(0xFF333333);
  static const Color borderActive = primaryDark; // #10B981
  static const Color divider = Color(0xFF222222);

  // ─── Financial Precision Colors ──────────────────────────────────────────────
  static const Color bidGreen = primaryDark; // #10B981 (Up / Positive)
  static const Color bidGreenSubtle = Color(0x2410B981);
  static const Color offerRed = Color(0xFFEF4444); // #EF4444 (Down / Negative)
  static const Color offerRedSubtle = Color(0x24EF4444);
  static const Color araYellow = Color(0xFFF59E0B);
  static const Color arbPurple = Color(0xFFA855F7);
  static const Color neutral = Color(0xFF9E9E9E);

  // ─── Brand & Accents ─────────────────────────────────────────────────────────
  static const Color primaryGreen = primaryDark; // #10B981
  static const Color primaryGreenDark = primaryLight; // #00875A
  static const Color badgeBlue = Color(0xFF38BDF8);
  static const Color badgePurple = Color(0xFFA78BFA);

  // ─── Typography Colors ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);

  // ─── Tab Colors ──────────────────────────────────────────────────────────────
  static const Color activeTabBg = Color(0xFF1F1F1F);
  static const Color inactiveTabBg = Color(0xFF141414);
  static const Color tabIndicator = primaryDark;

  // ─── Shadows ─────────────────────────────────────────────────────────────────
  static List<BoxShadow> get activeGlow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 10,
      spreadRadius: 1,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> get windowShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.6),
      blurRadius: 12,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];
}
