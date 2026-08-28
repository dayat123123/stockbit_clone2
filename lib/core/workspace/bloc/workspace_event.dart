import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/workspace/models/window_widget_type.dart';

abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

// ─── Initialization ───────────────────────────────────────────────────────────

/// Populate the workspace with a default set of windows.
class InitWorkspaceEvent extends WorkspaceEvent {
  /// List of (type, metadata) for each initial window to create.
  final List<(WindowWidgetType, Map<String, dynamic>)> initialWindows;
  const InitWorkspaceEvent({required this.initialWindows});

  @override
  List<Object?> get props => [initialWindows];
}

// ─── Tab Management ───────────────────────────────────────────────────────────

class SelectTabEvent extends WorkspaceEvent {
  final int tabIndex;
  const SelectTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class AddTabEvent extends WorkspaceEvent {
  final String title;
  final List<(WindowWidgetType, Map<String, dynamic>)> initialWindows;
  const AddTabEvent({
    this.title = 'Workspace',
    this.initialWindows = const [],
  });

  @override
  List<Object?> get props => [title, initialWindows];
}

class CloseTabEvent extends WorkspaceEvent {
  final int tabIndex;
  const CloseTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

// ─── Window Focus ─────────────────────────────────────────────────────────────

class SetActiveWindowEvent extends WorkspaceEvent {
  final String windowId;
  const SetActiveWindowEvent(this.windowId);

  @override
  List<Object?> get props => [windowId];
}

// ─── Window Move ──────────────────────────────────────────────────────────────

class MoveWindowEvent extends WorkspaceEvent {
  final String windowId;
  final Offset delta;
  final Size canvasSize;

  const MoveWindowEvent({
    required this.windowId,
    required this.delta,
    this.canvasSize = const Size(1400, 800),
  });

  @override
  List<Object?> get props => [windowId, delta, canvasSize];
}

// ─── Window Resize ────────────────────────────────────────────────────────────

class ResizeWindowEvent extends WorkspaceEvent {
  final String windowId;
  final Size newSize;
  const ResizeWindowEvent({required this.windowId, required this.newSize});

  @override
  List<Object?> get props => [windowId, newSize];
}

// ─── Window CRUD ──────────────────────────────────────────────────────────────

class AddWindowEvent extends WorkspaceEvent {
  final WindowWidgetType widgetType;
  final Map<String, dynamic> metadata;
  final Size canvasSize;

  const AddWindowEvent({
    required this.widgetType,
    this.metadata = const {},
    this.canvasSize = const Size(1400, 800),
  });

  @override
  List<Object?> get props => [widgetType, metadata, canvasSize];
}

class RemoveWindowEvent extends WorkspaceEvent {
  final String windowId;
  const RemoveWindowEvent(this.windowId);

  @override
  List<Object?> get props => [windowId];
}

class UpdateWindowMetadataEvent extends WorkspaceEvent {
  final String windowId;
  final Map<String, dynamic> metadata;
  const UpdateWindowMetadataEvent({
    required this.windowId,
    required this.metadata,
  });

  @override
  List<Object?> get props => [windowId, metadata];
}

// ─── Layout ───────────────────────────────────────────────────────────────────

class ToggleLayoutModeEvent extends WorkspaceEvent {
  const ToggleLayoutModeEvent();
}

class AutoArrangeWindowsEvent extends WorkspaceEvent {
  final Size canvasSize;
  const AutoArrangeWindowsEvent(this.canvasSize);

  @override
  List<Object?> get props => [canvasSize];
}

class SetGridPresetEvent extends WorkspaceEvent {
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

// ─── Search ───────────────────────────────────────────────────────────────────

class FilterGlobalSearchEvent extends WorkspaceEvent {
  final String query;
  const FilterGlobalSearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}
