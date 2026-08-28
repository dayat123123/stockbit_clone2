import 'dart:async';
import 'package:stockbit_clone2/features/orderbook/data/models/orderbook_data_model.dart';

abstract class OrderbookRemoteDataSource {
  Future<List<OrderbookDataModel>> fetchMultiOrderbooks();
  Future<OrderbookDataModel> fetchOrderbookBySymbol(String symbol);
  Stream<OrderbookDataModel> streamOrderbookUpdates(String symbol);
}
