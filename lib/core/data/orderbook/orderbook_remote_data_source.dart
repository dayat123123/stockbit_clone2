import 'package:stockbit_clone2/core/data/orderbook/orderbook_data_model.dart';

abstract class OrderbookRemoteDataSource {
  Future<OrderbookDataModel> getOrderbook(String symbol);
  Future<List<OrderbookDataModel>> getMultiOrderbooks(List<String> symbols);
}
