import 'package:stockbit_clone2/core/data/orderbook/orderbook_data_model.dart';
import 'package:stockbit_clone2/core/data/orderbook/orderbook_entry_model.dart';
import 'package:stockbit_clone2/core/data/orderbook/stock_summary_model.dart';

abstract class OrderbookLocalDataSource {
  Future<OrderbookDataModel> getOrderbook(String symbol);
  Future<List<OrderbookDataModel>> getMultiOrderbooks(List<String> symbols);
}

class OrderbookLocalDataSourceImpl implements OrderbookLocalDataSource {
  @override
  Future<OrderbookDataModel> getOrderbook(String symbol) async {
    return _generateMockData(symbol);
  }

  @override
  Future<List<OrderbookDataModel>> getMultiOrderbooks(
    List<String> symbols,
  ) async {
    return symbols.map((s) => _generateMockData(s)).toList();
  }

  OrderbookDataModel _generateMockData(String symbol) {
    double basePrice = 500.0;
    if (symbol == 'BBCA') basePrice = 9850.0;
    if (symbol == 'BBRI') basePrice = 4890.0;
    if (symbol == 'BMRI') basePrice = 6500.0;
    if (symbol == 'TLKM') basePrice = 2940.0;
    if (symbol == 'ASII') basePrice = 4980.0;
    if (symbol == 'PACK') basePrice = 510.0;

    final entries = List.generate(10, (index) {
      final bidP = basePrice - (index * 25);
      final offerP = basePrice + 25 + (index * 25);
      return OrderbookEntryModel(
        bidFreq: 100 + (index * 15),
        bidLot: 20000 + (index * 3500),
        bidPrice: bidP,
        offerPrice: offerP,
        offerLot: 18000 + (index * 2900),
        offerFreq: 95 + (index * 12),
      );
    });

    return OrderbookDataModel(
      symbol: symbol,
      lastPrice: basePrice,
      change: 75.0,
      changePercentage: 1.25,
      summary: StockSummaryModel(
        open: basePrice - 50,
        high: basePrice + 150,
        low: basePrice - 100,
        previous: basePrice - 75,
        autoRejectionAtas: basePrice * 1.25,
        autoRejectionBawah: basePrice * 0.75,
        totalLot: 450000,
        totalValue: basePrice * 450000 * 100,
        averagePrice: basePrice + 10,
      ),
      entries: entries,
      totalBidLot: 350000,
      totalOfferLot: 310000,
    );
  }
}
