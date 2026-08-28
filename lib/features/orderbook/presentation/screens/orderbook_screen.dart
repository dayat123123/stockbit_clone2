import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/stock_summary.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_event.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_state.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/widgets/orderbook_table_widget.dart';

/// Feature Screen: Displays the real-time Orderbook depth & statistics for a given stock symbol.
class OrderbookScreen extends StatefulWidget {
  final String symbol;

  const OrderbookScreen({super.key, required this.symbol});

  @override
  State<OrderbookScreen> createState() => _OrderbookScreenState();
}

class _OrderbookScreenState extends State<OrderbookScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderbookBloc>().add(
      LoadOrderbookForSymbolEvent(widget.symbol),
    );
  }

  @override
  void didUpdateWidget(covariant OrderbookScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol) {
      context.read<OrderbookBloc>().add(
        LoadOrderbookForSymbolEvent(widget.symbol),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'en_US');

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

        final orderbook = state is OrderbookLoadedState
            ? state.getBySymbol(widget.symbol)
            : null;

        if (orderbook == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hourglass_empty,
                  size: 24,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 8),
                Text(
                  'Loading ${widget.symbol} Depth...',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardSurface,
                    foregroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(80, 24),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () {
                    context.read<OrderbookBloc>().add(
                      LoadOrderbookForSymbolEvent(widget.symbol),
                    );
                  },
                  child: const Text(
                    'Fetch Data',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          );
        }

        final summary = orderbook.summary;

        return Container(
          color: AppColors.cardBg,
          child: Column(
            children: [
              _buildMetricsBar(summary, fmt),
              Expanded(
                child: OrderbookTableWidget(
                  symbol: summary.symbol,
                  entries: orderbook.entries,
                  totalBidLot: orderbook.totalBidLot,
                  totalOfferLot: orderbook.totalOfferLot,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricsBar(StockSummary summary, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      color: AppColors.cardBg,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _metricRow('Open', fmt.format(summary.open.toInt())),
                _metricRow('High', fmt.format(summary.high.toInt())),
                _metricRow('Low', fmt.format(summary.low.toInt())),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _metricRow('Prev', fmt.format(summary.prev.toInt())),
                _metricRow(
                  'ARA',
                  fmt.format(summary.ara.toInt()),
                  color: AppColors.araYellow,
                ),
                _metricRow(
                  'ARB',
                  fmt.format(summary.arb.toInt()),
                  color: AppColors.arbPurple,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _metricRow('Lot', _formatLot(summary.lot)),
                _metricRow('Val', '${summary.value.toStringAsFixed(1)}B'),
                _metricRow('Avg', fmt.format(summary.avg.toInt())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value, {Color? color}) {
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
              color: color ?? AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLot(int lot) {
    if (lot >= 1000000) return '${(lot / 1000000).toStringAsFixed(1)}M';
    if (lot >= 1000) return '${(lot / 1000).toStringAsFixed(1)}K';
    return '$lot';
  }
}
