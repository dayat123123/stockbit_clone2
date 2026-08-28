import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_state.dart';
import 'package:stockbit_clone2/core/workspace/controllers/canvas_drag_controller.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_window.dart';
import 'package:stockbit_clone2/core/workspace/widgets/add_widget_dialog.dart';
import 'package:stockbit_clone2/core/workspace/widgets/floating_window_shell.dart';
import 'package:stockbit_clone2/core/workspace/models/window_widget_type.dart';

/// Generic canvas that renders [WorkspaceWindow] list with drag, resize,
/// z-ordering. Content for each window is resolved via [windowContentBuilder]
/// and [windowHeaderBuilder].
class FloatingWorkspaceCanvas extends StatefulWidget {
  /// Builds the body content for a given window.
  final Widget Function(WorkspaceWindow window) windowContentBuilder;

  /// Builds the header title area for a given window (optional).
  final Widget Function(WorkspaceWindow window)? windowHeaderBuilder;

  const FloatingWorkspaceCanvas({
    super.key,
    required this.windowContentBuilder,
    this.windowHeaderBuilder,
  });

  @override
  State<FloatingWorkspaceCanvas> createState() =>
      _FloatingWorkspaceCanvasState();
}

class _FloatingWorkspaceCanvasState extends State<FloatingWorkspaceCanvas> {
  final CanvasDragController _dragController = CanvasDragController();

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkspaceBloc, WorkspaceState>(
      builder: (context, state) {
        if (state is WorkspaceInitialState) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen,
              strokeWidth: 2,
            ),
          );
        }

        if (state is! WorkspaceLoadedState) {
          return const SizedBox.shrink();
        }

        final activeTab = state.activeTab;
        final sortedWindows = List<WorkspaceWindow>.from(activeTab.windows)
          ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

        return LayoutBuilder(
          builder: (context, constraints) {
            final canvasSize =
                Size(constraints.maxWidth, constraints.maxHeight);

            return Listener(
              onPointerDown: (event) {
                final reversedWindows = sortedWindows.reversed.toList();
                for (final win in reversedWindows) {
                  final rect = Rect.fromLTWH(
                    win.position.dx,
                    win.position.dy,
                    win.size.width,
                    win.size.height,
                  );
                  final headerRect = Rect.fromLTWH(
                    win.position.dx,
                    win.position.dy,
                    win.size.width,
                    34,
                  );
                  if (headerRect.contains(event.localPosition)) {
                    _dragController.startDrag(
                        win.id, context.read<WorkspaceBloc>());
                    break;
                  } else if (rect.contains(event.localPosition)) {
                    context
                        .read<WorkspaceBloc>()
                        .add(SetActiveWindowEvent(win.id));
                    break;
                  }
                }
              },
              onPointerMove: (event) {
                _dragController.updateDrag(
                  event.delta,
                  canvasSize,
                  context.read<WorkspaceBloc>(),
                );
              },
              onPointerUp: (event) =>
                  _dragController.endDrag(context.read<WorkspaceBloc>()),
              onPointerCancel: (event) =>
                  _dragController.endDrag(context.read<WorkspaceBloc>()),
              child: Container(
                color: AppColors.canvasBg,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Grid background
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridBackgroundPainter(),
                      ),
                    ),

                    // Windows
                    ...sortedWindows.map((win) {
                      final isActive = win.id == activeTab.activeWindowId;
                      return FloatingWindowShell(
                        key: ValueKey(win.id),
                        window: win,
                        isActive: isActive,
                        canvasSize: canvasSize,
                        contentBuilder: widget.windowContentBuilder,
                        headerBuilder: widget.windowHeaderBuilder,
                      );
                    }),

                    // Empty canvas hint
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
                              'No Windows on this Canvas',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () async {
                                final type =
                                    await AddWidgetDialog.show(context);
                                if (type != null && context.mounted) {
                                  context.read<WorkspaceBloc>().add(
                                        AddWindowEvent(
                                          widgetType: type,
                                          metadata: type ==
                                                  WindowWidgetType.orderbook
                                              ? {'symbol': 'BBRI'}
                                              : {},
                                          canvasSize: canvasSize,
                                        ),
                                      );
                                }
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Widget'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.12)
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
