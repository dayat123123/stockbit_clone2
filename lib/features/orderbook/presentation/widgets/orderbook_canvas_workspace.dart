import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_window_item.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_event.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_state.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/widgets/orderbook_floating_window.dart';

class OrderbookCanvasWorkspace extends StatelessWidget {
  const OrderbookCanvasWorkspace({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderbookBloc, OrderbookState>(
      builder: (context, state) {
        if (state is OrderbookLoadingState) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen,
              strokeWidth: 2,
            ),
          );
        }

        if (state is OrderbookErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 36, color: AppColors.offerRed),
                const SizedBox(height: 12),
                Text(state.message, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    context.read<OrderbookBloc>().add(const LoadMultiOrderbooksEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is OrderbookLoadedState) {
          final activeTab = state.activeTab;
          final windows = List<OrderbookWindowItem>.from(activeTab.windows)
            ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
          final snapGuide = state.magneticSnapGuide;

          return LayoutBuilder(
            builder: (context, constraints) {
              final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

              return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: AppColors.canvasBg,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Canvas Grid blueprint background lines
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridBackgroundPainter(),
                      ),
                    ),

                    // 2. Magnetic Snap Visual Guide (Ghost Slot Target)
                    if (snapGuide != null)
                      Positioned(
                        left: snapGuide.left,
                        top: snapGuide.top,
                        width: snapGuide.width,
                        height: snapGuide.height,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 0.6),
                              width: 1.5,
                              strokeAlign: BorderSide.strokeAlignCenter,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.flash_on, size: 14, color: AppColors.primaryGreen),
                                const SizedBox(width: 4),
                                Text(
                                  'Magnetic Snap Lock',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen.withValues(alpha: 0.9),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // 3. Orderbook Windows in stacking order
                    ...windows.map((win) {
                      final isActive = win.id == activeTab.activeWindowId;
                      return OrderbookFloatingWindow(
                        key: ValueKey(win.id),
                        window: win,
                        isActive: isActive,
                        canvasSize: canvasSize,
                      );
                    }),

                    if (windows.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.dashboard_customize_outlined, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'No Orderbook Windows on this Canvas',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                context.read<OrderbookBloc>().add(
                                      AddNewWindowToWorkspaceEvent(
                                        symbol: 'BBRI',
                                        canvasSize: canvasSize,
                                      ),
                                    );
                              },
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Window'),
                            ),
                          ],
                        ),
                      ),
                  ],
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
