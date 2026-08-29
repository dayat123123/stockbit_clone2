import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/navigation/cubit/navigation_cubit.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_widget_type.dart';

/// Interactive Testing Window Dialog triggered globally via [F2] / [F3] hotkeys.
/// Enables quick slot testing, simulated order execution, and terminal diagnostics.
class TestingWindowDialog extends StatefulWidget {
  const TestingWindowDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => const TestingWindowDialog(),
    );
  }

  @override
  State<TestingWindowDialog> createState() => _TestingWindowDialogState();
}

class _TestingWindowDialogState extends State<TestingWindowDialog> {
  String _selectedSymbol = 'BBCA';
  WorkspaceWidgetType _selectedType = WorkspaceWidgetType.orderbook;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF13171F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2E343E), width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Hotkey badge and Close Button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF8B5CF6)),
                    ),
                    child: const Text(
                      'F2 / F3',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA78BFA),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Testing Window & Order Form',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              const Text(
                'Simulate instant execution, spawn terminal test slots, or test keyboard shortcuts across the workspace.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Stock Symbol Selector Chips
              const Text(
                'TARGET STOCK SYMBOL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['BBCA', 'BBRI', 'BMRI', 'TLKM', 'ASII', 'GOTO'].map((
                  sym,
                ) {
                  final isSelected = sym == _selectedSymbol;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedSymbol = sym),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryDark.withValues(alpha: 0.2)
                              : const Color(0xFF1B2028),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryDark
                                : const Color(0xFF2E343E),
                          ),
                        ),
                        child: Text(
                          sym,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primaryDark
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Widget Type Spawn Selector
              const Text(
                'WIDGET TYPE TO SPAWN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      WorkspaceWidgetType.orderbook,
                      WorkspaceWidgetType.chart,
                      WorkspaceWidgetType.watchlist,
                      WorkspaceWidgetType.brokerSummary,
                      WorkspaceWidgetType.market,
                      WorkspaceWidgetType.screener,
                    ].map((type) {
                      final isSelected = type == _selectedType;
                      return InkWell(
                        onTap: () => setState(() => _selectedType = type),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? type.color.withValues(alpha: 0.2)
                                : const Color(0xFF1B2028),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? type.color
                                  : const Color(0xFF2E343E),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(type.icon, size: 12, color: type.color),
                              const SizedBox(width: 6),
                              Text(
                                type.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? type.color
                                      : const Color(0xFFD1D5DB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),

              // Action Buttons Row
              Row(
                children: [
                  // 1. Spawn Window to Workspace
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E343E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        context.read<WorkspaceBloc>().add(
                          AddNewWindowToWorkspaceEvent(
                            type: _selectedType,
                            symbol: _selectedSymbol,
                            canvasSize: MediaQuery.of(context).size,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Spawn Slot',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 2. Open Simulated Trade Order Form (navigates dynamically to Orders screen)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C076),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.read<NavigationCubit>().navigateToOrder(
                          symbol: _selectedSymbol,
                          isBuy: true,
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                      label: const Text(
                        'Open Order Form',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Escape Hint Footer
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F29),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Press [Escape] on the layout canvas to close the active window.',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF9CA3AF),
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
  }
}
