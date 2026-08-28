import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_state.dart';
import 'package:stockbit_clone2/core/workspace/models/window_widget_type.dart';
import 'package:stockbit_clone2/core/workspace/widgets/add_widget_dialog.dart';
import 'package:stockbit_clone2/features/trade/presentation/widgets/quick_trade_modal.dart';

class WorkspaceTopToolbar extends StatelessWidget {
  const WorkspaceTopToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        int activeTabIndex = 0;
        bool isFreeFloating = false;
        int gridRows = 2;
        int gridCols = 4;
        String? activeSymbol;

        if (state is WorkspaceLoadedState) {
          activeTabIndex = state.activeTabIndex;
          isFreeFloating = state.isFreeFloating;
          gridRows = state.gridRows;
          gridCols = state.gridColumns;
          activeSymbol = state.activeWindow?.symbol;
        }

        final tabs = state is WorkspaceLoadedState ? state.tabs : [];

        return Container(
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.headerBg,
            border:
                Border(bottom: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Row(
            children: [
              // 1. Workspace Tabs Bar
              ...tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isActiveTab = index == activeTabIndex;

                return InkWell(
                  onTap: () {
                    context
                        .read<WorkspaceBloc>()
                        .add(SelectTabEvent(index));
                  },
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isActiveTab
                          ? AppColors.activeTabBg
                          : AppColors.inactiveTabBg,
                      border: Border(
                        right: const BorderSide(
                            color: AppColors.border, width: 1),
                        top: BorderSide(
                          color: isActiveTab
                              ? AppColors.tabIndicator
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.grid_view,
                          size: 13,
                          color: isActiveTab
                              ? AppColors.primaryGreen
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tab.title,
                          style: TextStyle(
                            fontSize: 12,
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
                              context
                                  .read<WorkspaceBloc>()
                                  .add(CloseTabEvent(index));
                            },
                            child: const Icon(Icons.close,
                                size: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              // Add Workspace Tab Button (+)
              IconButton(
                icon: const Icon(Icons.add,
                    size: 16, color: AppColors.textSecondary),
                tooltip: 'Add New Workspace Tab',
                onPressed: () {
                  context.read<WorkspaceBloc>().add(
                        AddTabEvent(
                          title: 'Workspace',
                          initialWindows: [
                            for (int i = 0; i < 4; i++)
                              (
                                WindowWidgetType.orderbook,
                                <String, dynamic>{
                                  'symbol': ['BBRI', 'BBCA', 'TLKM', 'ASII'][i]
                                }
                              ),
                          ],
                        ),
                      );
                },
              ),

              const SizedBox(width: 8),
              const VerticalDivider(
                  color: AppColors.border, width: 1, indent: 8, endIndent: 8),
              const SizedBox(width: 8),

              // 2. Global Stock Search to Active Window
              Container(
                width: 200,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textPrimary),
                  onSubmitted: (value) {
                    final sym = value.trim().toUpperCase();
                    if (sym.isNotEmpty && state is WorkspaceLoadedState) {
                      final activeWin = state.activeWindow;
                      if (activeWin != null) {
                        context.read<WorkspaceBloc>().add(
                              UpdateWindowMetadataEvent(
                                windowId: activeWin.id,
                                metadata: {'symbol': sym},
                              ),
                            );
                      }
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search symbol to active window...',
                    hintStyle:
                        TextStyle(fontSize: 11, color: AppColors.textMuted),
                    prefixIcon:
                        Icon(Icons.search, size: 14, color: AppColors.textMuted),
                    prefixIconConstraints:
                        BoxConstraints(minWidth: 26, minHeight: 26),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Active Window Indicator
              if (activeSymbol != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                        color:
                            AppColors.primaryGreen.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 11, color: AppColors.primaryGreen),
                      const SizedBox(width: 4),
                      Text(
                        'Active: $activeSymbol',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // 3. Auto Arrange
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardSurface,
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.borderLight),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  minimumSize: const Size(100, 28),
                  elevation: 0,
                ),
                onPressed: () {
                  final mediaSize = MediaQuery.of(context).size;
                  final availableWidth = mediaSize.width - 54;
                  final availableHeight = mediaSize.height - 42 - 24;
                  context.read<WorkspaceBloc>().add(
                        AutoArrangeWindowsEvent(
                            Size(availableWidth, availableHeight)),
                      );
                },
                icon: const Icon(Icons.auto_awesome_mosaic_outlined,
                    size: 13, color: AppColors.primaryGreen),
                label: const Text('Auto Arrange (Rapih)',
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(width: 8),

              // 4. Layout Mode Toggle
              Tooltip(
                message: isFreeFloating
                    ? 'Mode Dinamis (Bebas Geser Aktif)'
                    : 'Mode Grid (Tersusun Rapih)',
                child: InkWell(
                  onTap: () {
                    context
                        .read<WorkspaceBloc>()
                        .add(const ToggleLayoutModeEvent());
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isFreeFloating
                          ? AppColors.badgePurple.withValues(alpha: 0.2)
                          : AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isFreeFloating
                            ? AppColors.badgePurple
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isFreeFloating
                              ? Icons.pan_tool_alt_outlined
                              : Icons.grid_on,
                          size: 13,
                          color: isFreeFloating
                              ? AppColors.badgePurple
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isFreeFloating ? 'Dinamis (Free)' : 'Rapih (Grid)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isFreeFloating
                                ? AppColors.badgePurple
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 5. Grid Preset Selector
              PopupMenuButton<Map<String, int>>(
                tooltip: 'Select Grid Presets',
                color: AppColors.cardBg,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.view_quilt_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        '$gridRows × $gridCols Grid',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                      const Icon(Icons.arrow_drop_down,
                          size: 13, color: AppColors.textMuted),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  _buildPresetItem('2 × 4 (8 Slots - Default)', 2, 4),
                  _buildPresetItem('2 × 3 (6 Slots)', 2, 3),
                  _buildPresetItem('2 × 2 (4 Slots)', 2, 2),
                  _buildPresetItem('1 × 2 (2 Slots)', 1, 2),
                  _buildPresetItem('3 × 3 (9 Slots)', 3, 3),
                  _buildPresetItem('1 × 1 (Single Max Focus)', 1, 1),
                ],
                onSelected: (val) {
                  final mediaSize = MediaQuery.of(context).size;
                  final availableWidth = mediaSize.width - 54;
                  final availableHeight = mediaSize.height - 42 - 24;
                  context.read<WorkspaceBloc>().add(
                        SetGridPresetEvent(
                          rows: val['rows']!,
                          columns: val['cols']!,
                          canvasSize:
                              Size(availableWidth, availableHeight),
                        ),
                      );
                },
              ),

              const SizedBox(width: 8),

              // 6. + Add Widget Button (opens dialog)
              IconButton(
                icon: const Icon(Icons.add_to_photos_outlined,
                    size: 16, color: AppColors.primaryGreen),
                tooltip: 'Add New Widget Window',
                onPressed: () async {
                  final type = await AddWidgetDialog.show(context);
                  if (type != null && context.mounted) {
                    final mediaSize = MediaQuery.of(context).size;
                    context.read<WorkspaceBloc>().add(
                          AddWindowEvent(
                            widgetType: type,
                            metadata: type == WindowWidgetType.orderbook
                                ? {'symbol': 'BBCA'}
                                : {},
                            canvasSize: Size(
                                mediaSize.width - 54, mediaSize.height - 66),
                          ),
                        );
                  }
                },
              ),

              const SizedBox(width: 6),

              // 7. BUY Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(64, 28),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  elevation: 0,
                ),
                onPressed: () {
                  QuickTradeModal.show(
                    context,
                    symbol: activeSymbol ?? 'BBRI',
                    isBuy: true,
                  );
                },
                icon: const Icon(Icons.shopping_cart_outlined, size: 13),
                label: const Text('BUY',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }

  PopupMenuItem<Map<String, int>> _buildPresetItem(
      String label, int rows, int cols) {
    return PopupMenuItem(
      value: {'rows': rows, 'cols': cols},
      child: Text(label,
          style: const TextStyle(
              fontSize: 11, color: AppColors.textPrimary)),
    );
  }
}
