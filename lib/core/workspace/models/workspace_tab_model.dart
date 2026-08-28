import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/core/workspace/models/layout_mode.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_window_model.dart';

/// Data model representing an individual workspace tab.
///
/// Contains ID, title, [LayoutMode] (fixed vs scrollable), and list of windows.
class WorkspaceTabModel extends Equatable {
  final String id;
  final String title;
  final LayoutMode layoutMode;
  final List<WorkspaceWindowModel> windows;
  final String? activeWindowId;
  final bool isFreeFloating;
  final int gridRows;
  final int gridColumns;

  const WorkspaceTabModel({
    required this.id,
    required this.title,
    this.layoutMode = LayoutMode.fixed,
    required this.windows,
    this.activeWindowId,
    this.isFreeFloating = false,
    this.gridRows = 2,
    this.gridColumns = 4,
  });

  WorkspaceWindowModel? get activeWindow {
    if (activeWindowId == null || windows.isEmpty) return null;
    try {
      return windows.firstWhere((w) => w.id == activeWindowId);
    } catch (_) {
      return windows.first;
    }
  }

  WorkspaceTabModel copyWith({
    String? id,
    String? title,
    LayoutMode? layoutMode,
    List<WorkspaceWindowModel>? windows,
    String? activeWindowId,
    bool? isFreeFloating,
    int? gridRows,
    int? gridColumns,
  }) {
    return WorkspaceTabModel(
      id: id ?? this.id,
      title: title ?? this.title,
      layoutMode: layoutMode ?? this.layoutMode,
      windows: windows ?? this.windows,
      activeWindowId: activeWindowId ?? this.activeWindowId,
      isFreeFloating: isFreeFloating ?? this.isFreeFloating,
      gridRows: gridRows ?? this.gridRows,
      gridColumns: gridColumns ?? this.gridColumns,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    layoutMode,
    windows,
    activeWindowId,
    isFreeFloating,
    gridRows,
    gridColumns,
  ];
}
