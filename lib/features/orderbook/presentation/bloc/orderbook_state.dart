import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_window_item.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/workspace_tab.dart';

abstract class OrderbookState extends Equatable {
  const OrderbookState();

  @override
  List<Object?> get props => [];
}

class OrderbookInitialState extends OrderbookState {
  const OrderbookInitialState();
}

class OrderbookLoadingState extends OrderbookState {
  const OrderbookLoadingState();
}

class OrderbookLoadedState extends OrderbookState {
  final List<WorkspaceTab> tabs;
  final int activeTabIndex;
  final String searchQuery;
  final DateTime lastUpdated;

  const OrderbookLoadedState({
    required this.tabs,
    this.activeTabIndex = 0,
    this.searchQuery = '',
    required this.lastUpdated,
  });

  WorkspaceTab get activeTab {
    if (tabs.isEmpty) {
      return const WorkspaceTab(id: 'tab_default', title: 'Multi-orderbook', windows: []);
    }
    return tabs[activeTabIndex.clamp(0, tabs.length - 1)];
  }

  List<OrderbookWindowItem> get windows => activeTab.windows;
  OrderbookWindowItem? get activeWindow => activeTab.activeWindow;
  bool get isFreeFloating => activeTab.isFreeFloating;
  int get gridRows => activeTab.gridRows;
  int get gridColumns => activeTab.gridColumns;

  OrderbookLoadedState copyWith({
    List<WorkspaceTab>? tabs,
    int? activeTabIndex,
    String? searchQuery,
    DateTime? lastUpdated,
  }) {
    return OrderbookLoadedState(
      tabs: tabs ?? this.tabs,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [tabs, activeTabIndex, searchQuery, lastUpdated];
}

class OrderbookErrorState extends OrderbookState {
  final String message;
  const OrderbookErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
