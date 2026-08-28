import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_state.dart';
import 'package:stockbit_clone2/features/broker_summary/presentation/screens/broker_summary_screen.dart';
import 'package:stockbit_clone2/features/layout/presentation/screens/layout_screen.dart';
import 'package:stockbit_clone2/features/layout/presentation/widgets/testing_window_dialog.dart';
import 'package:stockbit_clone2/features/market/presentation/screens/market_screen.dart';
import 'package:stockbit_clone2/features/navigation/domain/entities/app_nav_tab.dart';
import 'package:stockbit_clone2/features/navigation/presentation/cubit/navigation_cubit.dart';
import 'package:stockbit_clone2/features/navigation/presentation/widgets/desktop_app_title_bar.dart';
import 'package:stockbit_clone2/features/navigation/presentation/widgets/desktop_bottom_ticker.dart';
import 'package:stockbit_clone2/features/navigation/presentation/widgets/desktop_vertical_sidebar.dart';
import 'package:stockbit_clone2/features/order/presentation/screens/orders_screen.dart';
import 'package:stockbit_clone2/features/portfolio/presentation/screens/portfolio_screen.dart';
import 'package:stockbit_clone2/features/screener/presentation/screens/screener_screen.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/screens/watchlist_feature_view.dart';

/// Main Desktop Shell providing professional trading layout:
/// - Top: Frameless Window Title Bar with Drag Area & Window Controls (Minimize, Maximize, Close)
/// - Left: Vertical Navigation Sidebar (Watchlist, Layout, Portfolio, Markets, Screener, etc.)
/// - Center: Active Feature Page (Layout Screen with Multi-Terminal Canvas / Standalone Feature Pages)
/// - Bottom: Real-time Market Running Trades Ticker
///
/// Global Shortcuts:
/// - [F2] / [F3]: Open Testing Window & Order Form Dialog
/// - [Escape]: In 'Fixed Terminal #1', close/delete the last window slot
class DesktopMainShell extends StatefulWidget {
  const DesktopMainShell({super.key});

  @override
  State<DesktopMainShell> createState() => _DesktopMainShellState();
}

class _DesktopMainShellState extends State<DesktopMainShell> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleGlobalKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKeyEvent);
    super.dispose();
  }

  bool _handleGlobalKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    // 1. [F2] / [F3] Hotkey: Open Testing Window Dialog from anywhere
    if (event.logicalKey == LogicalKeyboardKey.f2 ||
        event.logicalKey == LogicalKeyboardKey.f3) {
      TestingWindowDialog.show(context);
      return true;
    }

    // 2. [Escape] Hotkey: ONLY active when looking at Layout Screen AND inside 'Fixed Terminal #1' tab
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      try {
        // Guard 1: Must be currently viewing the Layout screen
        final currentNavTab = context.read<NavigationCubit>().state;
        if (currentNavTab != AppNavTab.layout) {
          return false;
        }

        // Guard 2: Must be currently in the 'Fixed Terminal #1' workspace tab
        final workspaceBloc = context.read<WorkspaceBloc>();
        final state = workspaceBloc.state;
        if (state is WorkspaceLoadedState) {
          final activeTab = state.activeTab;
          final isFixedTerminal1 =
              activeTab.id == 'tab_1' ||
              activeTab.title.toLowerCase().contains('terminal #1') ||
              activeTab.title.toLowerCase().contains('fixed terminal');

          if (isFixedTerminal1 && activeTab.windows.isNotEmpty) {
            final lastWindow = activeTab.windows.last;
            workspaceBloc.add(RemoveWindowEvent(lastWindow.id));
            return true;
          }
        }
      } catch (_) {}
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── 1. Top Frameless Window Title Bar (Spans 100% Full Width) ────
          const DesktopAppTitleBar(
            title: 'Stockbit Desktop Pro - Institutional Trading Terminal',
            showMaximize: true,
          ),

          // ── 2. Main Middle Workspace Area (Sidebar + Content) ────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2a. Left Vertical Navigation Sidebar (68px)
                const DesktopVerticalSidebar(),

                // 2b. Right Main Feature Area
                Expanded(
                  child: Column(
                    children: [
                      // Dynamic Main Feature Content
                      Expanded(
                        child: BlocBuilder<NavigationCubit, AppNavTab>(
                          builder: (context, activeTab) {
                            switch (activeTab) {
                              case AppNavTab.layout:
                                return const LayoutScreen();

                              case AppNavTab.watchlist:
                                return const WatchlistFeatureView();

                              case AppNavTab.order:
                                return const OrdersScreen();

                              case AppNavTab.portfolio:
                                return const PortfolioScreen();

                              case AppNavTab.markets:
                                return const MarketScreen();

                              case AppNavTab.screener:
                                return const ScreenerScreen();

                              case AppNavTab.brokerAnalysis:
                                return const BrokerSummaryScreen(
                                  symbol: 'BBCA',
                                );

                              case AppNavTab.stream:
                              case AppNavTab.eIpo:
                                return const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.stream,
                                        size: 36,
                                        color: AppColors.textMuted,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Feature Coming Soon',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                            }
                          },
                        ),
                      ),

                      // 2c. Real-time Bottom Ticker Bar
                      const DesktopBottomTicker(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
