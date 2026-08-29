import 'package:stockbit_clone2/core/data/orderbook/orderbook_entry_model.dart';
import 'package:stockbit_clone2/core/data/orderbook/stock_summary_model.dart';
import 'package:stockbit_clone2/core/domain/orderbook/orderbook_data.dart';

class OrderbookDataModel extends OrderbookData {
  const OrderbookDataModel({
    required super.symbol,
    required super.lastPrice,
    required super.change,
    required super.changePercentage,
    required super.summary,
    required super.entries,
    required super.totalBidLot,
    required super.totalOfferLot,
  });

  factory OrderbookDataModel.fromJson(Map<String, dynamic> json) {
    final entriesRaw = json['entries'] as List<dynamic>? ?? [];
    final entriesList = entriesRaw
        .map((e) => OrderbookEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return OrderbookDataModel(
      symbol: json['symbol'] as String? ?? '',
      lastPrice: (json['last_price'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercentage: (json['change_percentage'] as num?)?.toDouble() ?? 0.0,
      summary: StockSummaryModel.fromJson(
        json['summary'] as Map<String, dynamic>? ?? {},
      ),
      entries: entriesList,
      totalBidLot: json['total_bid_lot'] as int? ?? 0,
      totalOfferLot: json['total_offer_lot'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'last_price': lastPrice,
      'change': change,
      'change_percentage': changePercentage,
      'summary': (summary as StockSummaryModel).toJson(),
      'entries': entries
          .map((e) => (e as OrderbookEntryModel).toJson())
          .toList(),
      'total_bid_lot': totalBidLot,
      'total_offer_lot': totalOfferLot,
    };
  }
}
