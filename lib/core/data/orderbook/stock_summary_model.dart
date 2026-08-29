import 'package:stockbit_clone2/core/domain/orderbook/stock_summary.dart';

class StockSummaryModel extends StockSummary {
  const StockSummaryModel({
    required super.open,
    required super.high,
    required super.low,
    required super.previous,
    required super.autoRejectionAtas,
    required super.autoRejectionBawah,
    required super.totalLot,
    required super.totalValue,
    required super.averagePrice,
  });

  factory StockSummaryModel.fromJson(Map<String, dynamic> json) {
    return StockSummaryModel(
      open: (json['open'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      previous: (json['previous'] as num?)?.toDouble() ?? 0.0,
      autoRejectionAtas:
          (json['auto_rejection_atas'] as num?)?.toDouble() ?? 0.0,
      autoRejectionBawah:
          (json['auto_rejection_bawah'] as num?)?.toDouble() ?? 0.0,
      totalLot: json['total_lot'] as int? ?? 0,
      totalValue: (json['total_value'] as num?)?.toDouble() ?? 0.0,
      averagePrice: (json['average_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'high': high,
      'low': low,
      'previous': previous,
      'auto_rejection_atas': autoRejectionAtas,
      'auto_rejection_bawah': autoRejectionBawah,
      'total_lot': totalLot,
      'total_value': totalValue,
      'average_price': averagePrice,
    };
  }
}
