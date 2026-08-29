import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/navigation/cubit/navigation_cubit.dart';

/// Unified Header Actions Widget for Stockbit Pro Terminal.
/// Provides consistent BUY, Open Trading Account, Messages/Notifications badges,
/// and Profile Avatar across all screens and sub-headers.
class DesktopHeaderActions extends StatelessWidget {
  /// The stock symbol to prepopulate when BUY button is pressed.
  final String? activeSymbol;

  /// Custom action widgets inserted before the BUY button (e.g. Grid selector, Add Window).
  final List<Widget>? leadingActions;

  /// Custom action widgets inserted after Open Trading Account and before badges.
  final List<Widget>? trailingActions;

  /// Whether to display the BUY button (default: true).
  final bool showBuy;

  /// Whether to display the 'Open Trading Account' button (default: true).
  final bool showOpenTradingAccount;

  /// Whether to display the notification & message badges (default: true).
  final bool showBadges;

  /// Whether to display the profile avatar with online indicator (default: true).
  final bool showProfile;

  const DesktopHeaderActions({
    super.key,
    this.activeSymbol,
    this.leadingActions,
    this.trailingActions,
    this.showBuy = true,
    this.showOpenTradingAccount = true,
    this.showBadges = true,
    this.showProfile = true,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = activeSymbol ?? 'BBCA';

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── 1. Optional Leading Actions ───────────────────────────────────
        if (leadingActions != null) ...[
          for (final widget in leadingActions!) ...[
            widget,
            const SizedBox(width: 6),
          ],
        ],

        // ── 2. Quick BUY Button ───────────────────────────────────────────
        if (showBuy) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 0,
              ),
              minimumSize: const Size(50, 26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 0,
            ),
            onPressed: () {
              context.read<NavigationCubit>().navigateToOrder(
                symbol: symbol,
                isBuy: true,
              );
            },
            child: const Text(
              'BUY',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
        ],

        // ── 3. Open Trading Account Button ────────────────────────────────
        if (showOpenTradingAccount) ...[
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppColors.primaryDark,
                width: 0.9,
              ),
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 0,
              ),
              minimumSize: const Size(130, 26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () {
              // Open trading account flow
            },
            child: const Text(
              'Open Trading Account',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // ── 4. Optional Trailing Actions ──────────────────────────────────
        if (trailingActions != null) ...[
          for (final widget in trailingActions!) ...[
            widget,
            const SizedBox(width: 6),
          ],
        ],

        // ── 5. Messages Badge (24) ────────────────────────────────────────
        if (showBadges) ...[
          _buildIconBadge(
            icon: Icons.chat_bubble_outline,
            badgeText: '24',
            badgeColor: AppColors.badgeBlue,
          ),
          const SizedBox(width: 6),

          // Notifications Badge (99+)
          _buildIconBadge(
            icon: Icons.notifications_none_outlined,
            badgeText: '99+',
            badgeColor: AppColors.primaryDark,
          ),
          const SizedBox(width: 8),
        ],

        // ── 6. Profile Avatar with Active Green Dot ───────────────────────
        if (showProfile) const UserProfileAvatar(),
      ],
    );
  }

  Widget _buildIconBadge({
    required IconData icon,
    required String badgeText,
    required Color badgeColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        Positioned(
          top: -4,
          right: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 1),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Standardized User Profile Avatar across all headers and navigation.
class UserProfileAvatar extends StatelessWidget {
  final double size;

  const UserProfileAvatar({super.key, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Center(
            child: Icon(
              Icons.person,
              size: size * 0.58,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBg, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
