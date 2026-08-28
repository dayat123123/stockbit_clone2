import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:stockbit_clone2/core/workspace/models/workspace_widget_type.dart';

/// Data model representing a modular window panel placed inside a workspace tab.
class WorkspaceWindowModel extends Equatable {
  final String id;
  final WorkspaceWidgetType type;
  final String symbol;
  final Offset position;
  final Size size;
  final int zIndex;
  final bool isMinimized;

  const WorkspaceWindowModel({
    required this.id,
    required this.type,
    this.symbol = 'BBCA',
    required this.position,
    required this.size,
    this.zIndex = 0,
    this.isMinimized = false,
  });

  WorkspaceWindowModel copyWith({
    String? id,
    WorkspaceWidgetType? type,
    String? symbol,
    Offset? position,
    Size? size,
    int? zIndex,
    bool? isMinimized,
  }) {
    return WorkspaceWindowModel(
      id: id ?? this.id,
      type: type ?? this.type,
      symbol: symbol ?? this.symbol,
      position: position ?? this.position,
      size: size ?? this.size,
      zIndex: zIndex ?? this.zIndex,
      isMinimized: isMinimized ?? this.isMinimized,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    symbol,
    position,
    size,
    zIndex,
    isMinimized,
  ];
}
