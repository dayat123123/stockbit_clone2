import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/navigation/cubit/navigation_state.dart';
import 'package:stockbit_clone2/core/navigation/models/app_nav_tab.dart';

/// Navigation Cubit managing active tab state and dynamic arguments.
///
/// Features:
/// - [selectTab] allows passing dynamic Map arguments, or named shortcuts like [symbol] and [isBuy].
/// - Dedicated convenience methods: [navigateToOrder], [navigateToWatchlist], [navigateToLayout], [navigateToPortfolio].
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(tab: AppNavTab.layout));

  /// Switch active tab with optional dynamic arguments.
  ///
  /// Examples:
  /// ```dart
  /// // 1. Simple tab switch:
  /// context.read<NavigationCubit>().selectTab(AppNavTab.watchlist);
  ///
  /// // 2. Tab switch with named shortcuts:
  /// context.read<NavigationCubit>().selectTab(
  ///   AppNavTab.order,
  ///   symbol: 'BBCA',
  ///   isBuy: true,
  /// );
  ///
  /// // 3. Tab switch with dynamic custom arguments:
  /// context.read<NavigationCubit>().selectTab(
  ///   AppNavTab.order,
  ///   arguments: {'symbol': 'TLKM', 'isBuy': false, 'price': 2940, 'lot': 50},
  /// );
  /// ```
  void selectTab(
    AppNavTab tab, {
    Map<String, dynamic>? arguments,
    String? symbol,
    bool? isBuy,
    int? price,
    int? lot,
  }) {
    final combinedArgs = <String, dynamic>{
      ...?arguments,
      if (symbol != null) 'symbol': symbol,
      if (isBuy != null) 'isBuy': isBuy,
      if (price != null) 'price': price,
      if (lot != null) 'lot': lot,
    };
    emit(NavigationState(tab: tab, arguments: combinedArgs));
  }

  /// Convenience shortcut to immediately open Orders screen with pre-filled order data.
  void navigateToOrder({
    required String symbol,
    bool isBuy = true,
    int? price,
    int? lot,
    Map<String, dynamic>? extraArgs,
  }) {
    selectTab(
      AppNavTab.order,
      arguments: {
        'symbol': symbol,
        'isBuy': isBuy,
        if (price != null) 'price': price,
        if (lot != null) 'lot': lot,
        ...?extraArgs,
      },
    );
  }

  /// Convenience shortcut to immediately navigate to Watchlist screen.
  void navigateToWatchlist({String? symbol}) {
    selectTab(AppNavTab.watchlist, symbol: symbol);
  }

  /// Convenience shortcut to navigate to Workspace Layout canvas.
  void navigateToLayout() {
    selectTab(AppNavTab.layout);
  }

  /// Convenience shortcut to navigate to Portfolio screen.
  void navigateToPortfolio() {
    selectTab(AppNavTab.portfolio);
  }
}
