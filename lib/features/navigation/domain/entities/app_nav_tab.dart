import 'package:flutter/material.dart';

/// Navigation items displayed in the left vertical sidebar.
enum AppNavTab {
  watchlist(
    label: 'Watchlist',
    icon: Icons.bookmark_outline,
  ),
  layout(
    label: 'Layout',
    icon: Icons.dashboard_customize_outlined,
  ),
  portfolio(
    label: 'Portfolio',
    icon: Icons.account_balance_wallet_outlined,
  ),
  markets(
    label: 'Markets',
    icon: Icons.public,
  ),
  stream(
    label: 'Stream',
    icon: Icons.forum_outlined,
  ),
  screener(
    label: 'Screener',
    icon: Icons.filter_alt_outlined,
  ),
  eIpo(
    label: 'e-IPO',
    icon: Icons.new_releases_outlined,
  ),
  brokerAnalysis(
    label: 'Broker',
    icon: Icons.pie_chart_outline,
  );

  final String label;
  final IconData icon;

  const AppNavTab({
    required this.label,
    required this.icon,
  });
}
