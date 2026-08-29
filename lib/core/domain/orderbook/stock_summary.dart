import 'package:equatable/equatable.dart';

class StockSummary extends Equatable {
  final double open;
  final double high;
  final double low;
  final double previous;
  final double autoRejectionAtas;
  final double autoRejectionBawah;
  final int totalLot;
  final double totalValue;
  final double averagePrice;

  const StockSummary({
    required this.open,
    required this.high,
    required this.low,
    required this.previous,
    required this.autoRejectionAtas,
    required this.autoRejectionBawah,
    required this.totalLot,
    required this.totalValue,
    required this.averagePrice,
  });

  double get prev => previous;
  double get ara => autoRejectionAtas;
  double get arb => autoRejectionBawah;
  int get lot => totalLot;
  double get value => totalValue;
  double get avg => averagePrice;

  @override
  List<Object?> get props => [
    open,
    high,
    low,
    previous,
    autoRejectionAtas,
    autoRejectionBawah,
    totalLot,
    totalValue,
    averagePrice,
  ];
}
