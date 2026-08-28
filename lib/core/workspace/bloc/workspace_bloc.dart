import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_state.dart';
import 'package:stockbit_clone2/core/workspace/models/window_widget_type.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_tab.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_window.dart';

/// Manages all workspace window operations: move, resize, add, remove,
/// tabs, layout modes, and grid arrangement.
///
/// This bloc is **feature-agnostic** — it doesn't know about orderbook data
/// or any specific widget content. It only manages window geometry and metadata.
class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  int _tabCounter = 1;
  int _windowCounter = 0;

  WorkspaceBloc() : super(const WorkspaceInitialState()) {
    on<InitWorkspaceEvent>(_onInit);
    // Tabs
    on<SelectTabEvent>(_onSelectTab);
    on<AddTabEvent>(_onAddTab);
    on<CloseTabEvent>(_onCloseTab);
    // Windows
    on<SetActiveWindowEvent>(_onSetActiveWindow);
    on<MoveWindowEvent>(_onMoveWindow);
    on<ResizeWindowEvent>(_onResizeWindow);
    on<AddWindowEvent>(_onAddWindow);
    on<RemoveWindowEvent>(_onRemoveWindow);
    on<UpdateWindowMetadataEvent>(_onUpdateWindowMetadata);
    // Layout
    on<ToggleLayoutModeEvent>(_onToggleLayoutMode);
    on<AutoArrangeWindowsEvent>(_onAutoArrangeWindows);
    on<SetGridPresetEvent>(_onSetGridPreset);
    // Search
    on<FilterGlobalSearchEvent>(_onFilterGlobalSearch);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  WorkspaceLoadedState get _loaded => state as WorkspaceLoadedState;
  bool get _isLoaded => state is WorkspaceLoadedState;

  String _nextWindowId() => 'win_${++_windowCounter}';

  void _mutateActiveTab(
    WorkspaceLoadedState current,
    Emitter<WorkspaceState> emit,
    WorkspaceTab Function(WorkspaceTab tab) mutate,
  ) {
    final updatedTabs = List<WorkspaceTab>.from(current.tabs);
    updatedTabs[current.activeTabIndex] = mutate(current.activeTab);
    emit(current.copyWith(tabs: updatedTabs));
  }

  // ─── Init ─────────────────────────────────────────────────────────────────

  void _onInit(InitWorkspaceEvent event, Emitter<WorkspaceState> emit) {
    final windows = <WorkspaceWindow>[
      for (int i = 0; i < event.initialWindows.length; i++)
        WorkspaceWindow(
          id: _nextWindowId(),
          widgetType: event.initialWindows[i].$1,
          metadata: event.initialWindows[i].$2,
          position: Offset((i % 4) * 354.0 + 4, (i ~/ 4) * 394.0 + 4),
          size: event.initialWindows[i].$1.defaultSize,
          zIndex: i,
        ),
    ];

    emit(WorkspaceLoadedState(
      tabs: [
        WorkspaceTab(
          id: 'tab_1',
          title: 'Multi-orderbook',
          windows: windows,
          activeWindowId: windows.isNotEmpty ? windows.first.id : null,
          isFreeFloating: false,
          gridRows: 2,
          gridColumns: 4,
        ),
      ],
      activeTabIndex: 0,
    ));
  }

  // ─── Tab Management ───────────────────────────────────────────────────────

  void _onSelectTab(SelectTabEvent event, Emitter<WorkspaceState> emit) {
    if (!_isLoaded) return;
    final current = _loaded;
    if (event.tabIndex >= 0 && event.tabIndex < current.tabs.length) {
      emit(current.copyWith(activeTabIndex: event.tabIndex));
    }
  }

  void _onAddTab(AddTabEvent event, Emitter<WorkspaceState> emit) {
    if (!_isLoaded) return;
    final current = _loaded;
    _tabCounter++;

    final newWindows = <WorkspaceWindow>[
      for (int i = 0; i < event.initialWindows.length; i++)
        WorkspaceWindow(
          id: _nextWindowId(),
          widgetType: event.initialWindows[i].$1,
          metadata: event.initialWindows[i].$2,
          position: Offset((i % 2) * 354.0 + 4, (i ~/ 2) * 394.0 + 4),
          size: event.initialWindows[i].$1.defaultSize,
          zIndex: i,
        ),
    ];

    final newTab = WorkspaceTab(
      id: 'tab_$_tabCounter',
      title: '${event.title} #$_tabCounter',
      windows: newWindows,
      activeWindowId: newWindows.isNotEmpty ? newWindows.first.id : null,
      isFreeFloating: false,
      gridRows: 2,
      gridColumns: 2,
    );

    final updatedTabs = List<WorkspaceTab>.from(current.tabs)..add(newTab);
    emit(current.copyWith(
      tabs: updatedTabs,
      activeTabIndex: updatedTabs.length - 1,
    ));
  }

  void _onCloseTab(CloseTabEvent event, Emitter<WorkspaceState> emit) {
    if (!_isLoaded) return;
    final current = _loaded;
    if (current.tabs.length <= 1) return;

    final updatedTabs = List<WorkspaceTab>.from(current.tabs)
      ..removeAt(event.tabIndex);
    final newIndex =
        current.activeTabIndex.clamp(0, updatedTabs.length - 1);
    emit(current.copyWith(tabs: updatedTabs, activeTabIndex: newIndex));
  }

  // ─── Window Focus ─────────────────────────────────────────────────────────

  void _onSetActiveWindow(
    SetActiveWindowEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final maxZ =
        current.activeTab.windows.fold(0, (m, w) => max(m, w.zIndex));

    _mutateActiveTab(
      current,
      emit,
      (tab) => tab.copyWith(
        activeWindowId: event.windowId,
        windows: tab.windows.map((w) {
          return w.id == event.windowId
              ? w.copyWith(zIndex: maxZ + 1)
              : w;
        }).toList(),
      ),
    );
  }

  // ─── Window Move ──────────────────────────────────────────────────────────

  void _onMoveWindow(MoveWindowEvent event, Emitter<WorkspaceState> emit) {
    if (!_isLoaded) return;
    final current = _loaded;
    final maxZ =
        current.activeTab.windows.fold(0, (m, w) => max(m, w.zIndex));

    _mutateActiveTab(current, emit, (tab) {
      return tab.copyWith(
        activeWindowId: event.windowId,
        isFreeFloating: true,
        windows: tab.windows.map((w) {
          if (w.id != event.windowId) return w;
          return w.copyWith(
            zIndex: maxZ + 1,
            position: Offset(
              (w.position.dx + event.delta.dx)
                  .clamp(0.0, max(0.0, event.canvasSize.width - 60)),
              (w.position.dy + event.delta.dy)
                  .clamp(0.0, max(0.0, event.canvasSize.height - 40)),
            ),
          );
        }).toList(),
      );
    });
  }

  // ─── Resize ───────────────────────────────────────────────────────────────

  void _onResizeWindow(
    ResizeWindowEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    _mutateActiveTab(_loaded, emit, (tab) {
      return tab.copyWith(
        windows: tab.windows.map((w) {
          return w.id == event.windowId
              ? w.copyWith(size: event.newSize)
              : w;
        }).toList(),
      );
    });
  }

  // ─── Window CRUD ──────────────────────────────────────────────────────────

  void _onAddWindow(AddWindowEvent event, Emitter<WorkspaceState> emit) {
    if (!_isLoaded) return;
    final current = _loaded;
    final maxZ =
        current.activeTab.windows.fold(0, (m, w) => max(m, w.zIndex));

    final offset = (current.activeTab.windows.length * 30.0) % 200;
    final newWindow = WorkspaceWindow(
      id: _nextWindowId(),
      widgetType: event.widgetType,
      metadata: event.metadata,
      position: Offset(40 + offset, 40 + offset),
      size: event.widgetType.defaultSize,
      zIndex: maxZ + 1,
    );

    _mutateActiveTab(current, emit, (tab) {
      return tab.copyWith(
        activeWindowId: newWindow.id,
        windows: [...tab.windows, newWindow],
      );
    });
  }

  void _onRemoveWindow(
    RemoveWindowEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    _mutateActiveTab(_loaded, emit, (tab) {
      final remaining =
          tab.windows.where((w) => w.id != event.windowId).toList();
      return tab.copyWith(
        windows: remaining,
        activeWindowId: remaining.isNotEmpty ? remaining.last.id : null,
      );
    });
  }

  void _onUpdateWindowMetadata(
    UpdateWindowMetadataEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    _mutateActiveTab(_loaded, emit, (tab) {
      return tab.copyWith(
        windows: tab.windows.map((w) {
          if (w.id != event.windowId) return w;
          return w.copyWith(
            metadata: {...w.metadata, ...event.metadata},
          );
        }).toList(),
      );
    });
  }

  // ─── Layout ───────────────────────────────────────────────────────────────

  void _onToggleLayoutMode(
    ToggleLayoutModeEvent _,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final tab = current.activeTab;
    final newFreeFloating = !tab.isFreeFloating;
    var updatedTab = tab.copyWith(isFreeFloating: newFreeFloating);

    if (!newFreeFloating) {
      updatedTab = _applyGridLayout(updatedTab, const Size(1440, 820));
    }

    final updatedTabs = List<WorkspaceTab>.from(current.tabs);
    updatedTabs[current.activeTabIndex] = updatedTab;
    emit(current.copyWith(tabs: updatedTabs));
  }

  void _onAutoArrangeWindows(
    AutoArrangeWindowsEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final updatedTabs = List<WorkspaceTab>.from(current.tabs);
    updatedTabs[current.activeTabIndex] = _applyGridLayout(
      current.activeTab.copyWith(isFreeFloating: false),
      event.canvasSize,
    );
    emit(current.copyWith(tabs: updatedTabs));
  }

  void _onSetGridPreset(
    SetGridPresetEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final updatedTabs = List<WorkspaceTab>.from(current.tabs);
    updatedTabs[current.activeTabIndex] = _applyGridLayout(
      current.activeTab.copyWith(
        gridRows: event.rows,
        gridColumns: event.columns,
        isFreeFloating: false,
      ),
      event.canvasSize,
      rows: event.rows,
      cols: event.columns,
    );
    emit(current.copyWith(tabs: updatedTabs));
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  void _onFilterGlobalSearch(
    FilterGlobalSearchEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    emit(_loaded.copyWith(searchQuery: event.query));
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────

  WorkspaceTab _applyGridLayout(
    WorkspaceTab tab,
    Size canvasSize, {
    int? rows,
    int? cols,
  }) {
    final r = rows ?? tab.gridRows;
    final c = cols ?? tab.gridColumns;
    if (r <= 0 || c <= 0 || tab.windows.isEmpty) return tab;

    const spacing = 4.0;
    const padding = 4.0;

    final tileW = max(
        280.0, (canvasSize.width - padding * 2 - spacing * (c - 1)) / c);
    final tileH = max(
        340.0, (canvasSize.height - padding * 2 - spacing * (r - 1)) / r);

    final arranged = <WorkspaceWindow>[];
    for (int i = 0; i < tab.windows.length; i++) {
      arranged.add(tab.windows[i].copyWith(
        position: Offset(
          padding + (i % c) * (tileW + spacing),
          padding + (i ~/ c) * (tileH + spacing),
        ),
        size: Size(tileW, tileH),
        zIndex: i,
      ));
    }

    return tab.copyWith(
      windows: arranged,
      gridRows: r,
      gridColumns: c,
      isFreeFloating: false,
    );
  }
}
