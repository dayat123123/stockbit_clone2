import 'package:flutter/material.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_event.dart';

/// A single centralized controller for all window drag operations on the canvas.
/// One instance of this lives in [OrderbookCanvasWorkspace] and handles
/// drag for whichever window the user grabs — no per-window GestureDetector needed.
class CanvasDragController extends ChangeNotifier {
  String? _draggingId;
  bool get isDragging => _draggingId != null;
  String? get draggingId => _draggingId;

  void startDrag(String windowId, OrderbookBloc bloc) {
    _draggingId = windowId;
    bloc.add(SetActiveWindowEvent(windowId));
    notifyListeners();
  }

  void updateDrag(Offset delta, Size canvasSize, OrderbookBloc bloc) {
    if (_draggingId == null) return;
    bloc.add(MoveWindowEvent(
      windowId: _draggingId!,
      delta: delta,
      canvasSize: canvasSize,
    ));
  }

  void endDrag(OrderbookBloc bloc) {
    _draggingId = null;
    notifyListeners();
  }
}
