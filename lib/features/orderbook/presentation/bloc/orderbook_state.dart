import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_data.dart';

abstract class OrderbookState extends Equatable {
  const OrderbookState();

  @override
  List<Object?> get props => [];
}

class OrderbookInitialState extends OrderbookState {
  const OrderbookInitialState();
}

class OrderbookLoadingState extends OrderbookState {
  const OrderbookLoadingState();
}

/// All orderbook data keyed by symbol.
/// The UI reads from this map using the symbol stored in window metadata.
class OrderbookLoadedState extends OrderbookState {
  /// Map of symbol → OrderbookData.
  final Map<String, OrderbookData> orderbooksBySymbol;
  final DateTime lastUpdated;

  const OrderbookLoadedState({
    required this.orderbooksBySymbol,
    required this.lastUpdated,
  });

  /// Get orderbook for a specific symbol.
  OrderbookData? getBySymbol(String? symbol) {
    if (symbol == null) return null;
    return orderbooksBySymbol[symbol.toUpperCase()];
  }

  OrderbookLoadedState copyWith({
    Map<String, OrderbookData>? orderbooksBySymbol,
    DateTime? lastUpdated,
  }) {
    return OrderbookLoadedState(
      orderbooksBySymbol: orderbooksBySymbol ?? this.orderbooksBySymbol,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [orderbooksBySymbol, lastUpdated];
}

class OrderbookErrorState extends OrderbookState {
  final String message;
  const OrderbookErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
