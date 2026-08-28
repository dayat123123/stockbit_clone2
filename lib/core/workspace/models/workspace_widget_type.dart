import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';

/// Supported widget types that can be added into any workspace window slot.
enum WorkspaceWidgetType {
  orderbook(
    label: 'Orderbook',
    description: 'Real-time 10-level bid/ask depth and price statistics.',
    icon: Icons.format_list_numbered_rtl,
    color: AppColors.primaryGreen,
    requiresSymbol: true,
  ),
  chart(
    label: 'Technical Chart',
    description: 'Interactive candlestick/line technical analysis chart.',
    icon: Icons.candlestick_chart_outlined,
    color: AppColors.badgeBlue,
    requiresSymbol: true,
  ),
  watchlist(
    label: 'Watchlist',
    description: 'Monitored stock prices, daily changes, and volumes.',
    icon: Icons.bookmark_outline,
    color: AppColors.araYellow,
    requiresSymbol: true,
  ),
  market(
    label: 'Market Overview',
    description: 'IHSG index status, sector leaders, and top movers.',
    icon: Icons.public,
    color: AppColors.badgePurple,
    requiresSymbol: false,
  ),
  screener(
    label: 'Stock Screener',
    description: 'Fundamental filters (P/E, ROE, Dividend Yield).',
    icon: Icons.filter_alt_outlined,
    color: Colors.tealAccent,
    requiresSymbol: false,
  ),
  portfolio(
    label: 'Portfolio',
    description: 'Account portfolio value, holdings, and unrealized P&L.',
    icon: Icons.account_balance_wallet_outlined,
    color: Colors.orangeAccent,
    requiresSymbol: false,
  ),
  brokerSummary(
    label: 'Broker Summary',
    description: 'Foreign/domestic net buy and top broker accumulation.',
    icon: Icons.pie_chart_outline,
    color: Colors.cyanAccent,
    requiresSymbol: true,
  );

  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final bool requiresSymbol;

  const WorkspaceWidgetType({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiresSymbol,
  });
}
