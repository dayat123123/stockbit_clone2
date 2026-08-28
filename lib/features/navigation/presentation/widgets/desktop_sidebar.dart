import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_event.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_state.dart';
import 'package:stockbit_clone2/features/trade/presentation/widgets/quick_trade_modal.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderbookBloc, OrderbookState>(
      builder: (context, state) {
        bool isFreeFloating = false;
        if (state is OrderbookLoadedState) {
          isFreeFloating = state.isFreeFloating;
        }

        return Container(
          width: 52,
          decoration: const BoxDecoration(
            color: AppColors.sidebarBg,
            border: Border(
              right: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Column(
            children: [
              // 1. Stockbit Logo
              Container(
                height: 42,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.primaryGreen,
                  size: 22,
                ),
              ),
              const Divider(color: AppColors.border, height: 1),

              // 2. Main Orderbook Tools
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 6),

                      // Multi-orderbook Layout (Main Active)
                      _buildSidebarButton(
                        icon: Icons.dashboard_customize_outlined,
                        label: 'Layout',
                        isSelected: true,
                        tooltip: 'Multi-orderbook Workspace',
                        onTap: () {},
                      ),

                      // Auto Arrange Button (Rapih)
                      _buildSidebarButton(
                        icon: Icons.auto_awesome_mosaic_outlined,
                        label: 'Rapih',
                        isSelected: !isFreeFloating,
                        tooltip: 'Auto Arrange Windows (Rapih)',
                        onTap: () {
                          final mediaSize = MediaQuery.of(context).size;
                          context.read<OrderbookBloc>().add(
                                AutoArrangeWindowsEvent(
                                  Size(mediaSize.width - 54, mediaSize.height - 66),
                                ),
                              );
                        },
                      ),

                      // Dinamis (Free Drag) Toggle
                      _buildSidebarButton(
                        icon: Icons.pan_tool_alt_outlined,
                        label: 'Dinamis',
                        isSelected: isFreeFloating,
                        tooltip: 'Free Floating Canvas Mode (Dinamis)',
                        onTap: () {
                          context.read<OrderbookBloc>().add(const ToggleLayoutModeEvent());
                        },
                      ),

                      const SizedBox(height: 4),
                      const Divider(color: AppColors.border, height: 1, indent: 8, endIndent: 8),
                      const SizedBox(height: 4),

                      // + Add Window
                      _buildSidebarButton(
                        icon: Icons.add_to_photos_outlined,
                        label: 'Add Win',
                        isSelected: false,
                        tooltip: 'Add New Orderbook Window',
                        onTap: () {
                          final mediaSize = MediaQuery.of(context).size;
                          context.read<OrderbookBloc>().add(
                                AddNewWindowToWorkspaceEvent(
                                  symbol: 'BBCA',
                                  canvasSize: Size(mediaSize.width - 54, mediaSize.height - 66),
                                ),
                              );
                        },
                      ),

                      // Preset 2x4 (8 Slots)
                      _buildSidebarButton(
                        icon: Icons.view_compact_outlined,
                        label: '2x4 Grid',
                        isSelected: false,
                        tooltip: 'Arrange 2x4 (8 Slots)',
                        onTap: () {
                          final mediaSize = MediaQuery.of(context).size;
                          context.read<OrderbookBloc>().add(
                                SetGridPresetEvent(
                                  rows: 2,
                                  columns: 4,
                                  canvasSize: Size(mediaSize.width - 54, mediaSize.height - 66),
                                ),
                              );
                        },
                      ),

                      // Preset 2x2 (4 Slots)
                      _buildSidebarButton(
                        icon: Icons.grid_view,
                        label: '2x2 Grid',
                        isSelected: false,
                        tooltip: 'Arrange 2x2 (4 Slots)',
                        onTap: () {
                          final mediaSize = MediaQuery.of(context).size;
                          context.read<OrderbookBloc>().add(
                                SetGridPresetEvent(
                                  rows: 2,
                                  columns: 2,
                                  canvasSize: Size(mediaSize.width - 54, mediaSize.height - 66),
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Bottom Fast Actions (Fast Trade & Info)
              const Divider(color: AppColors.border, height: 1),

              _buildSidebarButton(
                icon: Icons.shopping_cart_outlined,
                label: 'Order',
                isSelected: false,
                tooltip: 'Place Quick Order',
                onTap: () {
                  QuickTradeModal.show(context, isBuy: true);
                },
              ),

              _buildSidebarButton(
                icon: Icons.tune_outlined,
                label: 'Tools',
                isSelected: false,
                tooltip: 'Workspace Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.cardSurface,
                      content: Text('Multi-Orderbook Pro Canvas • Ready for Trading'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 46,
            width: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                  width: 3,
                ),
              ),
              color: isSelected ? AppColors.cardSurface : Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
