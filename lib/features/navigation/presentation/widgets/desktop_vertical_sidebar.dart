import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:stockbit_clone2/features/auth/presentation/bloc/auth_event.dart';
import 'package:stockbit_clone2/features/navigation/domain/entities/app_nav_tab.dart';
import 'package:stockbit_clone2/features/navigation/presentation/cubit/navigation_cubit.dart';

/// Left Vertical Sidebar Navigation (Stockbit Pro Style).
///
/// Follows Separation of Concerns (SoC) & Clean Architecture:
/// - Displays Stockbit Logo, Vertical Navigation Items, and Bottom Utility Actions.
/// - Wrapped with SingleChildScrollView to prevent vertical RenderFlex overflow on small window sizes.
class DesktopVerticalSidebar extends StatelessWidget {
  const DesktopVerticalSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, AppNavTab>(
      builder: (context, activeTab) {
        return Container(
          width: 68,
          decoration: const BoxDecoration(
            color: AppColors.sidebarBg,
            border: Border(
              right: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Column(
            children: [
              // ── 1. Top Logo ──────────────────────────────────────────────
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: AppColors.primaryDark,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: AppColors.border, height: 1, indent: 8, endIndent: 8),
              const SizedBox(height: 4),

              // ── 2. Vertical Navigation Menu Items ────────────────────────
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: AppNavTab.values.map((tab) {
                    final isSelected = activeTab == tab;
                    return _buildSidebarItem(
                      context: context,
                      tab: tab,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<NavigationCubit>().selectTab(tab);
                      },
                    );
                  }).toList(),
                ),
              ),

              // ── 3. Bottom Utility Icons (Alerts, Settings, Logout) ───────
              const Divider(color: AppColors.border, height: 1, indent: 8, endIndent: 8),
              const SizedBox(height: 4),

              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, size: 17, color: AppColors.textSecondary),
                tooltip: 'Price Alerts',
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                onPressed: () {},
              ),
              const SizedBox(height: 4),

              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 17, color: AppColors.textSecondary),
                tooltip: 'Terminal Settings',
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                onPressed: () {},
              ),
              const SizedBox(height: 4),

              // Logout Button
              Tooltip(
                message: 'Sign Out / Lock Terminal',
                child: IconButton(
                  icon: const Icon(Icons.logout, size: 16, color: AppColors.offerRed),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutEvent());
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarItem({
    required BuildContext context,
    required AppNavTab tab,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(vertical: 1.5),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primaryDark : Colors.transparent,
              width: 3,
            ),
          ),
          color: isSelected
              ? AppColors.primaryDark.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tab.icon,
              size: 19,
              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
