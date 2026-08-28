import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_window.dart';

/// A tab in the workspace, each containing its own set of windows.
class WorkspaceTab extends Equatable {
  final String id;
  final String title;
  final List<WorkspaceWindow> windows;
  final String? activeWindowId;
  final bool isFreeFloating;
  final int gridRows;
  final int gridColumns;

  const WorkspaceTab({
    required this.id,
    required this.title,
    required this.windows,
    this.activeWindowId,
    this.isFreeFloating = false,
    this.gridRows = 2,
    this.gridColumns = 4,
  });

  WorkspaceWindow? get activeWindow {
    if (activeWindowId == null || windows.isEmpty) return null;
    try {
      return windows.firstWhere((w) => w.id == activeWindowId);
    } catch (_) {
      return windows.first;
    }
  }

  WorkspaceTab copyWith({
    String? id,
    String? title,
    List<WorkspaceWindow>? windows,
    String? activeWindowId,
    bool? isFreeFloating,
    int? gridRows,
    int? gridColumns,
  }) {
    return WorkspaceTab(
      id: id ?? this.id,
      title: title ?? this.title,
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
        windows,
        activeWindowId,
        isFreeFloating,
        gridRows,
        gridColumns,
      ];
}
