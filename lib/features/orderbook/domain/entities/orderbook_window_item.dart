import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_data.dart';

class OrderbookWindowItem extends Equatable {
  final String id;
  final OrderbookData? orderbook;
  final Offset position;
  final Size size;
  final int zIndex;
  final bool isMinimized;
  final bool isDragging;

  const OrderbookWindowItem({
    required this.id,
    this.orderbook,
    required this.position,
    required this.size,
    this.zIndex = 0,
    this.isMinimized = false,
    this.isDragging = false,
  });

  OrderbookWindowItem copyWith({
    String? id,
    OrderbookData? orderbook,
    bool clearOrderbook = false,
    Offset? position,
    Size? size,
    int? zIndex,
    bool? isMinimized,
    bool? isDragging,
  }) {
    return OrderbookWindowItem(
      id: id ?? this.id,
      orderbook: clearOrderbook ? null : (orderbook ?? this.orderbook),
      position: position ?? this.position,
      size: size ?? this.size,
      zIndex: zIndex ?? this.zIndex,
      isMinimized: isMinimized ?? this.isMinimized,
      isDragging: isDragging ?? this.isDragging,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderbook,
        position,
        size,
        zIndex,
        isMinimized,
        isDragging,
      ];
}
