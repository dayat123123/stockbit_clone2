import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_state.dart';
import 'package:stockbit_clone2/core/workspace/widgets/add_widget_dialog.dart';
import 'package:stockbit_clone2/core/widgets/dialogs/layout_template_gallery_dialog.dart';
import 'package:stockbit_clone2/core/widgets/navigation/desktop_header_actions.dart';

/// Top Workspace Toolbar Header (matching Stockbit Pro Desktop reference design).
///
/// Features:
/// - Tabs on the left with clean bottom underline.
/// - Search Symbol input.
/// - Modular DesktopHeaderActions (BUY, Open Trading Account, Badges, Profile Avatar).
/// - Grid Presets, Add Window, & Arrange buttons.
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

                      // ── 2. Right Side: Unified DesktopHeaderActions ──────────
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: DesktopHeaderActions(
                          activeSymbol: 'BBCA',
                          leadingActions: [
                            // 1. Grid Preset Selector
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
                                _buildPresetItem(
                                  '3 × 3 (9 Slots - Grid)',
                                  3,
                                  3,
                                ),
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
                                _buildPresetItem(
                                  '1 × 3 (3 Columns Focus)',
                                  1,
                                  3,
                                ),
                                _buildPresetItem(
                                  '1 × 2 (2 Split Screen)',
                                  1,
                                  2,
                                ),
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

                            // 2. Add Window Button
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

                            // 3. Arrange Windows Button
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
                          ],
                        ),
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
