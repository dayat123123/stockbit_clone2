import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_widget_type.dart';
import 'package:stockbit_clone2/features/broker_summary/presentation/screens/broker_summary_screen.dart';
import 'package:stockbit_clone2/features/chart/presentation/screens/chart_screen.dart';
import 'package:stockbit_clone2/features/market/presentation/screens/market_screen.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/screens/orderbook_screen.dart';
import 'package:stockbit_clone2/features/portfolio/presentation/screens/portfolio_screen.dart';
import 'package:stockbit_clone2/features/screener/presentation/screens/screener_screen.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/screens/watchlist_screen.dart';

/// Dynamic Factory that maps [WorkspaceWidgetType] to its respective feature screen.
///
/// Follows Factory Design Pattern & Clean Architecture:
/// - Core workspace does not hardcode feature business logic.
/// - Feature screens are instantiated on demand based on slot configuration.
class WorkspaceWidgetFactory {
  static Widget build({
    required WorkspaceWidgetType type,
    required String symbol,
    required String windowId,
  }) {
    switch (type) {
      case WorkspaceWidgetType.orderbook:
        return OrderbookScreen(symbol: symbol);
      case WorkspaceWidgetType.chart:
        return ChartScreen(symbol: symbol);
      case WorkspaceWidgetType.watchlist:
        return WatchlistScreen(windowId: windowId);
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
