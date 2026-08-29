import 'package:stockbit_clone2/core/data/orderbook/orderbook_data_model.dart';
import 'package:stockbit_clone2/core/data/orderbook/orderbook_local_data_source.dart';
import 'package:stockbit_clone2/core/data/orderbook/orderbook_remote_data_source.dart';

class OrderbookRemoteDataSourceImpl implements OrderbookRemoteDataSource {
  final OrderbookLocalDataSource localDataSource;

  OrderbookRemoteDataSourceImpl({required this.localDataSource});

  @override
  Future<OrderbookDataModel> getOrderbook(String symbol) async {
    return await localDataSource.getOrderbook(symbol);
  }

  @override
  Future<List<OrderbookDataModel>> getMultiOrderbooks(
    List<String> symbols,
  ) async {
    return await localDataSource.getMultiOrderbooks(symbols);
  }
}
