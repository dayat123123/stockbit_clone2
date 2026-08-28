import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/features/navigation/presentation/widgets/desktop_bottom_ticker.dart';
import 'package:stockbit_clone2/features/navigation/presentation/widgets/desktop_sidebar.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/screens/orderbook_screen.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/widgets/orderbook_top_toolbar.dart';

class DesktopMainShell extends StatelessWidget {
  const DesktopMainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // 1. Sleek Left Sidebar Navigation
          DesktopSidebar(),

          // 2. Main Terminal Workspace
          Expanded(
            child: Column(
              children: [
                // Top Action Toolbar (Search, Grid Selector, Active Slot Indicator, BUY)
                OrderbookTopToolbar(),

                // Draggable Multi-Orderbook Grid Screen
                Expanded(
                  child: OrderbookScreen(),
                ),

                // Real-time Bottom Ticker Bar (IHSG, Trending Stocks, Time)
                DesktopBottomTicker(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
