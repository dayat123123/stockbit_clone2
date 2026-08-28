import 'package:stockbit_clone2/features/orderbook/data/models/orderbook_entry_model.dart';
import 'package:stockbit_clone2/features/orderbook/data/models/stock_summary_model.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_data.dart';

class OrderbookDataModel extends OrderbookData {
  const OrderbookDataModel({
    required StockSummaryModel super.summary,
    required List<OrderbookEntryModel> super.entries,
    required super.totalBidLot,
    required super.totalOfferLot,
  });

  @override
  StockSummaryModel get summary => super.summary as StockSummaryModel;

  @override
  List<OrderbookEntryModel> get entries =>
      super.entries as List<OrderbookEntryModel>;

  factory OrderbookDataModel.fromJson(Map<String, dynamic> json) {
    final summaryModel = StockSummaryModel.fromJson(
      json['summary'] as Map<String, dynamic>? ?? {},
    );
    final rawEntries = json['entries'] as List<dynamic>? ?? [];
    final entriesList = rawEntries
        .map((e) => OrderbookEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return OrderbookDataModel(
      summary: summaryModel,
      entries: entriesList,
      totalBidLot:
          (json['total_bid_lot'] as num?)?.toInt() ??
          entriesList.fold(0, (sum, item) => sum + item.bidLot),
      totalOfferLot:
          (json['total_offer_lot'] as num?)?.toInt() ??
          entriesList.fold(0, (sum, item) => sum + item.offerLot),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'total_bid_lot': totalBidLot,
      'total_offer_lot': totalOfferLot,
    };
  }
}
