import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/core/domain/orderbook/orderbook_data.dart';

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

class OrderbookLoadedState extends OrderbookState {
  final Map<String, OrderbookData> orderbooks;
  final String activeSymbol;

  const OrderbookLoadedState({
    required this.orderbooks,
    required this.activeSymbol,
  });

  OrderbookData? get activeOrderbook => orderbooks[activeSymbol];

  OrderbookData? getBySymbol(String symbol) => orderbooks[symbol];

  OrderbookLoadedState copyWith({
    Map<String, OrderbookData>? orderbooks,
    String? activeSymbol,
  }) {
    return OrderbookLoadedState(
      orderbooks: orderbooks ?? this.orderbooks,
      activeSymbol: activeSymbol ?? this.activeSymbol,
    );
  }

  @override
  List<Object?> get props => [orderbooks, activeSymbol];
}

class OrderbookErrorState extends OrderbookState {
  final String message;

  const OrderbookErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
