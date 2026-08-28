import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_window_item.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_event.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_state.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/controllers/canvas_drag_controller.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/widgets/orderbook_floating_window.dart';

class OrderbookCanvasWorkspace extends StatefulWidget {
  const OrderbookCanvasWorkspace({super.key});

  @override
  State<OrderbookCanvasWorkspace> createState() =>
      _OrderbookCanvasWorkspaceState();
}

class _OrderbookCanvasWorkspaceState extends State<OrderbookCanvasWorkspace> {
  /// One controller for the whole canvas — handles drag for any window.
  final CanvasDragController _dragController = CanvasDragController();

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderbookBloc, OrderbookState>(
      builder: (context, state) {
        // ── Loading ────────────────────────────────────────────────────────────
        if (state is OrderbookLoadingState) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen,
              strokeWidth: 2,
            ),
          );
        }

        // ── Error ─────────────────────────────────────────────────────────────
        if (state is OrderbookErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 36, color: AppColors.offerRed),
                const SizedBox(height: 12),
                Text(state.message,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => context
                      .read<OrderbookBloc>()
                      .add(const LoadMultiOrderbooksEvent()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // ── Canvas ────────────────────────────────────────────────────────────
        if (state is OrderbookLoadedState) {
          final activeTab = state.activeTab;
          final sortedWindows = List<OrderbookWindowItem>.from(activeTab.windows)
            ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

          return LayoutBuilder(
            builder: (context, constraints) {
              final canvasSize =
                  Size(constraints.maxWidth, constraints.maxHeight);

              return Listener(
                // ── Single GestureDetector for the whole canvas drag ──────────
                onPointerDown: (event) {
                  // Hit-test which window the pointer landed on (topmost first)
                  final reversedWindows =
                      sortedWindows.reversed.toList();
                  for (final win in reversedWindows) {
                    final rect = Rect.fromLTWH(
                      win.position.dx,
                      win.position.dy,
                      win.size.width,
                      win.size.height,
                    );
                    // Only start drag when the user presses the header strip (top 34px)
                    final headerRect = Rect.fromLTWH(
                      win.position.dx,
                      win.position.dy,
                      win.size.width,
                      34,
                    );
                    if (headerRect.contains(event.localPosition)) {
                      _dragController.startDrag(
                          win.id, context.read<OrderbookBloc>());
                      break;
                    } else if (rect.contains(event.localPosition)) {
                      // Tap elsewhere on the window just focuses it
                      context
                          .read<OrderbookBloc>()
                          .add(SetActiveWindowEvent(win.id));
                      break;
                    }
                  }
                },
                onPointerMove: (event) {
                  _dragController.updateDrag(
                    event.delta,
                    canvasSize,
                    context.read<OrderbookBloc>(),
                  );
                },
                onPointerUp: (event) => _dragController.endDrag(
                    context.read<OrderbookBloc>()),
                onPointerCancel: (event) => _dragController.endDrag(
                    context.read<OrderbookBloc>()),
                child: Container(
                  color: AppColors.canvasBg,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── Blueprint grid background ───────────────────────────
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GridBackgroundPainter(),
                        ),
                      ),

                      // ── Orderbook windows ───────────────────────────────────
                      ...sortedWindows.map((win) {
                        final isActive = win.id == activeTab.activeWindowId;
                        return OrderbookFloatingWindow(
                          key: ValueKey(win.id),
                          window: win,
                          isActive: isActive,
                          canvasSize: canvasSize,
                        );
                      }),

                      // ── Empty canvas hint ───────────────────────────────────
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
                                'No Orderbook Windows on this Canvas',
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
                                onPressed: () => context
                                    .read<OrderbookBloc>()
                                    .add(AddNewWindowToWorkspaceEvent(
                                      symbol: 'BBRI',
                                      canvasSize: canvasSize,
                                    )),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Window'),
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
        }

        return const SizedBox.shrink();
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
