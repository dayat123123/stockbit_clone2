import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/di/injection_container.dart' as di;
import 'package:stockbit_clone2/core/workspace/models/workspace_widget_type.dart';
import 'package:stockbit_clone2/features/broker_summary/presentation/screens/broker_summary_screen.dart';
import 'package:stockbit_clone2/features/chart/presentation/screens/chart_screen.dart';
import 'package:stockbit_clone2/features/market/presentation/screens/market_screen.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_event.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/screens/orderbook_screen.dart';
import 'package:stockbit_clone2/features/portfolio/presentation/screens/portfolio_screen.dart';
import 'package:stockbit_clone2/features/screener/presentation/screens/screener_screen.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_event.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/screens/watchlist_screen.dart';

/// Dynamic Factory that maps [WorkspaceWidgetType] to its respective feature screen.
///
/// Resilient & Clean Architecture:
/// - Provides automatic BLoC fallback to prevent [ProviderNotFoundException] during hot-reloads or detached sub-windows.
class WorkspaceWidgetFactory {
  static Widget build({
    required WorkspaceWidgetType type,
    required String symbol,
    required String windowId,
  }) {
    switch (type) {
      case WorkspaceWidgetType.orderbook:
        return Builder(
          builder: (context) {
            try {
              context.read<OrderbookBloc>();
              return OrderbookScreen(symbol: symbol);
            } catch (_) {
              return BlocProvider<OrderbookBloc>(
                create: (_) =>
                    di.sl<OrderbookBloc>()..add(const LoadMultiOrderbooksEvent()),
                child: OrderbookScreen(symbol: symbol),
              );
            }
          },
        );

      case WorkspaceWidgetType.chart:
        return ChartScreen(symbol: symbol);

      case WorkspaceWidgetType.watchlist:
        return Builder(
          builder: (context) {
            try {
              context.read<WatchlistBloc>();
              return WatchlistScreen(windowId: windowId);
            } catch (_) {
              return BlocProvider<WatchlistBloc>(
                create: (_) =>
                    di.sl<WatchlistBloc>()..add(const LoadWatchlistEvent()),
                child: WatchlistScreen(windowId: windowId),
              );
            }
          },
        );

      case WorkspaceWidgetType.market:
        return const MarketScreen();

      case WorkspaceWidgetType.screener:
        return const ScreenerScreen();

      case WorkspaceWidgetType.portfolio:
        return const PortfolioScreen();

      case WorkspaceWidgetType.brokerSummary:
        return BrokerSummaryScreen(symbol: symbol);
    }
  }
}
