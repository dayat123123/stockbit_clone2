import 'package:stockbit_clone2/core/domain/orderbook/orderbook_entry.dart';

class OrderbookEntryModel extends OrderbookEntry {
  const OrderbookEntryModel({
    required super.bidFreq,
    required super.bidLot,
    required super.bidPrice,
    required super.offerPrice,
    required super.offerLot,
    required super.offerFreq,
  });

  factory OrderbookEntryModel.fromJson(Map<String, dynamic> json) {
    return OrderbookEntryModel(
      bidFreq: json['bid_freq'] as int? ?? 0,
      bidLot: json['bid_lot'] as int? ?? 0,
      bidPrice: (json['bid_price'] as num?)?.toDouble() ?? 0.0,
      offerPrice: (json['offer_price'] as num?)?.toDouble() ?? 0.0,
      offerLot: json['offer_lot'] as int? ?? 0,
      offerFreq: json['offer_freq'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bid_freq': bidFreq,
      'bid_lot': bidLot,
      'bid_price': bidPrice,
      'offer_price': offerPrice,
      'offer_lot': offerLot,
      'offer_freq': offerFreq,
    };
  }
}
