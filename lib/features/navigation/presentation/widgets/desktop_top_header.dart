import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_state.dart';
import 'package:stockbit_clone2/core/workspace/widgets/add_widget_dialog.dart';
import 'package:stockbit_clone2/features/layout/presentation/widgets/layout_template_gallery_dialog.dart';
import 'package:stockbit_clone2/features/navigation/domain/entities/app_nav_tab.dart';
import 'package:stockbit_clone2/features/navigation/presentation/cubit/navigation_cubit.dart';

/// Top Workspace Toolbar Header (matching Stockbit Pro Desktop reference design).
///
/// Features:
/// - Tabs on the left with clean bottom underline.
/// - Search Symbol input.
/// - Grid Presets & Auto Arrange.
/// - + Add Window Button.
/// - Quick BUY & Open Trading Account buttons.
/// - Messages (24), Notifications (99+) badges, and Profile Avatar with green status dot.
class DesktopTopHeader extends StatelessWidget {
  const DesktopTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        int activeTabIndex = 0;
        int gridRows = 2;
        int gridCols = 4;

        if (state is WorkspaceLoadedState) {
          activeTabIndex = state.activeTabIndex;
          gridRows = state.gridRows;
          gridCols = state.gridColumns;
        }

        final tabs = state is WorkspaceLoadedState ? state.tabs : [];

        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 38,
              width: constraints.maxWidth,
              decoration: const BoxDecoration(
                color: AppColors.headerBg,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ── 1. Left Side: Tabs & Search ─────────────────────────
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Workspace Tabs Bar (Active Indicator on BOTTOM)
                          ...tabs.asMap().entries.map((entry) {
                            final index = entry.key;
                            final tab = entry.value;
                            final isActiveTab = index == activeTabIndex;

                            return InkWell(
                              onTap: () {
                                context.read<WorkspaceBloc>().add(
                                  SelectWorkspaceTabEvent(index),
                                );
                              },
                              child: Container(
                                height: 38,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: isActiveTab
                                      ? AppColors.activeTabBg
                                      : AppColors.inactiveTabBg,
                                  border: Border(
                                    right: const BorderSide(
                                      color: AppColors.border,
                                      width: 1,
                                    ),
                                    bottom: BorderSide(
                                      color: isActiveTab
                                          ? AppColors.primaryDark
                                          : Colors.transparent,
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.dashboard_customize_outlined,
                                      size: 13,
                                      color: isActiveTab
                                          ? AppColors.primaryDark
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      tab.title,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isActiveTab
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isActiveTab
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    if (tabs.length > 1) ...[
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          context.read<WorkspaceBloc>().add(
                                            CloseWorkspaceTabEvent(index),
                                          );
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Add Workspace Tab (+) - Opens Template Picker Gallery
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 15,
                              color: AppColors.textSecondary,
                            ),
                            tooltip:
                                'Add New Workspace Layout (Choose Template)',
                            onPressed: () {
                              final mediaSize = MediaQuery.of(context).size;
                              final availableWidth = mediaSize.width - 68;
                              final availableHeight =
                                  mediaSize.height - 38 - 26 - 30;
                              LayoutTemplateGalleryDialog.show(
                                context,
                                Size(availableWidth, availableHeight),
                              );
                            },
                          ),

                          const SizedBox(width: 4),
                          const SizedBox(
                            height: 20,
                            child: VerticalDivider(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Search Symbol Field
                          Container(
                            width: 180,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: TextField(
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textPrimary,
                              ),
                              onSubmitted: (value) {
                                context.read<WorkspaceBloc>().add(
                                  GlobalSearchSymbolEvent(value),
                                );
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textMuted,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: 13,
                                  color: AppColors.textMuted,
                                ),
                                prefixIconConstraints: BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 16),

                      // ── 2. Right Side: Actions, BUY, Account, Badges & Profile
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Grid Preset Selector
                          PopupMenuButton<Map<String, int>>(
                            tooltip: 'Select Grid Presets',
                            color: AppColors.cardBg,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.view_quilt_outlined,
                                    size: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$gridRows × $gridCols',
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                            itemBuilder: (_) => [
                              _buildPresetItem(
                                '2 × 4 (8 Slots - Standard)',
                                2,
                                4,
                              ),
                              _buildPresetItem(
                                '2 × 3 (6 Slots - Balanced)',
                                2,
                                3,
                              ),
                              _buildPresetItem('2 × 2 (4 Quad View)', 2, 2),
                              _buildPresetItem(
                                '3 × 4 (12 Slots - Compact Desk)',
                                3,
                                4,
                              ),
                              _buildPresetItem('3 × 3 (9 Slots - Grid)', 3, 3),
                              _buildPresetItem(
                                '2 × 5 (10 Slots - Mini Tiles)',
                                2,
                                5,
                              ),
                              _buildPresetItem(
                                '1 × 4 (4 Columns Horizontal)',
                                1,
                                4,
                              ),
                              _buildPresetItem('1 × 3 (3 Columns Focus)', 1, 3),
                              _buildPresetItem('1 × 2 (2 Split Screen)', 1, 2),
                              _buildPresetItem(
                                '1 × 1 (Single Max Focus)',
                                1,
                                1,
                              ),
                            ],
                            onSelected: (val) {
                              final mediaSize = MediaQuery.of(context).size;
                              final availableWidth = mediaSize.width - 68;
                              final availableHeight =
                                  mediaSize.height - 38 - 26 - 30;
                              context.read<WorkspaceBloc>().add(
                                SetGridPresetEvent(
                                  rows: val['rows']!,
                                  columns: val['cols']!,
                                  canvasSize: Size(
                                    availableWidth,
                                    availableHeight,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(width: 6),

                          // Add Window Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cardSurface,
                              foregroundColor: AppColors.primaryDark,
                              side: const BorderSide(
                                color: AppColors.primaryDark,
                                width: 0.8,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              minimumSize: const Size(82, 26),
                              elevation: 0,
                            ),
                            onPressed: () {
                              final mediaSize = MediaQuery.of(context).size;
                              final availableWidth = mediaSize.width - 68;
                              final availableHeight =
                                  mediaSize.height - 38 - 26 - 30;
                              AddWidgetDialog.show(
                                context,
                                Size(availableWidth, availableHeight),
                              );
                            },
                            icon: const Icon(
                              Icons.add,
                              size: 13,
                              color: AppColors.primaryDark,
                            ),
                            label: const Text(
                              'Add Window',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          // Arrange Windows Button (Neatly arranges positions without resizing)
                          Tooltip(
                            message:
                                'Auto-arrange and tidy up window positions without resizing',
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cardSurface,
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(
                                  color: AppColors.border,
                                  width: 0.8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 0,
                                ),
                                minimumSize: const Size(78, 26),
                                elevation: 0,
                              ),
                              onPressed: () {
                                final mediaSize = MediaQuery.of(context).size;
                                final availableWidth = mediaSize.width - 68;
                                final availableHeight =
                                    mediaSize.height - 38 - 26 - 30;
                                context.read<WorkspaceBloc>().add(
                                  AutoArrangeWindowsEvent(
                                    Size(availableWidth, availableHeight),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.auto_awesome_mosaic_outlined,
                                size: 12,
                                color: AppColors.primaryGreen,
                              ),
                              label: const Text(
                                'Arrange',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          // Quick BUY Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 0,
                              ),
                              minimumSize: const Size(46, 26),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              context.read<NavigationCubit>().selectTab(
                                AppNavTab.order,
                              );
                            },
                            child: const Text(
                              'BUY',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          // Open Trading Account Button (from screenshot reference)
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
                            onPressed: () {},
                            child: const Text(
                              'Open Trading Account',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Messages Badge (24)
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

                          // Profile Avatar with Green Dot
                          Stack(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 15,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDark,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.cardBg,
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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

  PopupMenuItem<Map<String, int>> _buildPresetItem(
    String label,
    int rows,
    int cols,
  ) {
    return PopupMenuItem(
      value: {'rows': rows, 'cols': cols},
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
      ),
    );
  }
}
