import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/core/domain/orderbook/orderbook_entry.dart';
import 'package:stockbit_clone2/core/domain/orderbook/stock_summary.dart';

class OrderbookData extends Equatable {
  final String symbol;
  final double lastPrice;
  final double change;
  final double changePercentage;
  final StockSummary summary;
  final List<OrderbookEntry> entries;
  final int totalBidLot;
  final int totalOfferLot;

  const OrderbookData({
    required this.symbol,
    required this.lastPrice,
    required this.change,
    required this.changePercentage,
    required this.summary,
    required this.entries,
    required this.totalBidLot,
    required this.totalOfferLot,
  });

  bool get isPositive => change >= 0;

  @override
  List<Object?> get props => [
    symbol,
    lastPrice,
    change,
    changePercentage,
    summary,
    entries,
    totalBidLot,
    totalOfferLot,
  ];
}
