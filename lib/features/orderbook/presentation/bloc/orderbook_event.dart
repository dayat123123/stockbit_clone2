import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class OrderbookEvent extends Equatable {
  const OrderbookEvent();

  @override
  List<Object?> get props => [];
}

class LoadMultiOrderbooksEvent extends OrderbookEvent {
  const LoadMultiOrderbooksEvent();
}

class RefreshMultiOrderbooksEvent extends OrderbookEvent {
  const RefreshMultiOrderbooksEvent();
}

// Tab Management
class SelectWorkspaceTabEvent extends OrderbookEvent {
  final int tabIndex;

  const SelectWorkspaceTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class AddWorkspaceTabEvent extends OrderbookEvent {
  final String title;

  const AddWorkspaceTabEvent({this.title = 'Orderbook Tab'});

  @override
  List<Object?> get props => [title];
}

class CloseWorkspaceTabEvent extends OrderbookEvent {
  final int tabIndex;

  const CloseWorkspaceTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

// Window Interactions & Smooth Dragging
class SetActiveWindowEvent extends OrderbookEvent {
  final String windowId;

  const SetActiveWindowEvent(this.windowId);

  @override
  List<Object?> get props => [windowId];
}

class StartDragWindowEvent extends OrderbookEvent {
  final String windowId;

  const StartDragWindowEvent(this.windowId);

  @override
  List<Object?> get props => [windowId];
}

class MoveWindowEvent extends OrderbookEvent {
  final String windowId;
  final Offset delta;
  final Size canvasSize;
  final bool enableMagneticSnap;

  const MoveWindowEvent({
    required this.windowId,
    required this.delta,
    this.canvasSize = const Size(1400, 800),
    this.enableMagneticSnap = false,
  });

  @override
  List<Object?> get props => [windowId, delta, canvasSize];
}

class EndDragWindowEvent extends OrderbookEvent {
  final String windowId;
  final Size canvasSize;

  const EndDragWindowEvent({required this.windowId, required this.canvasSize});

  @override
  List<Object?> get props => [windowId, canvasSize];
}

class SetWindowPositionEvent extends OrderbookEvent {
  final String windowId;
  final Offset newPosition;

  const SetWindowPositionEvent({
    required this.windowId,
    required this.newPosition,
  });

  @override
  List<Object?> get props => [windowId, newPosition];
}

class ResizeWindowEvent extends OrderbookEvent {
  final String windowId;
  final Size newSize;

  const ResizeWindowEvent({required this.windowId, required this.newSize});

  @override
  List<Object?> get props => [windowId, newSize];
}

// Layout Mode & Auto-Arrange
class ToggleLayoutModeEvent extends OrderbookEvent {
  const ToggleLayoutModeEvent();
}

class AutoArrangeWindowsEvent extends OrderbookEvent {
  final Size canvasSize;

  const AutoArrangeWindowsEvent(this.canvasSize);

  @override
  List<Object?> get props => [canvasSize];
}

class SetGridPresetEvent extends OrderbookEvent {
  final int rows;
  final int columns;
  final Size canvasSize;

  const SetGridPresetEvent({
    required this.rows,
    required this.columns,
    this.canvasSize = const Size(1400, 800),
  });

  @override
  List<Object?> get props => [rows, columns, canvasSize];
}

// Window Operations (Add, Remove, Symbol change, Swap)
class ChangeWindowSymbolEvent extends OrderbookEvent {
  final String windowId;
  final String newSymbol;

  const ChangeWindowSymbolEvent({
    required this.windowId,
    required this.newSymbol,
  });

  @override
  List<Object?> get props => [windowId, newSymbol];
}

class AddNewWindowToWorkspaceEvent extends OrderbookEvent {
  final String? symbol;
  final Size canvasSize;

  const AddNewWindowToWorkspaceEvent({
    this.symbol,
    this.canvasSize = const Size(1400, 800),
  });

  @override
  List<Object?> get props => [symbol, canvasSize];
}

class RemoveWindowEvent extends OrderbookEvent {
  final String windowId;

  const RemoveWindowEvent(this.windowId);

  @override
  List<Object?> get props => [windowId];
}

class SwapWindowPositionsEvent extends OrderbookEvent {
  final String sourceId;
  final String targetId;

  const SwapWindowPositionsEvent({
    required this.sourceId,
    required this.targetId,
  });

  @override
  List<Object?> get props => [sourceId, targetId];
}

class FilterGlobalSearchEvent extends OrderbookEvent {
  final String query;

  const FilterGlobalSearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterOrderbooksEvent extends OrderbookEvent {
  final String query;

  const FilterOrderbooksEvent(this.query);

  @override
  List<Object?> get props => [query];
}
