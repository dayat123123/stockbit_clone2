import 'package:equatable/equatable.dart';

/// Domain Entity representing an individual stock item inside a Watchlist.
class WatchlistItem extends Equatable {
  final String symbol;
  final String name;
  final String badge;
  final double lastPrice;
  final double change;
  final double changePercentage;
  final String volume;
  final List<double> sparklinePrices;

  const WatchlistItem({
    required this.symbol,
    required this.name,
    this.badge = 'RG',
    required this.lastPrice,
    required this.change,
    required this.changePercentage,
    required this.volume,
    required this.sparklinePrices,
  });

  bool get isPositive => change >= 0;

  @override
  List<Object?> get props => [
    symbol,
    name,
    badge,
    lastPrice,
    change,
    changePercentage,
    volume,
    sparklinePrices,
  ];
}
