import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_window_model.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_state.dart';
import 'package:stockbit_clone2/core/workspace/widgets/add_widget_dialog.dart';
import 'package:stockbit_clone2/core/workspace/widgets/workspace_window_shell.dart';
import 'package:stockbit_clone2/core/widgets/dialogs/layout_template_gallery_dialog.dart';

/// Pure UI View for the 2D Multi-Directional Workspace Canvas (Horizontal & Vertical Scroll)
/// with Interactive Edge Auto-Scrolling during window drag.
///
/// Follows Separation of Concerns (SoC) & Extreme Performance Optimization:
/// - Both Horizontal and Vertical scrollbars are supported.
/// - When a window is dragged near the screen edge (top, bottom, left, right), the canvas auto-scrolls.
/// - Wrapped with [RepaintBoundary] so scrolling and market streaming never cause cascading repaints.
class WorkspaceCanvasView extends StatefulWidget {
  const WorkspaceCanvasView({super.key});

  @override
  State<WorkspaceCanvasView> createState() => _WorkspaceCanvasViewState();
}

class _WorkspaceCanvasViewState extends State<WorkspaceCanvasView> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  /// Automatically scrolls the canvas if the pointer is dragged near the viewport boundaries.
  void _handleDragEdgeAutoScroll(Offset globalPosition) {
    final renderBox =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final localPos = renderBox.globalToLocal(globalPosition);
    final size = renderBox.size;

    const edgeMargin = 70.0;
    const scrollStep = 18.0;

    // ── Vertical Edge Auto-Scroll ────────────────────────────────────────────
    if (localPos.dy > size.height - edgeMargin) {
      if (_verticalController.hasClients) {
        final target = min(
          _verticalController.offset + scrollStep,
          _verticalController.position.maxScrollExtent,
        );
        _verticalController.jumpTo(target);
      }
    } else if (localPos.dy < edgeMargin) {
      if (_verticalController.hasClients) {
        final target = max(
          _verticalController.offset - scrollStep,
          _verticalController.position.minScrollExtent,
        );
        _verticalController.jumpTo(target);
      }
    }

    // ── Horizontal Edge Auto-Scroll ──────────────────────────────────────────
    if (localPos.dx > size.width - edgeMargin) {
      if (_horizontalController.hasClients) {
        final target = min(
          _horizontalController.offset + scrollStep,
          _horizontalController.position.maxScrollExtent,
        );
        _horizontalController.jumpTo(target);
      }
    } else if (localPos.dx < edgeMargin) {
      if (_horizontalController.hasClients) {
        final target = max(
          _horizontalController.offset - scrollStep,
          _horizontalController.position.minScrollExtent,
        );
        _horizontalController.jumpTo(target);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        if (state is WorkspaceLoadingState) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryDark,
              strokeWidth: 2,
            ),
          );
        }

        if (state is WorkspaceErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 36,
                  color: AppColors.offerRed,
                ),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => context.read<WorkspaceBloc>().add(
                    const InitializeWorkspaceEvent(),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is WorkspaceLoadedState) {
          final activeTab = state.activeTab;
          final sortedWindows = List<WorkspaceWindowModel>.from(
            activeTab.windows,
          )..sort((a, b) => a.zIndex.compareTo(b.zIndex));

          return LayoutBuilder(
            key: _viewportKey,
            builder: (context, constraints) {
              final viewportWidth = constraints.maxWidth;
              final viewportHeight = constraints.maxHeight;

              // Calculate dynamic total 2D canvas bounds
              final maxRight = sortedWindows.fold<double>(
                viewportWidth,
                (prev, w) => max(prev, w.position.dx + w.size.width + 120),
              );

              final maxBottom = sortedWindows.fold<double>(
                viewportHeight,
                (prev, w) => max(prev, w.position.dy + w.size.height + 120),
              );

              final totalCanvasWidth = max(viewportWidth, maxRight);
              final totalCanvasHeight = max(viewportHeight, maxBottom);
              final canvasSize = Size(totalCanvasWidth, totalCanvasHeight);

              // ── Main 2D Canvas Content ─────────────────────────────────────
              final canvasContent = Container(
                color: AppColors.canvasBg,
                width: totalCanvasWidth,
                height: totalCanvasHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Blueprint Grid Lines Background (Isolated Repaint)
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(painter: _GridBlueprintPainter()),
                      ),
                    ),

                    // Modular Terminal Windows (Isolated Repaint & Magnetic Snap & Auto-Scroll)
                    ...sortedWindows.map((win) {
                      final isActive = win.id == activeTab.activeWindowId;
                      return WorkspaceWindowShell(
                        key: ValueKey(win.id),
                        window: win,
                        isActive: isActive,
                        canvasSize: canvasSize,
                        onDragGlobalPosition: _handleDragEdgeAutoScroll,
                      );
                    }),

                    // Empty Workspace State
                    if (sortedWindows.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.dashboard_customize_outlined,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No Windows in this Workspace',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    LayoutTemplateGalleryDialog.show(
                                      context,
                                      canvasSize,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.dashboard_customize_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Choose Layout Template'),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                    foregroundColor: AppColors.textPrimary,
                                  ),
                                  onPressed: () {
                                    AddWidgetDialog.show(context, canvasSize);
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add Single Widget'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );

              // ── Dual Axis 2D Scroll View (Horizontal & Vertical) ───────────
              return Scrollbar(
                controller: _verticalController,
                thumbVisibility: true,
                thickness: 6,
                radius: const Radius.circular(3),
                child: Scrollbar(
                  controller: _horizontalController,
                  thumbVisibility: true,
                  thickness: 6,
                  radius: const Radius.circular(3),
                  notificationPredicate: (notif) => notif.depth == 1,
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    scrollDirection: Axis.vertical,
                    physics: const ClampingScrollPhysics(),
                    child: SingleChildScrollView(
                      controller: _horizontalController,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: canvasContent,
                    ),
                  ),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _GridBlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
