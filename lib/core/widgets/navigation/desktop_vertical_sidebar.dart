import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/navigation/cubit/navigation_cubit.dart';
import 'package:stockbit_clone2/core/navigation/cubit/navigation_state.dart';
import 'package:stockbit_clone2/core/navigation/models/app_nav_tab.dart';
import 'package:stockbit_clone2/core/blocs/auth/auth_bloc.dart';
import 'package:stockbit_clone2/core/blocs/auth/auth_event.dart';

/// Left Vertical Sidebar Navigation (50px wide) styled cleanly after Stockbit Pro.
/// Features clean subtle indicators on active tab with no harsh glows.
class DesktopVerticalSidebar extends StatelessWidget {
  const DesktopVerticalSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(right: BorderSide(color: AppColors.border, width: 0.8)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ── Main Navigation Tab Items ─────────────────────────────────────
          Expanded(
            child: BlocBuilder<NavigationCubit, NavigationState>(
              builder: (context, navState) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: AppNavTab.values.map((tab) {
                    final isSelected = navState.tab == tab;
                    return _SidebarItem(
                      tab: tab,
                      isSelected: isSelected,
                      onTap: () =>
                          context.read<NavigationCubit>().selectTab(tab),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // ── Bottom Section: Settings & Logout ────────────────────────────
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 4),

          _SidebarIconButton(
            icon: Icons.tune_outlined,
            tooltip: 'Settings',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings dialog opened'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          _SidebarIconButton(
            icon: Icons.logout_outlined,
            tooltip: 'Sign Out',
            iconColor: AppColors.textMuted,
            onTap: () => _confirmSignOut(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text(
          'Sign Out',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        ),
        content: const Text(
          'Are you sure you want to sign out of Stockbit Pro?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutEvent());
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.offerRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final AppNavTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tab.label,
      preferBelow: false,
      waitDuration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cardSurface : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                tab.icon,
                size: 19,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textMuted,
              ),
              const SizedBox(height: 2),
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color iconColor;

  const _SidebarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 38,
          child: Center(child: Icon(icon, size: 18, color: iconColor)),
        ),
      ),
    );
  }
}
