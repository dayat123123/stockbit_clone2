import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_window_item.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_event.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/widgets/orderbook_table_widget.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/widgets/stock_search_dialog.dart';
import 'package:stockbit_clone2/features/trade/presentation/widgets/quick_trade_modal.dart';

class OrderbookFloatingWindow extends StatelessWidget {
  final OrderbookWindowItem window;
  final bool isActive;
  final Size canvasSize;

  const OrderbookFloatingWindow({
    super.key,
    required this.window,
    required this.isActive,
    this.canvasSize = const Size(1400, 800),
  });

  @override
  Widget build(BuildContext context) {
    final orderbook = window.orderbook;
    final summary = orderbook?.summary;
    final numberFormat = NumberFormat('#,###', 'en_US');

    final changeColor = summary == null
        ? AppColors.textMuted
        : (summary.change > 0
              ? AppColors.bidGreen
              : (summary.change < 0 ? AppColors.offerRed : AppColors.neutral));

    final changePrefix = summary != null && summary.change > 0 ? '+' : '';
    final changeText = summary == null
        ? ''
        : '$changePrefix${numberFormat.format(summary.change.toInt())} (${summary.changePercent >= 0 ? '+' : ''}${summary.changePercent.toStringAsFixed(2)}%)';

    return Positioned(
      left: window.position.dx,
      top: window.position.dy,
      width: window.size.width,
      height: window.size.height,
      child: GestureDetector(
        onTapDown: (_) {
          context.read<OrderbookBloc>().add(SetActiveWindowEvent(window.id));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isActive ? AppColors.borderActive : AppColors.border,
              width: isActive ? 2.0 : 1.0,
            ),
            boxShadow: isActive ? AppColors.activeGlow : AppColors.windowShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Draggable Window Header with Magnetic Snap
              GestureDetector(
                onPanStart: (_) {
                  context.read<OrderbookBloc>().add(
                    SetActiveWindowEvent(window.id),
                  );
                },
                onPanUpdate: (details) {
                  context.read<OrderbookBloc>().add(
                    MoveWindowEvent(
                      windowId: window.id,
                      delta: details.delta,
                      canvasSize: canvasSize,
                      enableMagneticSnap: true,
                    ),
                  );
                },
                onPanEnd: (_) {
                  context.read<OrderbookBloc>().add(
                    EndDragWindowEvent(
                      windowId: window.id,
                      canvasSize: canvasSize,
                    ),
                  );
                },
                onPanCancel: () {
                  context.read<OrderbookBloc>().add(
                    EndDragWindowEvent(
                      windowId: window.id,
                      canvasSize: canvasSize,
                    ),
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.move,
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryGreen.withValues(alpha: 0.12)
                          : AppColors.cardHeader,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: isActive
                              ? AppColors.primaryGreen.withValues(alpha: 0.3)
                              : AppColors.border,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Drag Indicator
                        const Icon(
                          Icons.drag_indicator,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),

                        if (summary != null) ...[
                          // Stock Avatar
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.badgeBlue.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                summary.symbol.substring(0, 1),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.badgeBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Symbol Selector Button
                          InkWell(
                            onTap: () {
                              StockSearchDialog.show(
                                context,
                                targetSlotIndex: 0,
                                onSymbolSelected: (newSymbol) {
                                  context.read<OrderbookBloc>().add(
                                    ChangeWindowSymbolEvent(
                                      windowId: window.id,
                                      newSymbol: newSymbol,
                                    ),
                                  );
                                },
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  summary.symbol,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Leverage Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.badgePurple.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: AppColors.badgePurple.withValues(
                                  alpha: 0.4,
                                ),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              summary.leverage,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: AppColors.badgePurple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Price & Change
                          Text(
                            numberFormat.format(summary.price.toInt()),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: changeColor,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            changeText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: changeColor,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Empty Orderbook Slot',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],

                        const Spacer(),

                        // BUY Button
                        if (summary != null) ...[
                          InkWell(
                            onTap: () {
                              QuickTradeModal.show(
                                context,
                                symbol: summary.symbol,
                                price: summary.price,
                                isBuy: true,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Text(
                                'BUY',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],

                        // Window Options Menu
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_horiz,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: AppColors.cardBg,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'change',
                              child: Text(
                                'Change Symbol',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (summary != null) ...[
                              const PopupMenuItem(
                                value: 'buy',
                                child: Text(
                                  'Quick Buy Order',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.bidGreen,
                                  ),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'sell',
                                child: Text(
                                  'Quick Sell Order',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.offerRed,
                                  ),
                                ),
                              ),
                            ],
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text(
                                'Close Window',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.offerRed,
                                ),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'change') {
                              StockSearchDialog.show(
                                context,
                                targetSlotIndex: 0,
                                onSymbolSelected: (newSymbol) {
                                  context.read<OrderbookBloc>().add(
                                    ChangeWindowSymbolEvent(
                                      windowId: window.id,
                                      newSymbol: newSymbol,
                                    ),
                                  );
                                },
                              );
                            } else if (value == 'buy' && summary != null) {
                              QuickTradeModal.show(
                                context,
                                symbol: summary.symbol,
                                price: summary.price,
                                isBuy: true,
                              );
                            } else if (value == 'sell' && summary != null) {
                              QuickTradeModal.show(
                                context,
                                symbol: summary.symbol,
                                price: summary.price,
                                isBuy: false,
                              );
                            } else if (value == 'remove') {
                              context.read<OrderbookBloc>().add(
                                RemoveWindowEvent(window.id),
                              );
                            }
                          },
                        ),

                        const SizedBox(width: 2),

                        // Close Window button
                        InkWell(
                          onTap: () {
                            context.read<OrderbookBloc>().add(
                              RemoveWindowEvent(window.id),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Window Body
              Expanded(
                child: summary != null
                    ? Column(
                        children: [
                          // Metric Info Grid (Open, High, Low, Prev, ARA, ARB, Lot, Val, Avg)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            color: AppColors.cardBg,
                            child: Row(
                              children: [
                                // Col 1: Open / High / Low
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      _buildMetricRow(
                                        'Open',
                                        numberFormat.format(
                                          summary.open.toInt(),
                                        ),
                                      ),
                                      _buildMetricRow(
                                        'High',
                                        numberFormat.format(
                                          summary.high.toInt(),
                                        ),
                                      ),
                                      _buildMetricRow(
                                        'Low',
                                        numberFormat.format(
                                          summary.low.toInt(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Col 2: Prev / ARA / ARB
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      _buildMetricRow(
                                        'Prev',
                                        numberFormat.format(
                                          summary.prev.toInt(),
                                        ),
                                      ),
                                      _buildMetricRow(
                                        'ARA',
                                        numberFormat.format(
                                          summary.ara.toInt(),
                                        ),
                                        valueColor: AppColors.araYellow,
                                      ),
                                      _buildMetricRow(
                                        'ARB',
                                        numberFormat.format(
                                          summary.arb.toInt(),
                                        ),
                                        valueColor: AppColors.arbPurple,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Col 3: Lot / Val / Avg
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      _buildMetricRow(
                                        'Lot',
                                        _formatLot(summary.lot),
                                      ),
                                      _buildMetricRow(
                                        'Val',
                                        '${summary.value.toStringAsFixed(1)}B',
                                      ),
                                      _buildMetricRow(
                                        'Avg',
                                        numberFormat.format(
                                          summary.avg.toInt(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Depth Table
                          Expanded(
                            child: OrderbookTableWidget(
                              symbol: summary.symbol,
                              entries: orderbook!.entries,
                              totalBidLot: orderbook.totalBidLot,
                              totalOfferLot: orderbook.totalOfferLot,
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_chart_outlined,
                              size: 28,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No stock assigned',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.cardSurface,
                                foregroundColor: AppColors.primaryGreen,
                                side: const BorderSide(
                                  color: AppColors.borderLight,
                                ),
                                minimumSize: const Size(100, 26),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                              ),
                              onPressed: () {
                                StockSearchDialog.show(
                                  context,
                                  targetSlotIndex: 0,
                                  onSymbolSelected: (newSymbol) {
                                    context.read<OrderbookBloc>().add(
                                      ChangeWindowSymbolEvent(
                                        windowId: window.id,
                                        newSymbol: newSymbol,
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.add, size: 12),
                              label: const Text(
                                'Add Symbol',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              // 3. Resize Handle in bottom-right corner
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    final newW = (window.size.width + details.delta.dx).clamp(
                      260.0,
                      800.0,
                    );
                    final newH = (window.size.height + details.delta.dy).clamp(
                      280.0,
                      900.0,
                    );
                    context.read<OrderbookBloc>().add(
                      ResizeWindowEvent(
                        windowId: window.id,
                        newSize: Size(newW, newH),
                      ),
                    );
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeDownRight,
                    child: Container(
                      width: 14,
                      height: 14,
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(2),
                      child: const Icon(
                        Icons.south_east,
                        size: 9,
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
    );
  }

  Widget _buildMetricRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLot(int lot) {
    if (lot >= 1000000) {
      return '${(lot / 1000000).toStringAsFixed(1)}M';
    } else if (lot >= 1000) {
      return '${(lot / 1000).toStringAsFixed(1)}K';
    }
    return '$lot';
  }
}
