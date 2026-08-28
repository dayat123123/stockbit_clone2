import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_item.dart';

class WatchlistItemModel extends WatchlistItem {
  const WatchlistItemModel({
    required super.symbol,
    required super.name,
    super.badge = 'RG',
    required super.lastPrice,
    required super.change,
    required super.changePercentage,
    required super.volume,
    required super.sparklinePrices,
  });

  factory WatchlistItemModel.fromJson(Map<String, dynamic> json) {
    return WatchlistItemModel(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      badge: (json['badge'] as String?) ?? 'RG',
      lastPrice: (json['last_price'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercentage: (json['change_pct'] as num).toDouble(),
      volume: json['volume'] as String,
      sparklinePrices: (json['sparkline'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'badge': badge,
      'last_price': lastPrice,
      'change': change,
      'change_pct': changePercentage,
      'volume': volume,
      'sparkline': sparklinePrices,
    };
  }
}
