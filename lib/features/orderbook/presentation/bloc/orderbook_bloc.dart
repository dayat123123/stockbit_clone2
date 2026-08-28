import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/usecase/usecase.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_data.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_window_item.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/workspace_tab.dart';
import 'package:stockbit_clone2/features/orderbook/domain/usecases/get_multi_orderbooks_usecase.dart';
import 'package:stockbit_clone2/features/orderbook/domain/usecases/get_orderbook_by_symbol_usecase.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_event.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_state.dart';

class OrderbookBloc extends Bloc<OrderbookEvent, OrderbookState> {
  final GetMultiOrderbooksUseCase getMultiOrderbooksUseCase;
  final GetOrderbookBySymbolUseCase getOrderbookBySymbolUseCase;

  int _tabCounter = 1;
  int _windowCounter = 1;

  OrderbookBloc({
    required this.getMultiOrderbooksUseCase,
    required this.getOrderbookBySymbolUseCase,
  }) : super(const OrderbookInitialState()) {
    on<LoadMultiOrderbooksEvent>(_onLoadMultiOrderbooks);
    on<RefreshMultiOrderbooksEvent>(_onRefreshMultiOrderbooks);
    // Tabs
    on<SelectWorkspaceTabEvent>(_onSelectWorkspaceTab);
    on<AddWorkspaceTabEvent>(_onAddWorkspaceTab);
    on<CloseWorkspaceTabEvent>(_onCloseWorkspaceTab);
    // Windows
    on<SetActiveWindowEvent>(_onSetActiveWindow);
    on<MoveWindowEvent>(_onMoveWindow);
    on<ResizeWindowEvent>(_onResizeWindow);
    on<AddNewWindowToWorkspaceEvent>(_onAddNewWindowToWorkspace);
    on<RemoveWindowEvent>(_onRemoveWindow);
    on<ChangeWindowSymbolEvent>(_onChangeWindowSymbol);
    // Layout
    on<ToggleLayoutModeEvent>(_onToggleLayoutMode);
    on<AutoArrangeWindowsEvent>(_onAutoArrangeWindows);
    on<SetGridPresetEvent>(_onSetGridPreset);
    // Search
    on<FilterGlobalSearchEvent>(_onFilterGlobalSearch);
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  OrderbookLoadedState get _loaded => state as OrderbookLoadedState;
  bool get _isLoaded => state is OrderbookLoadedState;

  /// Applies a mutation to the active tab's windows and emits the new state.
  void _mutateActiveTab(
    OrderbookLoadedState current,
    Emitter<OrderbookState> emit,
    WorkspaceTab Function(WorkspaceTab tab) mutate,
  ) {
    final updatedTabs = List<WorkspaceTab>.from(current.tabs);
    updatedTabs[current.activeTabIndex] = mutate(current.activeTab);
    emit(current.copyWith(tabs: updatedTabs));
  }

  // ─── Data Loading ────────────────────────────────────────────────────────────

  Future<void> _onLoadMultiOrderbooks(
    LoadMultiOrderbooksEvent _,
    Emitter<OrderbookState> emit,
  ) async {
    emit(const OrderbookLoadingState());
    final result = await getMultiOrderbooksUseCase(const NoParams());
    result.fold(
      (failure) => emit(OrderbookErrorState(message: failure.message)),
      (data) {
        final windows = <OrderbookWindowItem>[
          for (int i = 0; i < 8; i++)
            OrderbookWindowItem(
              id: 'win_${_windowCounter++}',
              orderbook: i < data.length ? data[i] : null,
              position: Offset((i % 4) * 354.0 + 4, (i ~/ 4) * 394.0 + 4),
              size: const Size(350, 390),
              zIndex: i,
            ),
        ];

        emit(OrderbookLoadedState(
          tabs: [
            WorkspaceTab(
              id: 'tab_1',
              title: 'Multi-orderbook',
              windows: windows,
              activeWindowId: windows.first.id,
              isFreeFloating: false,
              gridRows: 2,
              gridColumns: 4,
            ),
          ],
          activeTabIndex: 0,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onRefreshMultiOrderbooks(
    RefreshMultiOrderbooksEvent _,
    Emitter<OrderbookState> emit,
  ) async {
    if (!_isLoaded) return;
    emit(_loaded.copyWith(lastUpdated: DateTime.now()));
  }

  // ─── Tab Management ──────────────────────────────────────────────────────────

  void _onSelectWorkspaceTab(
    SelectWorkspaceTabEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    if (event.tabIndex >= 0 && event.tabIndex < current.tabs.length) {
      emit(current.copyWith(activeTabIndex: event.tabIndex));
    }
  }

  Future<void> _onAddWorkspaceTab(
    AddWorkspaceTabEvent event,
    Emitter<OrderbookState> emit,
  ) async {
    if (!_isLoaded) return;
    final current = _loaded;
    _tabCounter++;

    final result = await getMultiOrderbooksUseCase(const NoParams());
    final List<OrderbookData> allData = result.dataOrNull ?? [];

    final newWindows = <OrderbookWindowItem>[
      for (int i = 0; i < 4; i++)
        OrderbookWindowItem(
          id: 'win_${_windowCounter++}',
          orderbook: i < allData.length ? allData[i] : null,
          position: Offset((i % 2) * 354.0 + 4, (i ~/ 2) * 394.0 + 4),
          size: const Size(350, 390),
          zIndex: i,
        ),
    ];

    final newTab = WorkspaceTab(
      id: 'tab_$_tabCounter',
      title: '${event.title} #$_tabCounter',
      windows: newWindows,
      activeWindowId: newWindows.first.id,
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

  void _onCloseWorkspaceTab(
    CloseWorkspaceTabEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    if (current.tabs.length <= 1) return;

    final updatedTabs = List<WorkspaceTab>.from(current.tabs)..removeAt(event.tabIndex);
    final newIndex = current.activeTabIndex.clamp(0, updatedTabs.length - 1);
    emit(current.copyWith(tabs: updatedTabs, activeTabIndex: newIndex));
  }

  // ─── Window Focus ────────────────────────────────────────────────────────────

  void _onSetActiveWindow(
    SetActiveWindowEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final maxZ = current.activeTab.windows.fold(0, (m, w) => max(m, w.zIndex));

    _mutateActiveTab(current, emit, (tab) => tab.copyWith(
      activeWindowId: event.windowId,
      windows: tab.windows.map((w) {
        return w.id == event.windowId ? w.copyWith(zIndex: maxZ + 1) : w;
      }).toList(),
    ));
  }

  // ─── Window Drag (called by CanvasDragController) ────────────────────────────

  void _onMoveWindow(
    MoveWindowEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    final maxZ = current.activeTab.windows.fold(0, (m, w) => max(m, w.zIndex));

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

  // ─── Resize ──────────────────────────────────────────────────────────────────

  void _onResizeWindow(
    ResizeWindowEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (!_isLoaded) return;
    _mutateActiveTab(_loaded, emit, (tab) => tab.copyWith(
      windows: tab.windows.map((w) {
        return w.id == event.windowId ? w.copyWith(size: event.newSize) : w;
      }).toList(),
    ));
  }

  // ─── Window CRUD ─────────────────────────────────────────────────────────────

  Future<void> _onAddNewWindowToWorkspace(
    AddNewWindowToWorkspaceEvent event,
    Emitter<OrderbookState> emit,
  ) async {
    if (!_isLoaded) return;
    final current = _loaded;
    final maxZ = current.activeTab.windows.fold(0, (m, w) => max(m, w.zIndex));

    OrderbookData? data;
    if (event.symbol != null) {
      final res = await getOrderbookBySymbolUseCase(
          GetOrderbookParams(symbol: event.symbol!));
      data = res.dataOrNull;
    }

    final offset = (current.activeTab.windows.length * 30.0) % 200;
    final newWindow = OrderbookWindowItem(
      id: 'win_${_windowCounter++}',
      orderbook: data,
      position: Offset(40 + offset, 40 + offset),
      size: const Size(350, 390),
      zIndex: maxZ + 1,
    );

    _mutateActiveTab(current, emit, (tab) => tab.copyWith(
      activeWindowId: newWindow.id,
      windows: [...tab.windows, newWindow],
    ));
  }

  void _onRemoveWindow(
    RemoveWindowEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (!_isLoaded) return;
    final current = _loaded;
    _mutateActiveTab(current, emit, (tab) {
      final remaining = tab.windows.where((w) => w.id != event.windowId).toList();
      return tab.copyWith(
        windows: remaining,
        activeWindowId: remaining.isNotEmpty ? remaining.last.id : null,
      );
    });
  }

  Future<void> _onChangeWindowSymbol(
    ChangeWindowSymbolEvent event,
    Emitter<OrderbookState> emit,
  ) async {
    if (!_isLoaded) return;
    final current = _loaded;
    final res = await getOrderbookBySymbolUseCase(
        GetOrderbookParams(symbol: event.newSymbol));

    res.fold((_) {}, (data) {
      _mutateActiveTab(current, emit, (tab) => tab.copyWith(
        activeWindowId: event.windowId,
        windows: tab.windows.map((w) {
          return w.id == event.windowId ? w.copyWith(orderbook: data) : w;
        }).toList(),
      ));
    });
  }

  // ─── Layout ──────────────────────────────────────────────────────────────────

  void _onToggleLayoutMode(
    ToggleLayoutModeEvent _,
    Emitter<OrderbookState> emit,
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
    Emitter<OrderbookState> emit,
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
    Emitter<OrderbookState> emit,
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

  // ─── Search ──────────────────────────────────────────────────────────────────

  void _onFilterGlobalSearch(
    FilterGlobalSearchEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (!_isLoaded) return;
    emit(_loaded.copyWith(searchQuery: event.query));
  }

  // ─── Private Helpers ─────────────────────────────────────────────────────────

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

    final tileW = max(280.0,
        (canvasSize.width - padding * 2 - spacing * (c - 1)) / c);
    final tileH = max(340.0,
        (canvasSize.height - padding * 2 - spacing * (r - 1)) / r);

    final arranged = <OrderbookWindowItem>[];
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
