import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/constants/app_colors.dart';
import 'package:stockbit_clone2/core/navigation/cubit/navigation_cubit.dart';
import 'package:stockbit_clone2/core/navigation/cubit/navigation_state.dart';
import 'package:stockbit_clone2/core/navigation/models/app_nav_tab.dart';
import 'package:stockbit_clone2/core/utils/desktop_window_helper.dart';
import 'package:stockbit_clone2/core/widgets/dialogs/testing_window_dialog.dart';
import 'package:stockbit_clone2/core/widgets/navigation/desktop_app_title_bar.dart';
import 'package:stockbit_clone2/core/widgets/navigation/desktop_bottom_ticker.dart';
import 'package:stockbit_clone2/core/widgets/navigation/desktop_vertical_sidebar.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_state.dart';
import 'package:stockbit_clone2/features/broker_summary/broker_summary_screen.dart';
import 'package:stockbit_clone2/features/layout/layout_screen.dart';
import 'package:stockbit_clone2/features/market/market_screen.dart';
import 'package:stockbit_clone2/features/order/orders_screen.dart';
import 'package:stockbit_clone2/features/portfolio/portfolio_screen.dart';
import 'package:stockbit_clone2/features/screener/screener_screen.dart';
import 'package:stockbit_clone2/features/watchlist/watchlist_feature_view.dart';

/// Main Desktop Shell providing professional trading layout:
/// - Top: Frameless Window Title Bar with Drag Area & Window Controls (Minimize, Maximize, Close)
/// - Left: Vertical Navigation Sidebar (Watchlist, Layout, Portfolio, Markets, Screener, etc.)
/// - Center: Active Feature Page (Layout Screen with Multi-Terminal Canvas / Standalone Feature Pages)
/// - Bottom: Real-time Market Running Trades Ticker
///
/// Global Shortcuts:
/// - [F2] / [F3]: Open Testing Window & Order Form Dialog
/// - [Escape]: Close/delete the active window slot on workspace layout
class DesktopMainShell extends StatefulWidget {
  const DesktopMainShell({super.key});

  @override
  State<DesktopMainShell> createState() => _DesktopMainShellState();
}

class _DesktopMainShellState extends State<DesktopMainShell> {
  /// Track tabs that have been visited so they only initialize on first visit
  /// and remain preserved in memory without disposing when navigating between tabs.
  final Set<AppNavTab> _loadedTabs = {};

  @override
  void initState() {
    super.initState();
    DesktopWindowHelper.setToTerminalMode();
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

    // 2. [Escape] Hotkey: Close active/last window on the current layout canvas
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      try {
        final navState = context.read<NavigationCubit>().state;
        if (navState.tab != AppNavTab.layout) {
          return false;
        }

        final workspaceBloc = context.read<WorkspaceBloc>();
        final state = workspaceBloc.state;
        if (state is WorkspaceLoadedState) {
          final activeTab = state.activeTab;
          if (activeTab.windows.isNotEmpty) {
            final targetWindowId =
                activeTab.activeWindowId ?? activeTab.windows.last.id;
            workspaceBloc.add(RemoveWindowEvent(targetWindowId));
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
                      // Dynamic Main Feature Content with Lazy-Load & State Preservation
                      Expanded(
                        child: BlocBuilder<NavigationCubit, NavigationState>(
                          builder: (context, navState) {
                            // Register current tab as visited so it will be loaded
                            _loadedTabs.add(navState.tab);

                            final tabs = AppNavTab.values;
                            final activeIndex = tabs.indexOf(navState.tab);

                            return IndexedStack(
                              index: activeIndex >= 0 ? activeIndex : 0,
                              children: tabs.map((tab) {
                                if (!_loadedTabs.contains(tab)) {
                                  // Tab not yet visited: do not load or mount
                                  return const SizedBox.shrink();
                                }

                                switch (tab) {
                                  case AppNavTab.watchlist:
                                    return WatchlistFeatureView(
                                      initialSymbol: navState.symbol,
                                    );

                                  case AppNavTab.layout:
                                    return const LayoutScreen();

                                  case AppNavTab.order:
                                    return OrdersScreen(
                                      initialSymbol: navState.symbol,
                                      initialIsBuy: navState.isBuy ?? true,
                                      initialPrice: navState.price,
                                      initialLot: navState.lot,
                                    );

                                  case AppNavTab.portfolio:
                                    return const PortfolioScreen();

                                  case AppNavTab.markets:
                                    return const MarketScreen();

                                  case AppNavTab.screener:
                                    return const ScreenerScreen();

                                  case AppNavTab.brokerAnalysis:
                                    return BrokerSummaryScreen(
                                      symbol: navState.symbol ?? 'BBCA',
                                    );

                                  case AppNavTab.stream:
                                  case AppNavTab.eIpo:
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                              }).toList(),
                            );
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
