import 'package:stockbit_clone2/core/domain/watchlist/watchlist_item.dart';

class WatchlistItemModel extends WatchlistItem {
  const WatchlistItemModel({
    required super.symbol,
    required super.name,
    required super.lastPrice,
    required super.change,
    required super.changePercentage,
    required super.badge,
    required super.sparklinePrices,
  });

  factory WatchlistItemModel.fromJson(Map<String, dynamic> json) {
    final prices = (json['sparkline_prices'] as List<dynamic>? ?? [])
        .map((e) => (e as num).toDouble())
        .toList();

    return WatchlistItemModel(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lastPrice: (json['last_price'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercentage: (json['change_percentage'] as num?)?.toDouble() ?? 0.0,
      badge: json['badge'] as String? ?? '1x',
      sparklinePrices: prices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'last_price': lastPrice,
      'change': change,
      'change_percentage': changePercentage,
      'badge': badge,
      'sparkline_prices': sparklinePrices,
    };
  }
}
