import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_entry.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/stock_summary.dart';

class OrderbookData extends Equatable {
  final StockSummary summary;
  final List<OrderbookEntry> entries;
  final int totalBidLot;
  final int totalOfferLot;

  const OrderbookData({
    required this.summary,
    required this.entries,
    required this.totalBidLot,
    required this.totalOfferLot,
  });

  @override
  List<Object?> get props => [summary, entries, totalBidLot, totalOfferLot];
}
