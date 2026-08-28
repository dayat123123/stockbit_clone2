import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/workspace/models/window_widget_type.dart';

/// A single window on the workspace canvas.
///
/// This is a generic container — it does NOT know about orderbook data.
/// The [widgetType] determines what content widget is rendered inside the shell.
/// [metadata] carries type-specific config (e.g. stock symbol for orderbook).
class WorkspaceWindow extends Equatable {
  final String id;
  final WindowWidgetType widgetType;
  final Offset position;
  final Size size;
  final int zIndex;
  final bool isMinimized;

  /// Type-specific configuration.
  /// For orderbook: `{'symbol': 'BBRI'}`.
  /// For chart: `{'symbol': 'BBCA', 'timeframe': '1D'}`.
  final Map<String, dynamic> metadata;

  const WorkspaceWindow({
    required this.id,
    required this.widgetType,
    required this.position,
    required this.size,
    this.zIndex = 0,
    this.isMinimized = false,
    this.metadata = const {},
  });

  /// Convenience getter for the stock symbol stored in metadata.
  String? get symbol => metadata['symbol'] as String?;

  WorkspaceWindow copyWith({
    String? id,
    WindowWidgetType? widgetType,
    Offset? position,
    Size? size,
    int? zIndex,
    bool? isMinimized,
    Map<String, dynamic>? metadata,
  }) {
    return WorkspaceWindow(
      id: id ?? this.id,
      widgetType: widgetType ?? this.widgetType,
      position: position ?? this.position,
      size: size ?? this.size,
      zIndex: zIndex ?? this.zIndex,
      isMinimized: isMinimized ?? this.isMinimized,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        widgetType,
        position,
        size,
        zIndex,
        isMinimized,
        metadata,
      ];
}
