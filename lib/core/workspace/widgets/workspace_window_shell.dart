import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_widget_type.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_window_model.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/workspace/factory/workspace_widget_factory.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/widgets/stock_search_dialog.dart';
import 'package:stockbit_clone2/features/trade/presentation/widgets/quick_trade_modal.dart';

/// Professional modular window container supporting 8-directional multi-edge resizing,
/// automatic magnetic snapping on resize release, subtle non-glowing active state,
/// and responsive overflow-safe header.
class WorkspaceWindowShell extends StatelessWidget {
  final WorkspaceWindowModel window;
  final bool isActive;
  final Size canvasSize;
  final void Function(Offset globalPosition)? onDragGlobalPosition;

  const WorkspaceWindowShell({
    super.key,
    required this.window,
    required this.isActive,
    required this.canvasSize,
    this.onDragGlobalPosition,
  });

  static const double _minWidth = 180.0;
  static const double _minHeight = 140.0;
  static const double _maxWidth = 1600.0;
  static const double _maxHeight = 1600.0;
  static const double _handleThickness = 6.0;

  @override
  Widget build(BuildContext context) {
    final type = window.type;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      left: window.position.dx,
      top: window.position.dy,
      width: window.size.width,
      height: window.size.height,
      child: RepaintBoundary(
        child: GestureDetector(
          onTapDown: (_) {
            context.read<WorkspaceBloc>().add(SetActiveWindowEvent(window.id));
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(5),
              // Clean subtle non-glow border
              border: Border.all(
                color: isActive
                    ? AppColors.primaryDark.withValues(alpha: 0.55)
                    : AppColors.border,
                width: 1.0,
              ),
              boxShadow: AppColors.windowShadow,
            ),
            child: Stack(
              children: [
                // ── 1. Main Window Body & Clean Header ───────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Bar (28px - Clean Non-Glow with Responsive Layout)
                    GestureDetector(
                      onPanStart: (details) {
                        context.read<WorkspaceBloc>().add(
                          SetActiveWindowEvent(window.id),
                        );
                        onDragGlobalPosition?.call(details.globalPosition);
                      },
                      onPanUpdate: (details) {
                        context.read<WorkspaceBloc>().add(
                          MoveWindowEvent(
                            windowId: window.id,
                            delta: details.delta,
                            canvasSize: canvasSize,
                          ),
                        );
                        onDragGlobalPosition?.call(details.globalPosition);
                      },
                      onPanEnd: (_) {
                        context.read<WorkspaceBloc>().add(
                          SnapWindowOnReleaseEvent(
                            windowId: window.id,
                            canvasSize: canvasSize,
                          ),
                        );
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.move,
                        child: Container(
                          height: 28,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.cardSurface
                                : AppColors.cardHeader,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            border: const Border(
                              bottom: BorderSide(
                                color: AppColors.border,
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Drag Handle Icon
                              const Icon(
                                Icons.drag_indicator,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 3),

                              // Widget Type Badge
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: type.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: type.color.withValues(alpha: 0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        type.icon,
                                        size: 9,
                                        color: type.color,
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          type.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold,
                                            color: type.color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),

                              // Active Stock Symbol Badge & Edit/Reset Action
                              if (type.requiresSymbol) ...[
                                InkWell(
                                  onTap: () => _openSymbolPicker(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBg,
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                        color: AppColors.border,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          window.symbol,
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          size: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),

                                // Reset/Change Stock Symbol Button
                                Tooltip(
                                  message: 'Change or Reset Stock Symbol',
                                  child: InkWell(
                                    onTap: () => _openSymbolPicker(context),
                                    child: const Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 10.5,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 3),
                              ],

                              const Spacer(),

                              // Quick BUY Button
                              if (type == WorkspaceWidgetType.orderbook ||
                                  type == WorkspaceWidgetType.chart ||
                                  type ==
                                      WorkspaceWidgetType.brokerSummary) ...[
                                InkWell(
                                  onTap: () {
                                    QuickTradeModal.show(
                                      context,
                                      symbol: window.symbol,
                                      isBuy: true,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryDark,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Text(
                                      'BUY',
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],

                              // Close / Delete Window Button (Firmly anchored at the far right end)
                              Tooltip(
                                message: 'Close window slot',
                                child: InkWell(
                                  onTap: () {
                                    context.read<WorkspaceBloc>().add(
                                      RemoveWindowEvent(window.id),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(3),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2,
                                      vertical: 2,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 12.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Feature Screen Content Body (Overflow protected)
                    Expanded(
                      child: ClipRect(
                        child: RepaintBoundary(
                          child: WorkspaceWidgetFactory.build(
                            type: window.type,
                            symbol: window.symbol,
                            windowId: window.id,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── 2. Interactive 8-Directional Resizing Handles with Snap ─
                // Top Edge
                Positioned(
                  top: 0,
                  left: _handleThickness,
                  right: _handleThickness,
                  height: _handleThickness,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUpDown,
                    child: GestureDetector(
                      onPanUpdate: (d) => _handleResizeTop(context, d.delta.dy),
                      onPanEnd: (_) => _handleResizeEnd(context),
                    ),
                  ),
                ),

                // Bottom Edge
                Positioned(
                  bottom: 0,
                  left: _handleThickness,
                  right: _handleThickness,
                  height: _handleThickness,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUpDown,
                    child: GestureDetector(
                      onPanUpdate: (d) =>
                          _handleResizeBottom(context, d.delta.dy),
                      onPanEnd: (_) => _handleResizeEnd(context),
                    ),
                  ),
                ),

                // Left Edge
                Positioned(
                  left: 0,
                  top: _handleThickness,
                  bottom: _handleThickness,
                  width: _handleThickness,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      onPanUpdate: (d) =>
                          _handleResizeLeft(context, d.delta.dx),
                      onPanEnd: (_) => _handleResizeEnd(context),
                    ),
                  ),
                ),

                // Right Edge
                Positioned(
                  right: 0,
                  top: _handleThickness,
                  bottom: _handleThickness,
                  width: _handleThickness,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      onPanUpdate: (d) =>
                          _handleResizeRight(context, d.delta.dx),
                      onPanEnd: (_) => _handleResizeEnd(context),
                    ),
                  ),
                ),

                // Top-Left Corner
                Positioned(
                  top: 0,
                  left: 0,
                  width: _handleThickness * 2,
                  height: _handleThickness * 2,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUpLeftDownRight,
                    child: GestureDetector(
                      onPanUpdate: (d) {
                        _handleResizeTop(context, d.delta.dy);
                        _handleResizeLeft(context, d.delta.dx);
                      },
                      onPanEnd: (_) => _handleResizeEnd(context),
                    ),
                  ),
                ),

                // Top-Right Corner
                Positioned(
                  top: 0,
                  right: 0,
                  width: _handleThickness * 2,
                  height: _handleThickness * 2,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUpRightDownLeft,
                    child: GestureDetector(
                      onPanUpdate: (d) {
                        _handleResizeTop(context, d.delta.dy);
                        _handleResizeRight(context, d.delta.dx);
                      },
                      onPanEnd: (_) => _handleResizeEnd(context),
                    ),
                  ),
                ),

                // Bottom-Left Corner
                Positioned(
                  bottom: 0,
                  left: 0,
                  width: _handleThickness * 2,
                  height: _handleThickness * 2,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUpRightDownLeft,
                    child: GestureDetector(
                      onPanUpdate: (d) {
                        _handleResizeBottom(context, d.delta.dy);
                        _handleResizeLeft(context, d.delta.dx);
                      },
                      onPanEnd: (_) => _handleResizeEnd(context),
                    ),
                  ),
                ),

                // Bottom-Right Corner
                Positioned(
                  bottom: 0,
                  right: 0,
                  width: _handleThickness * 2,
                  height: _handleThickness * 2,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUpLeftDownRight,
                    child: GestureDetector(
                      onPanUpdate: (d) {
                        _handleResizeBottom(context, d.delta.dy);
                        _handleResizeRight(context, d.delta.dx);
                      },
                      onPanEnd: (_) => _handleResizeEnd(context),
                      child: Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.all(1),
                        child: const Icon(
                          Icons.south_east,
                          size: 8,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Resize Handlers with Magnetic Snap ─────────────────────────────────────

  void _handleResizeRight(BuildContext context, double dx) {
    final newW = (window.size.width + dx).clamp(_minWidth, _maxWidth);
    context.read<WorkspaceBloc>().add(
      ResizeWindowEvent(
        windowId: window.id,
        newSize: Size(newW, window.size.height),
      ),
    );
  }

  void _handleResizeBottom(BuildContext context, double dy) {
    final newH = (window.size.height + dy).clamp(_minHeight, _maxHeight);
    context.read<WorkspaceBloc>().add(
      ResizeWindowEvent(
        windowId: window.id,
        newSize: Size(window.size.width, newH),
      ),
    );
  }

  void _handleResizeLeft(BuildContext context, double dx) {
    final potentialW = window.size.width - dx;
    if (potentialW >= _minWidth && potentialW <= _maxWidth) {
      final newX = window.position.dx + dx;
      context.read<WorkspaceBloc>().add(
        ResizeWindowEvent(
          windowId: window.id,
          newSize: Size(potentialW, window.size.height),
          newPosition: Offset(newX, window.position.dy),
        ),
      );
    }
  }

  void _handleResizeTop(BuildContext context, double dy) {
    final potentialH = window.size.height - dy;
    if (potentialH >= _minHeight && potentialH <= _maxHeight) {
      final newY = window.position.dy + dy;
      context.read<WorkspaceBloc>().add(
        ResizeWindowEvent(
          windowId: window.id,
          newSize: Size(window.size.width, potentialH),
          newPosition: Offset(window.position.dx, newY),
        ),
      );
    }
  }

  void _handleResizeEnd(BuildContext context) {
    context.read<WorkspaceBloc>().add(
      SnapResizeOnReleaseEvent(windowId: window.id, canvasSize: canvasSize),
    );
  }

  void _openSymbolPicker(BuildContext context) {
    StockSearchDialog.show(
      context,
      targetSlotIndex: 0,
      onSymbolSelected: (sym) {
        context.read<WorkspaceBloc>().add(
          ChangeWindowSymbolEvent(windowId: window.id, newSymbol: sym),
        );
      },
    );
  }
}
