import 'package:stockbit_clone2/core/data/orderbook/orderbook_local_data_source.dart';
import 'package:stockbit_clone2/core/data/orderbook/orderbook_remote_data_source.dart';
import 'package:stockbit_clone2/core/domain/orderbook/orderbook_data.dart';
import 'package:stockbit_clone2/core/domain/orderbook/orderbook_repository.dart';
import 'package:stockbit_clone2/core/errors/failures.dart';
import 'package:stockbit_clone2/core/utils/result.dart';

class OrderbookRepositoryImpl implements OrderbookRepository {
  final OrderbookRemoteDataSource remoteDataSource;
  final OrderbookLocalDataSource localDataSource;

  OrderbookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<OrderbookData>> getOrderbook(String symbol) async {
    try {
      final data = await remoteDataSource.getOrderbook(symbol);
      return Result.success(data);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<OrderbookData>>> getMultiOrderbooks(
    List<String> symbols,
  ) async {
    try {
      final list = await remoteDataSource.getMultiOrderbooks(symbols);
      return Result.success(list);
    } catch (e) {
      return Result.failure(ServerFailure(message: e.toString()));
    }
  }
}
