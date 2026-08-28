import 'package:equatable/equatable.dart';

class OrderbookEntry extends Equatable {
  final int bidFreq;
  final int bidLot;
  final double bidPrice;
  final double offerPrice;
  final int offerLot;
  final int offerFreq;

  const OrderbookEntry({
    required this.bidFreq,
    required this.bidLot,
    required this.bidPrice,
    required this.offerPrice,
    required this.offerLot,
    required this.offerFreq,
  });

  @override
  List<Object?> get props => [
    bidFreq,
    bidLot,
    bidPrice,
    offerPrice,
    offerLot,
    offerFreq,
  ];
}
