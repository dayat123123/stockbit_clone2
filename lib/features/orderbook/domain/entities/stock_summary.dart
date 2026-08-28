import 'package:equatable/equatable.dart';

class StockSummary extends Equatable {
  final String symbol;
  final String companyName;
  final double price;
  final double change;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final double prev;
  final double ara;
  final double arb;
  final int lot;
  final double value;
  final double avg;
  final String leverage; // e.g., "5x", "3x"
  final String logoIcon;

  const StockSummary({
    required this.symbol,
    required this.companyName,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.prev,
    required this.ara,
    required this.arb,
    required this.lot,
    required this.value,
    required this.avg,
    required this.leverage,
    required this.logoIcon,
  });

  @override
  List<Object?> get props => [
    symbol,
    companyName,
    price,
    change,
    changePercent,
    open,
    high,
    low,
    prev,
    ara,
    arb,
    lot,
    value,
    avg,
    leverage,
    logoIcon,
  ];
}
