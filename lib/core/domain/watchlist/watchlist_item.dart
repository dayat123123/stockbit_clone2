import 'package:equatable/equatable.dart';

class WatchlistItem extends Equatable {
  final String symbol;
  final String name;
  final double lastPrice;
  final double change;
  final double changePercentage;
  final String badge;
  final List<double> sparklinePrices;

  const WatchlistItem({
    required this.symbol,
    required this.name,
    required this.lastPrice,
    required this.change,
    required this.changePercentage,
    required this.badge,
    required this.sparklinePrices,
  });

  bool get isPositive => change >= 0;

  @override
  List<Object?> get props => [
    symbol,
    name,
    lastPrice,
    change,
    changePercentage,
    badge,
    sparklinePrices,
  ];
}
