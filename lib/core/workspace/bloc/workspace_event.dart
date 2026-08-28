import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/workspace/models/layout_mode.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_widget_type.dart';

abstract class WorkspaceEvent extends Equatable {
  const WorkspaceEvent();

  @override
  List<Object?> get props => [];
}

// ─── Initialization ──────────────────────────────────────────────────────────

class InitializeWorkspaceEvent extends WorkspaceEvent {
  const InitializeWorkspaceEvent();
}

// ─── Tabs ────────────────────────────────────────────────────────────────────

class SelectWorkspaceTabEvent extends WorkspaceEvent {
  final int tabIndex;
  const SelectWorkspaceTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class AddWorkspaceTabEvent extends WorkspaceEvent {
  final String title;
  final LayoutMode layoutMode;

  const AddWorkspaceTabEvent({
    this.title = 'Terminal Tab',
    this.layoutMode = LayoutMode.fixed,
  });

  @override
  List<Object?> get props => [title, layoutMode];
}

class CloseWorkspaceTabEvent extends WorkspaceEvent {
  final int tabIndex;
  const CloseWorkspaceTabEvent(this.tabIndex);

  @override
  List<Object?> get props => [tabIndex];
}

class ToggleTabModeEvent extends WorkspaceEvent {
  const ToggleTabModeEvent();
}

// ─── Window Selection & Manipulation ─────────────────────────────────────────

class SetActiveWindowEvent extends WorkspaceEvent {
  final String windowId;
  const SetActiveWindowEvent(this.windowId);

  @override
  List<Object?> get props => [windowId];
}

class ChangeWindowSymbolEvent extends WorkspaceEvent {
  final String windowId;
  final String newSymbol;

  const ChangeWindowSymbolEvent({
    required this.windowId,
    required this.newSymbol,
  });

  @override
  List<Object?> get props => [windowId, newSymbol];
}

class ResetWindowSlotEvent extends WorkspaceEvent {
  final String windowId;
  const ResetWindowSlotEvent(this.windowId);

  @override
  List<Object?> get props => [windowId];
}

class MoveWindowEvent extends WorkspaceEvent {
  final String windowId;
  final Offset delta;
  final Size canvasSize;

  const MoveWindowEvent({
    required this.windowId,
    required this.delta,
    required this.canvasSize,
  });

  @override
  List<Object?> get props => [windowId, delta, canvasSize];
}

class SnapWindowOnReleaseEvent extends WorkspaceEvent {
  final String windowId;
  final Size canvasSize;

  const SnapWindowOnReleaseEvent({
    required this.windowId,
    required this.canvasSize,
  });

  @override
  List<Object?> get props => [windowId, canvasSize];
}

class ResizeWindowEvent extends WorkspaceEvent {
  final String windowId;
  final Size newSize;
  final Offset? newPosition;

  const ResizeWindowEvent({
    required this.windowId,
    required this.newSize,
    this.newPosition,
  });

  @override
  List<Object?> get props => [windowId, newSize, newPosition];
}

class SnapResizeOnReleaseEvent extends WorkspaceEvent {
  final String windowId;
  final Size canvasSize;

  const SnapResizeOnReleaseEvent({
    required this.windowId,
    required this.canvasSize,
  });

  @override
  List<Object?> get props => [windowId, canvasSize];
}

/// Added exclusively via Toolbar / Header Add Window button.
class AddNewWindowToWorkspaceEvent extends WorkspaceEvent {
  final WorkspaceWidgetType type;
  final String symbol;
  final Size canvasSize;

  const AddNewWindowToWorkspaceEvent({
    required this.type,
    this.symbol = 'BBCA',
    required this.canvasSize,
  });

  @override
  List<Object?> get props => [type, symbol, canvasSize];
}

class RemoveWindowEvent extends WorkspaceEvent {
  final String windowId;
  const RemoveWindowEvent(this.windowId);

  @override
  List<Object?> get props => [windowId];
}

// ─── Layout & Arrangement ─────────────────────────────────────────────────────

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
    required this.canvasSize,
  });

  @override
  List<Object?> get props => [rows, columns, canvasSize];
}

class GlobalSearchSymbolEvent extends WorkspaceEvent {
  final String query;
  const GlobalSearchSymbolEvent(this.query);

  @override
  List<Object?> get props => [query];
}

enum WorkspaceLayoutTemplate {
  newLayout(
    title: 'New Layout',
    subtitle: 'Add widgets and customize your way.',
    tag: 'Custom',
  ),
  multiOrderbook(
    title: 'Multi-orderbook',
    subtitle: 'Display 10 different stock orderbook.',
    tag: 'Template',
  ),
  multiChart(
    title: 'Multi-chart',
    subtitle: 'Observe multiple stocks charts.',
    tag: 'Template',
  ),
  classic(
    title: 'Classic',
    subtitle: 'Basic stock trading layout.',
    tag: 'Template',
  ),
  multiStock(
    title: 'Multi-stock',
    subtitle: 'Monitor multiple stocks at the same time.',
    tag: 'Template',
  ),
  singleStock(
    title: 'Single-stock',
    subtitle: 'Focused stock trading dashboard.',
    tag: 'Template',
  ),
  fastOrder(
    title: 'Fast Order',
    subtitle: 'Experience quick trades execution.',
    tag: 'Template',
  );

  final String title;
  final String subtitle;
  final String tag;

  const WorkspaceLayoutTemplate({
    required this.title,
    required this.subtitle,
    required this.tag,
  });
}

class CreateTemplateLayoutEvent extends WorkspaceEvent {
  final WorkspaceLayoutTemplate template;
  final Size canvasSize;

  const CreateTemplateLayoutEvent({
    required this.template,
    required this.canvasSize,
  });

  @override
  List<Object?> get props => [template, canvasSize];
}
