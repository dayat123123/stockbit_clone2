import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/features/broker_summary/presentation/screens/broker_summary_screen.dart';
import 'package:stockbit_clone2/features/chart/presentation/screens/chart_screen.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/screens/orderbook_screen.dart';
import 'package:stockbit_clone2/features/trade/presentation/widgets/quick_trade_modal.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_state.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/widgets/watchlist_side_panel.dart';

/// Dedicated Full-Screen View for the Watchlist feature tab.
///
/// Layout:
/// - Left: WatchlistSidePanel (Group dropdown, search filter, and list of stocks with sparklines)
/// - Right: Live interactive dashboard for the selected stock (Orderbook Depth, Real-time Chart, Broker Summary).
class WatchlistFeatureView extends StatelessWidget {
  const WatchlistFeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        String activeSymbol = 'BBCA';
        if (state is WatchlistLoadedState && state.activeSymbol != null) {
          activeSymbol = state.activeSymbol!;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. Left Watchlist List Panel ─────────────────────────────────
            const WatchlistSidePanel(),

            // ── 2. Right Live Stock Analytics Dashboard ──────────────────────
            Expanded(
              child: Container(
                color: AppColors.canvasBg,
                child: Column(
                  children: [
                    // Top Active Stock Bar
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                        color: AppColors.cardHeader,
                        border: Border(
                          bottom: BorderSide(color: AppColors.border, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            activeSymbol,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: AppColors.primaryGreen.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            child: const Text(
                              'LIVE ANALYTICS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 0,
                              ),
                              minimumSize: const Size(70, 26),
                              elevation: 0,
                            ),
                            onPressed: () {
                              QuickTradeModal.show(
                                context,
                                symbol: activeSymbol,
                                isBuy: true,
                              );
                            },
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              size: 13,
                            ),
                            label: const Text(
                              'BUY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Content Split: Orderbook (Left) & Chart + Broker Summary (Right)
                    Expanded(
                      child: Row(
                        children: [
                          // Orderbook & Broker Summary Split
                          SizedBox(
                            width: 360,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: OrderbookScreen(symbol: activeSymbol),
                                ),
                                const Divider(
                                  color: AppColors.border,
                                  height: 1,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: BrokerSummaryScreen(
                                    symbol: activeSymbol,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const VerticalDivider(
                            color: AppColors.border,
                            width: 1,
                          ),

                          // Technical Chart
                          Expanded(child: ChartScreen(symbol: activeSymbol)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
