import 'dart:math';
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

/// Ultra-high performance modular window container.
///
/// Performance Optimizations:
/// - Maintains local drag & resize delta locally to prevent triggering full BLoC / canvas rebuilds during motion.
/// - Commits the final snapped position & size to WorkspaceBloc only on [onPanEnd].
/// - Wrapped with [RepaintBoundary] so window operations run at a silky-smooth 60/120 FPS without jank.
class WorkspaceWindowShell extends StatefulWidget {
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

  @override
  State<WorkspaceWindowShell> createState() => _WorkspaceWindowShellState();
}

class _WorkspaceWindowShellState extends State<WorkspaceWindowShell> {
  static const double _minWidth = 280.0;
  static const double _minHeight = 340.0;
  static const double _maxWidth = 1600.0;
  static const double _maxHeight = 1600.0;
  static const double _handleThickness = 6.0;

  late Offset _currentPosition;
  late Size _currentSize;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.window.position;
    _currentSize = widget.window.size;
  }

  @override
  void didUpdateWidget(covariant WorkspaceWindowShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isInteracting) {
      if (oldWidget.window.position != widget.window.position) {
        _currentPosition = widget.window.position;
      }
      if (oldWidget.window.size != widget.window.size) {
        _currentSize = widget.window.size;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.window.type;

    return AnimatedPositioned(
      duration: _isInteracting
          ? Duration.zero
          : const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      left: _currentPosition.dx,
      top: _currentPosition.dy,
      width: _currentSize.width,
      height: _currentSize.height,
      child: RepaintBoundary(
        child: GestureDetector(
          onTapDown: (_) {
            if (!widget.isActive) {
              context.read<WorkspaceBloc>().add(
                SetActiveWindowEvent(widget.window.id),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(5),
              // Clean subtle non-glow border
              border: Border.all(
                color: widget.isActive
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
                    // Header Bar (28px - Clean Non-Glow)
                    GestureDetector(
                      onPanStart: (details) {
                        _isInteracting = true;
                        if (!widget.isActive) {
                          context.read<WorkspaceBloc>().add(
                            SetActiveWindowEvent(widget.window.id),
                          );
                        }
                        widget.onDragGlobalPosition?.call(
                          details.globalPosition,
                        );
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          _currentPosition = Offset(
                            max(0.0, _currentPosition.dx + details.delta.dx),
                            max(0.0, _currentPosition.dy + details.delta.dy),
                          );
                        });
                        widget.onDragGlobalPosition?.call(
                          details.globalPosition,
                        );
                      },
                      onPanEnd: (_) {
                        _isInteracting = false;
                        // Commit position and trigger magnetic snap in BLoC
                        context.read<WorkspaceBloc>().add(
                          MoveWindowEvent(
                            windowId: widget.window.id,
                            delta: _currentPosition - widget.window.position,
                            canvasSize: widget.canvasSize,
                          ),
                        );
                        context.read<WorkspaceBloc>().add(
                          SnapWindowOnReleaseEvent(
                            windowId: widget.window.id,
                            canvasSize: widget.canvasSize,
                          ),
                        );
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.move,
                        child: Container(
                          height: 28,
                          padding: const EdgeInsets.only(left: 6, right: 2),
                          decoration: BoxDecoration(
                            color: widget.isActive
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left: Indicator, Badge & Symbol
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
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
                                          color: type.color.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          border: Border.all(
                                            color: type.color.withValues(
                                              alpha: 0.3,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                            border: Border.all(
                                              color: AppColors.border,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                widget.window.symbol,
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

                                      Tooltip(
                                        message: 'Change or Reset Stock Symbol',
                                        child: InkWell(
                                          onTap: () =>
                                              _openSymbolPicker(context),
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
                                    ],
                                  ],
                                ),
                              ),

                              // Right: BUY & Close Button (Pinned at the Far Right)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Quick BUY Button
                                  if (type == WorkspaceWidgetType.orderbook ||
                                      type == WorkspaceWidgetType.chart ||
                                      type ==
                                          WorkspaceWidgetType
                                              .brokerSummary) ...[
                                    InkWell(
                                      onTap: () {
                                        QuickTradeModal.show(
                                          context,
                                          symbol: widget.window.symbol,
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
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
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
                                    const SizedBox(width: 6),
                                  ],

                                  // Close / Delete Window Button (Firmly pinned at the far top-right end)
                                  Tooltip(
                                    message: 'Close window slot',
                                    child: InkWell(
                                      onTap: () {
                                        context.read<WorkspaceBloc>().add(
                                          RemoveWindowEvent(widget.window.id),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(3),
                                      child: const Padding(
                                        padding: EdgeInsets.all(3),
                                        child: Icon(
                                          Icons.close,
                                          size: 13.5,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Feature Screen Content Body (RepaintBoundary protected)
                    Expanded(
                      child: ClipRect(
                        child: RepaintBoundary(
                          child: WorkspaceWidgetFactory.build(
                            type: widget.window.type,
                            symbol: widget.window.symbol,
                            windowId: widget.window.id,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── 2. Interactive 8-Directional Resizing Handles ────────────
                // Top Edge
                Positioned(
                  top: 0,
                  left: _handleThickness,
                  right: _handleThickness,
                  height: _handleThickness,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUpDown,
                    child: GestureDetector(
                      onPanStart: (_) => _isInteracting = true,
                      onPanUpdate: (d) => _handleResizeTop(d.delta.dy),
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
                      onPanStart: (_) => _isInteracting = true,
                      onPanUpdate: (d) => _handleResizeBottom(d.delta.dy),
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
                      onPanStart: (_) => _isInteracting = true,
                      onPanUpdate: (d) => _handleResizeLeft(d.delta.dx),
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
                      onPanStart: (_) => _isInteracting = true,
                      onPanUpdate: (d) => _handleResizeRight(d.delta.dx),
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
                      onPanStart: (_) => _isInteracting = true,
                      onPanUpdate: (d) {
                        _handleResizeTop(d.delta.dy);
                        _handleResizeLeft(d.delta.dx);
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
                      onPanStart: (_) => _isInteracting = true,
                      onPanUpdate: (d) {
                        _handleResizeTop(d.delta.dy);
                        _handleResizeRight(d.delta.dx);
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
                      onPanStart: (_) => _isInteracting = true,
                      onPanUpdate: (d) {
                        _handleResizeBottom(d.delta.dy);
                        _handleResizeLeft(d.delta.dx);
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
                      onPanStart: (_) => _isInteracting = true,
                      onPanUpdate: (d) {
                        _handleResizeBottom(d.delta.dy);
                        _handleResizeRight(d.delta.dx);
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

  // ── Local Smooth Resize Handlers ──────────────────────────────────────────

  void _handleResizeRight(double dx) {
    setState(() {
      final newW = (_currentSize.width + dx).clamp(_minWidth, _maxWidth);
      _currentSize = Size(newW, _currentSize.height);
    });
  }

  void _handleResizeBottom(double dy) {
    setState(() {
      final newH = (_currentSize.height + dy).clamp(_minHeight, _maxHeight);
      _currentSize = Size(_currentSize.width, newH);
    });
  }

  void _handleResizeLeft(double dx) {
    final potentialW = _currentSize.width - dx;
    if (potentialW >= _minWidth && potentialW <= _maxWidth) {
      setState(() {
        _currentPosition = Offset(
          _currentPosition.dx + dx,
          _currentPosition.dy,
        );
        _currentSize = Size(potentialW, _currentSize.height);
      });
    }
  }

  void _handleResizeTop(double dy) {
    final potentialH = _currentSize.height - dy;
    if (potentialH >= _minHeight && potentialH <= _maxHeight) {
      setState(() {
        _currentPosition = Offset(
          _currentPosition.dx,
          _currentPosition.dy + dy,
        );
        _currentSize = Size(_currentSize.width, potentialH);
      });
    }
  }

  void _handleResizeEnd(BuildContext context) {
    _isInteracting = false;
    // Commit final size and position to BLoC once on release with Magnetic Snap
    context.read<WorkspaceBloc>().add(
      ResizeWindowEvent(
        windowId: widget.window.id,
        newSize: _currentSize,
        newPosition: _currentPosition,
      ),
    );
    context.read<WorkspaceBloc>().add(
      SnapResizeOnReleaseEvent(
        windowId: widget.window.id,
        canvasSize: widget.canvasSize,
      ),
    );
  }

  void _openSymbolPicker(BuildContext context) {
    StockSearchDialog.show(
      context,
      targetSlotIndex: 0,
      onSymbolSelected: (sym) {
        context.read<WorkspaceBloc>().add(
          ChangeWindowSymbolEvent(windowId: widget.window.id, newSymbol: sym),
        );
      },
    );
  }
}
