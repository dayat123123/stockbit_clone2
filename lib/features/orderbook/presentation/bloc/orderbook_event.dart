import 'package:equatable/equatable.dart';

abstract class OrderbookEvent extends Equatable {
  const OrderbookEvent();

  @override
  List<Object?> get props => [];
}

// ─── Data Loading ─────────────────────────────────────────────────────────────

/// Load orderbook data for multiple default symbols at startup.
class LoadMultiOrderbooksEvent extends OrderbookEvent {
  const LoadMultiOrderbooksEvent();
}

/// Refresh all loaded orderbook data.
class RefreshOrderbooksEvent extends OrderbookEvent {
  const RefreshOrderbooksEvent();
}

// ─── Symbol-Specific ──────────────────────────────────────────────────────────

/// Load orderbook data for a specific symbol (e.g. when a new orderbook window
/// is added or the symbol is changed).
class LoadOrderbookForSymbolEvent extends OrderbookEvent {
  final String symbol;
  const LoadOrderbookForSymbolEvent(this.symbol);

  @override
  List<Object?> get props => [symbol];
}
