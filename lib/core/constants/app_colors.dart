import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background Colors
  static const Color background = Color(0xFF0C0E12);
  static const Color canvasBg = Color(0xFF0F1218);
  static const Color sidebarBg = Color(0xFF12151B);
  static const Color cardBg = Color(0xFF161A22);
  static const Color cardSurface = Color(0xFF1C212B);
  static const Color cardHeader = Color(0xFF191E27);
  static const Color headerBg = Color(0xFF12151B);
  static const Color tableRowAlt = Color(0xFF14171E);
  static const Color tableRowHover = Color(0xFF202735);

  // Border & Divider Colors
  static const Color border = Color(0xFF242A36);
  static const Color borderLight = Color(0xFF2F3746);
  static const Color borderActive = Color(0xFF00C076);
  static const Color divider = Color(0xFF1F2530);

  // Market Action Colors
  static const Color bidGreen = Color(0xFF00C076);
  static const Color bidGreenSubtle = Color(0x2400C076);
  static const Color offerRed = Color(0xFFF43F5E);
  static const Color offerRedSubtle = Color(0x24F43F5E);
  static const Color araYellow = Color(0xFFFBBF24);
  static const Color arbPurple = Color(0xFFA855F7);
  static const Color neutral = Color(0xFF94A3B8);

  // Brand / Action Colors
  static const Color primaryGreen = Color(0xFF00C076);
  static const Color primaryGreenDark = Color(0xFF00965B);
  static const Color badgeBlue = Color(0xFF38BDF8);
  static const Color badgePurple = Color(0xFFA78BFA);

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFFFFFFFF);

  // Tab Colors
  static const Color activeTabBg = Color(0xFF1C212B);
  static const Color inactiveTabBg = Color(0xFF12151B);
  static const Color tabIndicator = Color(0xFF00C076);

  // Glow Shadows
  static List<BoxShadow> get activeGlow => [
        BoxShadow(
          color: const Color(0xFF00C076).withValues(alpha: 0.25),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> get windowShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 12,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ];
}
