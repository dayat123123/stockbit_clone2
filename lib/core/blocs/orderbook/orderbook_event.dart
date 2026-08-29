import 'package:equatable/equatable.dart';

abstract class OrderbookEvent extends Equatable {
  const OrderbookEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderbookEvent extends OrderbookEvent {
  final String symbol;

  const LoadOrderbookEvent(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

typedef LoadOrderbookForSymbolEvent = LoadOrderbookEvent;

class LoadMultiOrderbooksEvent extends OrderbookEvent {
  final List<String> symbols;

  const LoadMultiOrderbooksEvent({
    this.symbols = const ['BBCA', 'BBRI', 'BMRI', 'TLKM'],
  });

  @override
  List<Object?> get props => [symbols];
}
