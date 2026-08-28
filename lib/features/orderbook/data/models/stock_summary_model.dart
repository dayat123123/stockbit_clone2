import 'package:stockbit_clone2/features/orderbook/domain/entities/stock_summary.dart';

class StockSummaryModel extends StockSummary {
  const StockSummaryModel({
    required super.symbol,
    required super.companyName,
    required super.price,
    required super.change,
    required super.changePercent,
    required super.open,
    required super.high,
    required super.low,
    required super.prev,
    required super.ara,
    required super.arb,
    required super.lot,
    required super.value,
    required super.avg,
    required super.leverage,
    required super.logoIcon,
  });

  factory StockSummaryModel.fromJson(Map<String, dynamic> json) {
    return StockSummaryModel(
      symbol: json['symbol'] as String? ?? '',
      companyName: json['company_name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['change_percent'] as num?)?.toDouble() ?? 0.0,
      open: (json['open'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      prev: (json['prev'] as num?)?.toDouble() ?? 0.0,
      ara: (json['ara'] as num?)?.toDouble() ?? 0.0,
      arb: (json['arb'] as num?)?.toDouble() ?? 0.0,
      lot: (json['lot'] as num?)?.toInt() ?? 0,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      avg: (json['avg'] as num?)?.toDouble() ?? 0.0,
      leverage: json['leverage'] as String? ?? '1x',
      logoIcon: json['logo_icon'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'company_name': companyName,
      'price': price,
      'change': change,
      'change_percent': changePercent,
      'open': open,
      'high': high,
      'low': low,
      'prev': prev,
      'ara': ara,
      'arb': arb,
      'lot': lot,
      'value': value,
      'avg': avg,
      'leverage': leverage,
      'logo_icon': logoIcon,
    };
  }

  StockSummaryModel copyWith({
    String? symbol,
    String? companyName,
    double? price,
    double? change,
    double? changePercent,
    double? open,
    double? high,
    double? low,
    double? prev,
    double? ara,
    double? arb,
    int? lot,
    double? value,
    double? avg,
    String? leverage,
    String? logoIcon,
  }) {
    return StockSummaryModel(
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      prev: prev ?? this.prev,
      ara: ara ?? this.ara,
      arb: arb ?? this.arb,
      lot: lot ?? this.lot,
      value: value ?? this.value,
      avg: avg ?? this.avg,
      leverage: leverage ?? this.leverage,
      logoIcon: logoIcon ?? this.logoIcon,
    );
  }
}
