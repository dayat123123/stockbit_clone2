import 'package:flutter/material.dart';

/// All widget types that can be placed inside a workspace window.
/// The "+" button uses this enum to let users pick what to add.
enum WindowWidgetType {
  orderbook('Orderbook', Icons.menu_book_outlined, Size(350, 390)),
  chart('Chart', Icons.candlestick_chart_outlined, Size(500, 400)),
  watchlist('Watchlist', Icons.list_alt_outlined, Size(300, 400)),
  portfolio('Portfolio', Icons.account_balance_wallet_outlined, Size(400, 350)),
  tradeHistory('Trade History', Icons.history_outlined, Size(400, 350)),
  news('News', Icons.newspaper_outlined, Size(380, 400));

  final String label;
  final IconData icon;

  /// Default size when a new window of this type is created.
  final Size defaultSize;

  const WindowWidgetType(this.label, this.icon, this.defaultSize);
}
