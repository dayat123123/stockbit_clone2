import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/core/workspace/models/layout_mode.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_tab_model.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_window_model.dart';

abstract class WorkspaceState extends Equatable {
  const WorkspaceState();

  @override
  List<Object?> get props => [];
}

class WorkspaceInitialState extends WorkspaceState {
  const WorkspaceInitialState();
}

class WorkspaceLoadingState extends WorkspaceState {
  const WorkspaceLoadingState();
}

class WorkspaceLoadedState extends WorkspaceState {
  final List<WorkspaceTabModel> tabs;
  final int activeTabIndex;
  final String searchQuery;
  final DateTime lastUpdated;

  const WorkspaceLoadedState({
    required this.tabs,
    this.activeTabIndex = 0,
    this.searchQuery = '',
    required this.lastUpdated,
  });

  WorkspaceTabModel get activeTab {
    if (tabs.isEmpty) {
      return const WorkspaceTabModel(
        id: 'tab_default',
        title: 'Terminal Tab',
        windows: [],
      );
    }
    return tabs[activeTabIndex.clamp(0, tabs.length - 1)];
  }

  List<WorkspaceWindowModel> get windows => activeTab.windows;
  WorkspaceWindowModel? get activeWindow => activeTab.activeWindow;
  LayoutMode get layoutMode => activeTab.layoutMode;
  bool get isScrollable => activeTab.layoutMode == LayoutMode.scrollable;
  bool get isFreeFloating => activeTab.isFreeFloating;
  int get gridRows => activeTab.gridRows;
  int get gridColumns => activeTab.gridColumns;

  WorkspaceLoadedState copyWith({
    List<WorkspaceTabModel>? tabs,
    int? activeTabIndex,
    String? searchQuery,
    DateTime? lastUpdated,
  }) {
    return WorkspaceLoadedState(
      tabs: tabs ?? this.tabs,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [tabs, activeTabIndex, searchQuery, lastUpdated];
}

class WorkspaceErrorState extends WorkspaceState {
  final String message;
  const WorkspaceErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
