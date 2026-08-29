import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/workspace/models/layout_mode.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_tab_model.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_widget_type.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_window_model.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_state.dart';
import 'package:stockbit_clone2/core/workspace/utils/magnetic_snap_helper.dart';

/// Central BLoC in core managing all workspace tabs, modular window instances,
/// layout modes (Fixed vs Scrollable), drag/drop, and grid calculations.
class WorkspaceBloc extends Bloc<WorkspaceEvent, WorkspaceState> {
  int _tabCounter = 1;
  int _windowCounter = 1;

  WorkspaceBloc() : super(const WorkspaceInitialState()) {
    on<InitializeWorkspaceEvent>(_onInitializeWorkspace);
    on<SelectWorkspaceTabEvent>(_onSelectWorkspaceTab);
    on<AddWorkspaceTabEvent>(_onAddWorkspaceTab);
    on<CloseWorkspaceTabEvent>(_onCloseWorkspaceTab);
    on<ToggleTabModeEvent>(_onToggleTabMode);
    on<SetActiveWindowEvent>(_onSetActiveWindow);
    on<ChangeWindowSymbolEvent>(_onChangeWindowSymbol);
    on<ResetWindowSlotEvent>(_onResetWindowSlot);
    on<MoveWindowEvent>(_onMoveWindow);
    on<SnapWindowOnReleaseEvent>(_onSnapWindowOnRelease);
    on<ResizeWindowEvent>(_onResizeWindow);
    on<SnapResizeOnReleaseEvent>(_onSnapResizeOnRelease);
    on<AddNewWindowToWorkspaceEvent>(_onAddNewWindowToWorkspace);
    on<RemoveWindowEvent>(_onRemoveWindow);
    on<AutoArrangeWindowsEvent>(_onAutoArrangeWindows);
    on<SetGridPresetEvent>(_onSetGridPreset);
    on<GlobalSearchSymbolEvent>(_onGlobalSearchSymbol);
    on<CreateTemplateLayoutEvent>(_onCreateTemplateLayout);
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  WorkspaceLoadedState get _loaded => state as WorkspaceLoadedState;
  bool get _isLoaded => state is WorkspaceLoadedState;

  void _mutateActiveTab(
    WorkspaceLoadedState current,
    Emitter<WorkspaceState> emit,
    WorkspaceTabModel Function(WorkspaceTabModel tab) mutate,
  ) {
    final updatedTabs = List<WorkspaceTabModel>.from(current.tabs);
    updatedTabs[current.activeTabIndex] = mutate(current.activeTab);
    emit(current.copyWith(tabs: updatedTabs, lastUpdated: DateTime.now()));
  }

  // ─── Handlers ───────────────────────────────────────────────────────────────

  void _onInitializeWorkspace(
    InitializeWorkspaceEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    final symbols = [
      'BBCA',
      'BBRI',
      'BMRI',
      'TLKM',
      'ASII',
      'BBNI',
      'MDKA',
      'AMMN',
    ];

    final multiOrderbookWindows = <WorkspaceWindowModel>[
      for (int i = 0; i < symbols.length; i++)
        WorkspaceWindowModel(
          id: 'win_${_windowCounter++}',
          type: WorkspaceWidgetType.orderbook,
          symbol: symbols[i],
          position: Offset(4 + (i % 4) * 354.0, 4 + (i ~/ 4) * 394.0),
          size: const Size(350, 390),
          zIndex: i,
        ),
    ];

    emit(
      WorkspaceLoadedState(
        tabs: [
          WorkspaceTabModel(
            id: 'tab_multi_orderbook',
            title: 'Multi Orderbook',
            layoutMode: LayoutMode.fixed,
            windows: multiOrderbookWindows,
            activeWindowId: multiOrderbookWindows.first.id,
            isFreeFloating: false,
            gridRows: 2,
            gridColumns: 4,
          ),
        ],
        activeTabIndex: 0,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  void _onSelectWorkspaceTab(
    SelectWorkspaceTabEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    if (event.tabIndex >= 0 && event.tabIndex < _loaded.tabs.length) {
      emit(_loaded.copyWith(activeTabIndex: event.tabIndex));
    }
  }

  void _onAddWorkspaceTab(
    AddWorkspaceTabEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    _tabCounter++;

    final newWindows = <WorkspaceWindowModel>[
      WorkspaceWindowModel(
        id: 'win_${_windowCounter++}',
        type: WorkspaceWidgetType.orderbook,
        symbol: 'ASII',
        position: const Offset(4, 4),
        size: const Size(500, 390),
        zIndex: 0,
      ),
      WorkspaceWindowModel(
        id: 'win_${_windowCounter++}',
        type: WorkspaceWidgetType.chart,
        symbol: 'ASII',
        position: const Offset(508, 4),
        size: const Size(500, 390),
        zIndex: 1,
      ),
      WorkspaceWindowModel(
        id: 'win_${_windowCounter++}',
        type: WorkspaceWidgetType.screener,
        symbol: 'BBNI',
        position: const Offset(4, 398),
        size: const Size(500, 390),
        zIndex: 2,
      ),
      WorkspaceWindowModel(
        id: 'win_${_windowCounter++}',
        type: WorkspaceWidgetType.portfolio,
        symbol: 'PORTFOLIO',
        position: const Offset(508, 398),
        size: const Size(500, 390),
        zIndex: 3,
      ),
    ];

    final newTab = WorkspaceTabModel(
      id: 'tab_$_tabCounter',
      title: '${event.title} #$_tabCounter',
      layoutMode: event.layoutMode,
      windows: newWindows,
      activeWindowId: newWindows.first.id,
      isFreeFloating: false,
      gridRows: 2,
      gridColumns: 2,
    );

    final updatedTabs = List<WorkspaceTabModel>.from(current.tabs)..add(newTab);
    emit(
      current.copyWith(
        tabs: updatedTabs,
        activeTabIndex: updatedTabs.length - 1,
      ),
    );
  }

  void _onCloseWorkspaceTab(
    CloseWorkspaceTabEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    if (current.tabs.length <= 1) return;

    final updatedTabs = List<WorkspaceTabModel>.from(current.tabs)
      ..removeAt(event.tabIndex);
    final newIndex = current.activeTabIndex.clamp(0, updatedTabs.length - 1);
    emit(current.copyWith(tabs: updatedTabs, activeTabIndex: newIndex));
  }

  void _onToggleTabMode(
    ToggleTabModeEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final currentMode = current.activeTab.layoutMode;
    final nextMode = currentMode == LayoutMode.fixed
        ? LayoutMode.scrollable
        : LayoutMode.fixed;

    _mutateActiveTab(current, emit, (tab) {
      return tab.copyWith(layoutMode: nextMode);
    });
  }

  void _onSetActiveWindow(
    SetActiveWindowEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final maxZ = current.activeTab.windows.fold(0, (m, w) => max(m, w.zIndex));

    _mutateActiveTab(
      current,
      emit,
      (tab) => tab.copyWith(
        activeWindowId: event.windowId,
        windows: tab.windows.map((w) {
          return w.id == event.windowId ? w.copyWith(zIndex: maxZ + 1) : w;
        }).toList(),
      ),
    );
  }

  void _onChangeWindowSymbol(
    ChangeWindowSymbolEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final sym = event.newSymbol.trim().toUpperCase();
    if (sym.isEmpty) return;

    _mutateActiveTab(
      _loaded,
      emit,
      (tab) => tab.copyWith(
        activeWindowId: event.windowId,
        windows: tab.windows.map((w) {
          return w.id == event.windowId ? w.copyWith(symbol: sym) : w;
        }).toList(),
      ),
    );
  }

  void _onResetWindowSlot(
    ResetWindowSlotEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    _mutateActiveTab(
      _loaded,
      emit,
      (tab) => tab.copyWith(
        windows: tab.windows.map((w) {
          return w.id == event.windowId ? w.copyWith(symbol: 'BBRI') : w;
        }).toList(),
      ),
    );
  }

  void _onMoveWindow(MoveWindowEvent event, Emitter<WorkspaceState> emit) {
    if (!_isLoaded) return;
    final current = _loaded;
    final maxZ = current.activeTab.windows.fold(0, (m, w) => max(m, w.zIndex));

    _mutateActiveTab(current, emit, (tab) {
      return tab.copyWith(
        activeWindowId: event.windowId,
        isFreeFloating: true,
        windows: tab.windows.map((w) {
          if (w.id != event.windowId) return w;
          final newDx = (w.position.dx + event.delta.dx)
              .clamp(0.0, max(0.0, event.canvasSize.width - 60))
              .toDouble();
          final maxY = max(0.0, event.canvasSize.height - 40);
          final newDy = (w.position.dy + event.delta.dy)
              .clamp(0.0, maxY)
              .toDouble();

          return w.copyWith(zIndex: maxZ + 1, position: Offset(newDx, newDy));
        }).toList(),
      );
    });
  }

  void _onSnapWindowOnRelease(
    SnapWindowOnReleaseEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final activeTab = current.activeTab;
    final targetWindow = activeTab.windows.firstWhere(
      (w) => w.id == event.windowId,
      orElse: () => activeTab.windows.first,
    );
    final isScrollable = activeTab.layoutMode == LayoutMode.scrollable;

    final snappedOffset = MagneticSnapHelper.calculateSnap(
      activeWindowId: event.windowId,
      targetPosition: targetWindow.position,
      windowSize: targetWindow.size,
      otherWindows: activeTab.windows,
      canvasSize: event.canvasSize,
      isScrollable: isScrollable,
    );

    _mutateActiveTab(current, emit, (tab) {
      return tab.copyWith(
        windows: tab.windows.map((w) {
          return w.id == event.windowId
              ? w.copyWith(position: snappedOffset)
              : w;
        }).toList(),
      );
    });
  }

  void _onResizeWindow(ResizeWindowEvent event, Emitter<WorkspaceState> emit) {
    if (!_isLoaded) return;
    _mutateActiveTab(
      _loaded,
      emit,
      (tab) => tab.copyWith(
        windows: tab.windows.map((w) {
          if (w.id != event.windowId) return w;
          return w.copyWith(
            size: event.newSize,
            position: event.newPosition ?? w.position,
          );
        }).toList(),
      ),
    );
  }

  void _onSnapResizeOnRelease(
    SnapResizeOnReleaseEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final activeTab = current.activeTab;
    final targetWindow = activeTab.windows.firstWhere(
      (w) => w.id == event.windowId,
      orElse: () => activeTab.windows.first,
    );

    final snapResult = MagneticSnapHelper.calculateResizeSnap(
      activeWindowId: event.windowId,
      position: targetWindow.position,
      targetSize: targetWindow.size,
      otherWindows: activeTab.windows,
      canvasSize: event.canvasSize,
    );

    _mutateActiveTab(current, emit, (tab) {
      return tab.copyWith(
        windows: tab.windows.map((w) {
          if (w.id != event.windowId) return w;
          return w.copyWith(
            size: snapResult.size,
            position: snapResult.position,
          );
        }).toList(),
      );
    });
  }

  void _onAddNewWindowToWorkspace(
    AddNewWindowToWorkspaceEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final maxZ = current.activeTab.windows.fold(0, (m, w) => max(m, w.zIndex));
    final offset = (current.activeTab.windows.length * 30.0) % 200;

    final newWindow = WorkspaceWindowModel(
      id: 'win_${_windowCounter++}',
      type: event.type,
      symbol: event.symbol.toUpperCase(),
      position: Offset(40 + offset, 40 + offset),
      size: const Size(360, 400),
      zIndex: maxZ + 1,
    );

    _mutateActiveTab(
      current,
      emit,
      (tab) => tab.copyWith(
        activeWindowId: newWindow.id,
        windows: [...tab.windows, newWindow],
      ),
    );
  }

  void _onRemoveWindow(RemoveWindowEvent event, Emitter<WorkspaceState> emit) {
    if (!_isLoaded) return;
    final current = _loaded;
    _mutateActiveTab(current, emit, (tab) {
      final remaining = tab.windows
          .where((w) => w.id != event.windowId)
          .toList();
      return tab.copyWith(
        windows: remaining,
        activeWindowId: remaining.isNotEmpty ? remaining.last.id : null,
      );
    });
  }

  void _onAutoArrangeWindows(
    AutoArrangeWindowsEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final tab = current.activeTab;
    if (tab.windows.isEmpty) return;

    const spacing = 4.0;
    const padding = 4.0;
    final canvasWidth = event.canvasSize.width > 100
        ? event.canvasSize.width
        : 1920.0;

    double currentX = padding;
    double currentY = padding;
    double rowMaxHeight = 0.0;

    final arranged = <WorkspaceWindowModel>[];

    for (int i = 0; i < tab.windows.length; i++) {
      final win = tab.windows[i];
      final winW = win.size.width;
      final winH = win.size.height;

      // Wrap to next line if placing this window overflows canvas width (and not first in row)
      if (currentX + winW + padding > canvasWidth && currentX > padding) {
        currentX = padding;
        currentY += rowMaxHeight + spacing;
        rowMaxHeight = 0.0;
      }

      arranged.add(
        win.copyWith(position: Offset(currentX, currentY), zIndex: i),
      );

      currentX += winW + spacing;
      rowMaxHeight = max(rowMaxHeight, winH);
    }

    _mutateActiveTab(
      current,
      emit,
      (t) => t.copyWith(windows: arranged, isFreeFloating: true),
    );
  }

  void _onSetGridPreset(
    SetGridPresetEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final updatedTabs = List<WorkspaceTabModel>.from(current.tabs);
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

  void _onGlobalSearchSymbol(
    GlobalSearchSymbolEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final sym = event.query.trim().toUpperCase();
    if (sym.isEmpty) return;

    final activeWin = current.activeWindow;
    if (activeWin != null) {
      _mutateActiveTab(
        current,
        emit,
        (tab) => tab.copyWith(
          windows: tab.windows.map((w) {
            return w.id == activeWin.id ? w.copyWith(symbol: sym) : w;
          }).toList(),
        ),
      );
    }
  }

  void _onCreateTemplateLayout(
    CreateTemplateLayoutEvent event,
    Emitter<WorkspaceState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final tabTitle = event.template.title;

    final generatedWindows = <WorkspaceWindowModel>[];
    int rows = 2;
    int cols = 4;

    switch (event.template) {
      case WorkspaceLayoutTemplate.newLayout:
        generatedWindows.add(
          WorkspaceWindowModel(
            id: 'win_${_windowCounter++}',
            type: WorkspaceWidgetType.orderbook,
            symbol: 'BBCA',
            position: const Offset(8, 8),
            size: const Size(420, 480),
            zIndex: 0,
          ),
        );
        rows = 1;
        cols = 1;
        break;

      case WorkspaceLayoutTemplate.multiOrderbook:
        final symbols = [
          'BBCA',
          'BBRI',
          'BMRI',
          'TLKM',
          'ASII',
          'BBNI',
          'MDKA',
          'AMMN',
        ];
        for (int i = 0; i < symbols.length; i++) {
          generatedWindows.add(
            WorkspaceWindowModel(
              id: 'win_${_windowCounter++}',
              type: WorkspaceWidgetType.orderbook,
              symbol: symbols[i],
              position: const Offset(8, 8),
              size: const Size(320, 380),
              zIndex: i,
            ),
          );
        }
        rows = 2;
        cols = 4;
        break;

      case WorkspaceLayoutTemplate.multiChart:
        final symbols = ['BBCA', 'BBRI', 'BMRI', 'TLKM'];
        for (int i = 0; i < symbols.length; i++) {
          generatedWindows.add(
            WorkspaceWindowModel(
              id: 'win_${_windowCounter++}',
              type: WorkspaceWidgetType.chart,
              symbol: symbols[i],
              position: const Offset(8, 8),
              size: const Size(540, 380),
              zIndex: i,
            ),
          );
        }
        rows = 2;
        cols = 2;
        break;

      case WorkspaceLayoutTemplate.classic:
        generatedWindows.addAll([
          WorkspaceWindowModel(
            id: 'win_${_windowCounter++}',
            type: WorkspaceWidgetType.watchlist,
            symbol: 'BBCA',
            position: const Offset(8, 8),
            size: const Size(300, 520),
            zIndex: 0,
          ),
          WorkspaceWindowModel(
            id: 'win_${_windowCounter++}',
            type: WorkspaceWidgetType.chart,
            symbol: 'BBCA',
            position: const Offset(312, 8),
            size: const Size(560, 260),
            zIndex: 1,
          ),
          WorkspaceWindowModel(
            id: 'win_${_windowCounter++}',
            type: WorkspaceWidgetType.orderbook,
            symbol: 'BBCA',
            position: const Offset(312, 272),
            size: const Size(560, 260),
            zIndex: 2,
          ),
        ]);
        rows = 2;
        cols = 2;
        break;

      case WorkspaceLayoutTemplate.multiStock:
        final pairs = [
          (WorkspaceWidgetType.orderbook, 'BBCA'),
          (WorkspaceWidgetType.chart, 'BBCA'),
          (WorkspaceWidgetType.orderbook, 'BBRI'),
          (WorkspaceWidgetType.chart, 'BBRI'),
        ];
        for (int i = 0; i < pairs.length; i++) {
          generatedWindows.add(
            WorkspaceWindowModel(
              id: 'win_${_windowCounter++}',
              type: pairs[i].$1,
              symbol: pairs[i].$2,
              position: const Offset(8, 8),
              size: const Size(400, 360),
              zIndex: i,
            ),
          );
        }
        rows = 2;
        cols = 2;
        break;

      case WorkspaceLayoutTemplate.singleStock:
        generatedWindows.addAll([
          WorkspaceWindowModel(
            id: 'win_${_windowCounter++}',
            type: WorkspaceWidgetType.chart,
            symbol: 'BBCA',
            position: const Offset(8, 8),
            size: const Size(600, 380),
            zIndex: 0,
          ),
          WorkspaceWindowModel(
            id: 'win_${_windowCounter++}',
            type: WorkspaceWidgetType.orderbook,
            symbol: 'BBCA',
            position: const Offset(612, 8),
            size: const Size(380, 380),
            zIndex: 1,
          ),
          WorkspaceWindowModel(
            id: 'win_${_windowCounter++}',
            type: WorkspaceWidgetType.brokerSummary,
            symbol: 'BBCA',
            position: const Offset(8, 392),
            size: const Size(984, 280),
            zIndex: 2,
          ),
        ]);
        rows = 2;
        cols = 2;
        break;

      case WorkspaceLayoutTemplate.fastOrder:
        generatedWindows.addAll([
          WorkspaceWindowModel(
            id: 'win_${_windowCounter++}',
            type: WorkspaceWidgetType.orderbook,
            symbol: 'BBCA',
            position: const Offset(8, 8),
            size: const Size(450, 480),
            zIndex: 0,
          ),
          WorkspaceWindowModel(
            id: 'win_${_windowCounter++}',
            type: WorkspaceWidgetType.orderbook,
            symbol: 'BBRI',
            position: const Offset(462, 8),
            size: const Size(450, 480),
            zIndex: 1,
          ),
        ]);
        rows = 1;
        cols = 2;
        break;
    }

    var newTab = WorkspaceTabModel(
      id: 'tab_${_tabCounter++}',
      title: tabTitle,
      windows: generatedWindows,
      activeWindowId: generatedWindows.isNotEmpty
          ? generatedWindows.first.id
          : null,
      gridRows: rows,
      gridColumns: cols,
      layoutMode: LayoutMode.scrollable,
      isFreeFloating: event.template == WorkspaceLayoutTemplate.classic,
    );

    if (event.template != WorkspaceLayoutTemplate.classic &&
        generatedWindows.isNotEmpty) {
      newTab = _applyGridLayout(
        newTab,
        event.canvasSize,
        rows: rows,
        cols: cols,
      );
    }

    final newTabs = [...current.tabs, newTab];
    emit(current.copyWith(tabs: newTabs, activeTabIndex: newTabs.length - 1));
  }

  WorkspaceTabModel _applyGridLayout(
    WorkspaceTabModel tab,
    Size canvasSize, {
    int? rows,
    int? cols,
  }) {
    final r = rows ?? tab.gridRows;
    final c = cols ?? tab.gridColumns;
    if (r <= 0 || c <= 0 || tab.windows.isEmpty) return tab;

    const spacing = 4.0;
    const padding = 4.0;

    final isScrollable = tab.layoutMode == LayoutMode.scrollable;
    final availableW = canvasSize.width > 200 ? canvasSize.width : 1280.0;
    final availableH = canvasSize.height > 200 ? canvasSize.height : 720.0;

    final computedW = (availableW - padding * 2 - spacing * (c - 1)) / c;
    final computedH = (availableH - padding * 2 - spacing * (r - 1)) / r;

    final tileW = max(180.0, computedW);
    final tileH = isScrollable ? 340.0 : max(160.0, computedH);

    final arranged = <WorkspaceWindowModel>[];
    for (int i = 0; i < tab.windows.length; i++) {
      arranged.add(
        tab.windows[i].copyWith(
          position: Offset(
            padding + (i % c) * (tileW + spacing),
            padding + (i ~/ c) * (tileH + spacing),
          ),
          size: Size(tileW, tileH),
          zIndex: i,
        ),
      );
    }

    return tab.copyWith(
      windows: arranged,
      gridRows: r,
      gridColumns: c,
      isFreeFloating: false,
    );
  }
}
