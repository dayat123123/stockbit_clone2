import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_event.dart';

/// A single centralized controller for all window drag operations on the canvas.
/// One instance of this lives in [FloatingWorkspaceCanvas] and handles
/// drag for whichever window the user grabs.
class CanvasDragController extends ChangeNotifier {
  String? _draggingId;
  bool get isDragging => _draggingId != null;
  String? get draggingId => _draggingId;

  void startDrag(String windowId, WorkspaceBloc bloc) {
    _draggingId = windowId;
    bloc.add(SetActiveWindowEvent(windowId));
    notifyListeners();
  }

  void updateDrag(Offset delta, Size canvasSize, WorkspaceBloc bloc) {
    if (_draggingId == null) return;
    bloc.add(MoveWindowEvent(
      windowId: _draggingId!,
      delta: delta,
      canvasSize: canvasSize,
    ));
  }

  void endDrag(WorkspaceBloc bloc) {
    _draggingId = null;
    notifyListeners();
  }
}
