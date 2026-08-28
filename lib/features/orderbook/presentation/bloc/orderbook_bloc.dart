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
    on<SelectWorkspaceTabEvent>(_onSelectWorkspaceTab);
    on<AddWorkspaceTabEvent>(_onAddWorkspaceTab);
    on<CloseWorkspaceTabEvent>(_onCloseWorkspaceTab);
    on<SetActiveWindowEvent>(_onSetActiveWindow);
    on<StartDragWindowEvent>(_onStartDragWindow);
    on<MoveWindowEvent>(_onMoveWindow);
    on<EndDragWindowEvent>(_onEndDragWindow);
    on<SetWindowPositionEvent>(_onSetWindowPosition);
    on<ResizeWindowEvent>(_onResizeWindow);
    on<ToggleLayoutModeEvent>(_onToggleLayoutMode);
    on<AutoArrangeWindowsEvent>(_onAutoArrangeWindows);
    on<SetGridPresetEvent>(_onSetGridPreset);
    on<ChangeWindowSymbolEvent>(_onChangeWindowSymbol);
    on<AddNewWindowToWorkspaceEvent>(_onAddNewWindowToWorkspace);
    on<RemoveWindowEvent>(_onRemoveWindow);
    on<SwapWindowPositionsEvent>(_onSwapWindowPositions);
    on<FilterGlobalSearchEvent>(_onFilterGlobalSearch);
    on<FilterOrderbooksEvent>(_onFilterOrderbooks);
  }

  Future<void> _onLoadMultiOrderbooks(
    LoadMultiOrderbooksEvent event,
    Emitter<OrderbookState> emit,
  ) async {
    emit(const OrderbookLoadingState());
    final result = await getMultiOrderbooksUseCase(const NoParams());

    result.fold(
      (failure) => emit(OrderbookErrorState(message: failure.message)),
      (data) {
        // Tab 1: Default Multi-orderbook (8 windows matching the screenshot)
        final defaultWindows = <OrderbookWindowItem>[];
        const defaultSize = Size(350, 390);

        for (int i = 0; i < 8; i++) {
          final orderbookData = i < data.length ? data[i] : null;
          final row = i ~/ 4;
          final col = i % 4;

          defaultWindows.add(
            OrderbookWindowItem(
              id: 'win_${_windowCounter++}',
              orderbook: orderbookData,
              position: Offset(col * 354.0 + 4, row * 394.0 + 4),
              size: defaultSize,
              zIndex: i,
            ),
          );
        }

        final initialTab = WorkspaceTab(
          id: 'tab_1',
          title: 'Multi-orderbook',
          windows: defaultWindows,
          activeWindowId: defaultWindows.isNotEmpty
              ? defaultWindows.first.id
              : null,
          isFreeFloating: false,
          gridRows: 2,
          gridColumns: 4,
        );

        emit(
          OrderbookLoadedState(
            tabs: [initialTab],
            activeTabIndex: 0,
            lastUpdated: DateTime.now(),
          ),
        );
      },
    );
  }

  Future<void> _onRefreshMultiOrderbooks(
    RefreshMultiOrderbooksEvent event,
    Emitter<OrderbookState> emit,
  ) async {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      emit(current.copyWith(lastUpdated: DateTime.now()));
    }
  }

  void _onSelectWorkspaceTab(
    SelectWorkspaceTabEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      if (event.tabIndex >= 0 && event.tabIndex < current.tabs.length) {
        emit(current.copyWith(activeTabIndex: event.tabIndex));
      }
    }
  }

  Future<void> _onAddWorkspaceTab(
    AddWorkspaceTabEvent event,
    Emitter<OrderbookState> emit,
  ) async {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      _tabCounter++;

      final result = await getMultiOrderbooksUseCase(const NoParams());
      final List<OrderbookData> allData = result.dataOrNull ?? [];

      final newWindows = <OrderbookWindowItem>[];
      const defaultSize = Size(350, 390);

      for (int i = 0; i < 4; i++) {
        final data = i < allData.length ? allData[i] : null;
        final col = i % 2;
        final row = i ~/ 2;

        newWindows.add(
          OrderbookWindowItem(
            id: 'win_${_windowCounter++}',
            orderbook: data,
            position: Offset(col * 354.0 + 4, row * 394.0 + 4),
            size: defaultSize,
            zIndex: i,
          ),
        );
      }

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
      emit(
        current.copyWith(
          tabs: updatedTabs,
          activeTabIndex: updatedTabs.length - 1,
        ),
      );
    }
  }

  void _onCloseWorkspaceTab(
    CloseWorkspaceTabEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      if (current.tabs.length <= 1) return; // Keep at least 1 tab

      final updatedTabs = List<WorkspaceTab>.from(current.tabs)
        ..removeAt(event.tabIndex);
      var newIndex = current.activeTabIndex;
      if (newIndex >= updatedTabs.length) {
        newIndex = updatedTabs.length - 1;
      }

      emit(current.copyWith(tabs: updatedTabs, activeTabIndex: newIndex));
    }
  }

  void _onSetActiveWindow(
    SetActiveWindowEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final activeTab = current.activeTab;

      int maxZ = 0;
      for (final w in activeTab.windows) {
        maxZ = max(maxZ, w.zIndex);
      }

      final updatedWindows = activeTab.windows.map((w) {
        if (w.id == event.windowId) {
          return w.copyWith(zIndex: maxZ + 1);
        }
        return w;
      }).toList();

      final updatedTab = activeTab.copyWith(
        windows: updatedWindows,
        activeWindowId: event.windowId,
      );

      final updatedTabs = List<WorkspaceTab>.from(current.tabs);
      updatedTabs[current.activeTabIndex] = updatedTab;

      emit(current.copyWith(tabs: updatedTabs));
    }
  }

  void _onStartDragWindow(
    StartDragWindowEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final activeTab = current.activeTab;

      int maxZ = 0;
      for (final w in activeTab.windows) {
        maxZ = max(maxZ, w.zIndex);
      }

      final updatedWindows = activeTab.windows.map((w) {
        if (w.id == event.windowId) {
          return w.copyWith(zIndex: maxZ + 1, isDragging: true);
        }
        return w;
      }).toList();

      final updatedTab = activeTab.copyWith(
        windows: updatedWindows,
        activeWindowId: event.windowId,
        isFreeFloating: true,
      );

      final updatedTabs = List<WorkspaceTab>.from(current.tabs);
      updatedTabs[current.activeTabIndex] = updatedTab;

      emit(current.copyWith(tabs: updatedTabs));
    }
  }

  void _onMoveWindow(MoveWindowEvent event, Emitter<OrderbookState> emit) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final activeTab = current.activeTab;

      final currentWindow = activeTab.windows.firstWhere(
        (w) => w.id == event.windowId,
        orElse: () => activeTab.windows.first,
      );

      // 1. Raw Fluid Movement (1:1 with mouse, zero lag)
      final rawX = (currentWindow.position.dx + event.delta.dx).clamp(
        0.0,
        max(0.0, event.canvasSize.width - 60),
      );
      final rawY = (currentWindow.position.dy + event.delta.dy).clamp(
        0.0,
        max(0.0, event.canvasSize.height - 40),
      );

      final tentativePosition = Offset(rawX.toDouble(), rawY.toDouble());

      // 2. Conditional Magnetic Snap Logic
      Offset finalPosition = tentativePosition;
      Rect? snapGuide;

      final bool isSnapActive = event.enableMagneticSnap;
      if (isSnapActive) {
        // Gunakan threshold yang sama (misal 38.0)
        const double snapThreshold = 38.0;

        snapGuide = _findNearestSnapSlot(
          window: currentWindow,
          position: tentativePosition,
          canvasSize: event.canvasSize,
          gridRows: activeTab.gridRows,
          gridCols: activeTab.gridColumns,
          threshold: snapThreshold,
        );

        if (snapGuide != null) {
          final slotPos = Offset(snapGuide.left, snapGuide.top);
          final dist = (tentativePosition - slotPos).distance;

          // Jika masuk dalam jangkauan snapThreshold, langsung tarik/nempel ke posisi slot
          if (dist < snapThreshold) {
            finalPosition = slotPos;
          }
        }
      }

      final updatedWindows = activeTab.windows.map((w) {
        if (w.id == event.windowId) {
          return w.copyWith(position: finalPosition, isDragging: true);
        }
        return w;
      }).toList();

      final updatedTab = activeTab.copyWith(
        windows: updatedWindows,
        activeWindowId: event.windowId,
        isFreeFloating: true,
      );

      final updatedTabs = List<WorkspaceTab>.from(current.tabs);
      updatedTabs[current.activeTabIndex] = updatedTab;

      emit(
        current.copyWith(
          tabs: updatedTabs,
          magneticSnapGuide: isSnapActive ? snapGuide : null,
        ),
      );
    }
  }

  void _onEndDragWindow(
    EndDragWindowEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final activeTab = current.activeTab;

      final currentWindow = activeTab.windows.firstWhere(
        (w) => w.id == event.windowId,
        orElse: () => activeTab.windows.first,
      );

      // Check if within snap range upon release (smooth glide into neat slot)
      final nearestSlot = _findNearestSnapSlot(
        window: currentWindow,
        position: currentWindow.position,
        canvasSize: event.canvasSize,
        gridRows: activeTab.gridRows,
        gridCols: activeTab.gridColumns,
        threshold: 45.0,
      );

      Offset targetPosition = currentWindow.position;
      if (nearestSlot != null) {
        targetPosition = Offset(nearestSlot.left, nearestSlot.top);
      }

      final updatedWindows = activeTab.windows.map((w) {
        if (w.id == event.windowId) {
          return w.copyWith(position: targetPosition, isDragging: false);
        }
        return w.copyWith(isDragging: false);
      }).toList();

      final updatedTab = activeTab.copyWith(windows: updatedWindows);
      final updatedTabs = List<WorkspaceTab>.from(current.tabs);
      updatedTabs[current.activeTabIndex] = updatedTab;

      emit(current.copyWith(tabs: updatedTabs, clearMagneticSnapGuide: true));
    }
  }

  void _onSetWindowPosition(
    SetWindowPositionEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final activeTab = current.activeTab;

      final updatedWindows = activeTab.windows.map((w) {
        if (w.id == event.windowId) {
          return w.copyWith(position: event.newPosition);
        }
        return w;
      }).toList();

      final updatedTab = activeTab.copyWith(windows: updatedWindows);
      final updatedTabs = List<WorkspaceTab>.from(current.tabs);
      updatedTabs[current.activeTabIndex] = updatedTab;

      emit(current.copyWith(tabs: updatedTabs));
    }
  }

  void _onResizeWindow(ResizeWindowEvent event, Emitter<OrderbookState> emit) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final activeTab = current.activeTab;

      final updatedWindows = activeTab.windows.map((w) {
        if (w.id == event.windowId) {
          return w.copyWith(size: event.newSize);
        }
        return w;
      }).toList();

      final updatedTab = activeTab.copyWith(windows: updatedWindows);
      final updatedTabs = List<WorkspaceTab>.from(current.tabs);
      updatedTabs[current.activeTabIndex] = updatedTab;

      emit(current.copyWith(tabs: updatedTabs));
    }
  }

  void _onToggleLayoutMode(
    ToggleLayoutModeEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final activeTab = current.activeTab;
      final newMode = !activeTab.isFreeFloating;

      var updatedTab = activeTab.copyWith(isFreeFloating: newMode);

      // If switching to Grid mode (Rapih), automatically rearrange
      if (!newMode) {
        updatedTab = _calculateGridArrangement(
          updatedTab,
          const Size(1440, 820),
          updatedTab.gridRows,
          updatedTab.gridColumns,
        );
      }

      final updatedTabs = List<WorkspaceTab>.from(current.tabs);
      updatedTabs[current.activeTabIndex] = updatedTab;

      emit(current.copyWith(tabs: updatedTabs));
    }
  }

  void _onAutoArrangeWindows(
    AutoArrangeWindowsEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final activeTab = current.activeTab;

      final updatedTab = _calculateGridArrangement(
        activeTab.copyWith(isFreeFloating: false),
        event.canvasSize,
        activeTab.gridRows,
        activeTab.gridColumns,
      );

      final updatedTabs = List<WorkspaceTab>.from(current.tabs);
      updatedTabs[current.activeTabIndex] = updatedTab;

      emit(current.copyWith(tabs: updatedTabs, clearMagneticSnapGuide: true));
    }
  }

  void _onSetGridPreset(
    SetGridPresetEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final activeTab = current.activeTab;

      final updatedTab = _calculateGridArrangement(
        activeTab.copyWith(
          gridRows: event.rows,
          gridColumns: event.columns,
          isFreeFloating: false,
        ),
        event.canvasSize,
        event.rows,
        event.columns,
      );

      final updatedTabs = List<WorkspaceTab>.from(current.tabs);
      updatedTabs[current.activeTabIndex] = updatedTab;

      emit(current.copyWith(tabs: updatedTabs, clearMagneticSnapGuide: true));
    }
  }

  Future<void> _onChangeWindowSymbol(
    ChangeWindowSymbolEvent event,
    Emitter<OrderbookState> emit,
  ) async {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final res = await getOrderbookBySymbolUseCase(
        GetOrderbookParams(symbol: event.newSymbol),
      );

      res.fold((failure) {}, (data) {
        final activeTab = current.activeTab;
        final updatedWindows = activeTab.windows.map((w) {
          if (w.id == event.windowId) {
            return w.copyWith(orderbook: data);
          }
          return w;
        }).toList();

        final updatedTab = activeTab.copyWith(
          windows: updatedWindows,
          activeWindowId: event.windowId,
        );

        final updatedTabs = List<WorkspaceTab>.from(current.tabs);
        updatedTabs[current.activeTabIndex] = updatedTab;

        emit(current.copyWith(tabs: updatedTabs, lastUpdated: DateTime.now()));
      });
    }
  }

  Future<void> _onAddNewWindowToWorkspace(
    AddNewWindowToWorkspaceEvent event,
    Emitter<OrderbookState> emit,
  ) async {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final activeTab = current.activeTab;

      OrderbookData? data;
      if (event.symbol != null) {
        final res = await getOrderbookBySymbolUseCase(
          GetOrderbookParams(symbol: event.symbol!),
        );
        data = res.dataOrNull;
      }

      int maxZ = 0;
      for (final w in activeTab.windows) {
        maxZ = max(maxZ, w.zIndex);
      }

      final offset = (activeTab.windows.length * 30.0) % 200;
      final newWindow = OrderbookWindowItem(
        id: 'win_${_windowCounter++}',
        orderbook: data,
        position: Offset(40 + offset, 40 + offset),
        size: const Size(350, 390),
        zIndex: maxZ + 1,
      );

      final updatedWindows = List<OrderbookWindowItem>.from(activeTab.windows)
        ..add(newWindow);
      final updatedTab = activeTab.copyWith(
        windows: updatedWindows,
        activeWindowId: newWindow.id,
      );

      final updatedTabs = List<WorkspaceTab>.from(current.tabs);
      updatedTabs[current.activeTabIndex] = updatedTab;

      emit(current.copyWith(tabs: updatedTabs));
    }
  }

  void _onRemoveWindow(RemoveWindowEvent event, Emitter<OrderbookState> emit) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final activeTab = current.activeTab;

      final updatedWindows = List<OrderbookWindowItem>.from(activeTab.windows)
        ..removeWhere((w) => w.id == event.windowId);

      final updatedTab = activeTab.copyWith(
        windows: updatedWindows,
        activeWindowId: updatedWindows.isNotEmpty
            ? updatedWindows.last.id
            : null,
      );

      final updatedTabs = List<WorkspaceTab>.from(current.tabs);
      updatedTabs[current.activeTabIndex] = updatedTab;

      emit(current.copyWith(tabs: updatedTabs));
    }
  }

  void _onSwapWindowPositions(
    SwapWindowPositionsEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      final activeTab = current.activeTab;

      final sourceIdx = activeTab.windows.indexWhere(
        (w) => w.id == event.sourceId,
      );
      final targetIdx = activeTab.windows.indexWhere(
        (w) => w.id == event.targetId,
      );

      if (sourceIdx != -1 && targetIdx != -1) {
        final updatedWindows = List<OrderbookWindowItem>.from(
          activeTab.windows,
        );
        final sourcePos = updatedWindows[sourceIdx].position;
        final targetPos = updatedWindows[targetIdx].position;

        updatedWindows[sourceIdx] = updatedWindows[sourceIdx].copyWith(
          position: targetPos,
        );
        updatedWindows[targetIdx] = updatedWindows[targetIdx].copyWith(
          position: sourcePos,
        );

        final updatedTab = activeTab.copyWith(
          windows: updatedWindows,
          activeWindowId: event.sourceId,
        );

        final updatedTabs = List<WorkspaceTab>.from(current.tabs);
        updatedTabs[current.activeTabIndex] = updatedTab;

        emit(current.copyWith(tabs: updatedTabs));
      }
    }
  }

  void _onFilterGlobalSearch(
    FilterGlobalSearchEvent event,
    Emitter<OrderbookState> emit,
  ) {
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      emit(current.copyWith(searchQuery: event.query));
    }
  }

  void _onFilterOrderbooks(
    FilterOrderbooksEvent event,
    Emitter<OrderbookState> emit,
  ) {
    _onFilterGlobalSearch(FilterGlobalSearchEvent(event.query), emit);
  }

  Rect? _findNearestSnapSlot({
    required OrderbookWindowItem window,
    required Offset position,
    required Size canvasSize,
    required int gridRows,
    required int gridCols,
    required double threshold,
  }) {
    const double padding = 4.0;
    const double spacing = 4.0;

    final availableW =
        canvasSize.width - (padding * 2) - (spacing * (gridCols - 1));
    final availableH =
        canvasSize.height - (padding * 2) - (spacing * (gridRows - 1));

    final tileW = max(280.0, availableW / gridCols);
    final tileH = max(340.0, availableH / gridRows);

    Rect? closestRect;
    double minDistance = double.infinity;

    for (int r = 0; r < gridRows; r++) {
      for (int c = 0; c < gridCols; c++) {
        final slotX = padding + (c * (tileW + spacing));
        final slotY = padding + (r * (tileH + spacing));

        final dist = (position - Offset(slotX, slotY)).distance;
        if (dist < threshold && dist < minDistance) {
          minDistance = dist;
          closestRect = Rect.fromLTWH(slotX, slotY, tileW, tileH);
        }
      }
    }

    return closestRect;
  }

  WorkspaceTab _calculateGridArrangement(
    WorkspaceTab tab,
    Size canvasSize,
    int rows,
    int cols,
  ) {
    if (rows <= 0 || cols <= 0 || tab.windows.isEmpty) return tab;

    const spacing = 4.0;
    const padding = 4.0;

    final availableW =
        canvasSize.width - (padding * 2) - (spacing * (cols - 1));
    final availableH =
        canvasSize.height - (padding * 2) - (spacing * (rows - 1));

    final tileW = max(280.0, availableW / cols);
    final tileH = max(340.0, availableH / rows);
    final tileSize = Size(tileW, tileH);

    final updatedWindows = <OrderbookWindowItem>[];

    for (int i = 0; i < tab.windows.length; i++) {
      final w = tab.windows[i];
      final r = i ~/ cols;
      final c = i % cols;

      final posX = padding + (c * (tileW + spacing));
      final posY = padding + (r * (tileH + spacing));

      updatedWindows.add(
        w.copyWith(position: Offset(posX, posY), size: tileSize, zIndex: i),
      );
    }

    return tab.copyWith(
      windows: updatedWindows,
      gridRows: rows,
      gridColumns: cols,
      isFreeFloating: false,
    );
  }
}
