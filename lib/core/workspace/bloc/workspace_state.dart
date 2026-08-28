import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_tab.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_window.dart';

abstract class WorkspaceState extends Equatable {
  const WorkspaceState();

  @override
  List<Object?> get props => [];
}

class WorkspaceInitialState extends WorkspaceState {
  const WorkspaceInitialState();
}

class WorkspaceLoadedState extends WorkspaceState {
  final List<WorkspaceTab> tabs;
  final int activeTabIndex;
  final String searchQuery;

  const WorkspaceLoadedState({
    required this.tabs,
    this.activeTabIndex = 0,
    this.searchQuery = '',
  });

  WorkspaceTab get activeTab {
    if (tabs.isEmpty) {
      return const WorkspaceTab(
        id: 'tab_default',
        title: 'Workspace',
        windows: [],
      );
    }
    return tabs[activeTabIndex.clamp(0, tabs.length - 1)];
  }

  List<WorkspaceWindow> get windows => activeTab.windows;
  WorkspaceWindow? get activeWindow => activeTab.activeWindow;
  bool get isFreeFloating => activeTab.isFreeFloating;
  int get gridRows => activeTab.gridRows;
  int get gridColumns => activeTab.gridColumns;

  WorkspaceLoadedState copyWith({
    List<WorkspaceTab>? tabs,
    int? activeTabIndex,
    String? searchQuery,
  }) {
    return WorkspaceLoadedState(
      tabs: tabs ?? this.tabs,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [tabs, activeTabIndex, searchQuery];
}
