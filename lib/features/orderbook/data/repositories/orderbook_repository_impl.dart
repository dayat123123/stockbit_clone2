import 'dart:async';
import 'package:stockbit_clone2/core/errors/exceptions.dart';
import 'package:stockbit_clone2/core/errors/failures.dart';
import 'package:stockbit_clone2/core/utils/result.dart';
import 'package:stockbit_clone2/features/orderbook/data/datasources/orderbook_local_data_source.dart';
import 'package:stockbit_clone2/features/orderbook/data/datasources/orderbook_remote_data_source.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_data.dart';
import 'package:stockbit_clone2/features/orderbook/domain/repositories/orderbook_repository.dart';

class OrderbookRepositoryImpl implements OrderbookRepository {
  final OrderbookRemoteDataSource remoteDataSource;
  final OrderbookLocalDataSource localDataSource;

  OrderbookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<List<OrderbookData>>> getMultiOrderbooks() async {
    try {
      final remoteList = await remoteDataSource.fetchMultiOrderbooks();
      await localDataSource.cacheOrderbooks(remoteList);
      return Success(remoteList);
    } on ServerException catch (e) {
      // Fallback to cache if server fails
      try {
        final cachedList = await localDataSource.getCachedOrderbooks();
        return Success(cachedList);
      } catch (_) {
        return Error(
          ServerFailure(message: e.message, statusCode: e.statusCode),
        );
      }
    } catch (e) {
      return Error(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<OrderbookData>> getOrderbookBySymbol(String symbol) async {
    try {
      final data = await remoteDataSource.fetchOrderbookBySymbol(symbol);
      return Success(data);
    } on ServerException catch (e) {
      return Error(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Error(
        ServerFailure(message: 'Failed to fetch orderbook for $symbol: $e'),
      );
    }
  }

  @override
  Stream<OrderbookData> watchOrderbook(String symbol) {
    return remoteDataSource.streamOrderbookUpdates(symbol);
  }
}
