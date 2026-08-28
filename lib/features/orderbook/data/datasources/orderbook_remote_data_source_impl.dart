import 'dart:async';
import 'dart:math';
import 'package:stockbit_clone2/core/errors/exceptions.dart';
import 'package:stockbit_clone2/features/orderbook/data/datasources/orderbook_local_data_source.dart';
import 'package:stockbit_clone2/features/orderbook/data/datasources/orderbook_remote_data_source.dart';
import 'package:stockbit_clone2/features/orderbook/data/models/orderbook_data_model.dart';

class OrderbookRemoteDataSourceImpl implements OrderbookRemoteDataSource {
  final OrderbookLocalDataSource localDataSource;
  final _random = Random();

  OrderbookRemoteDataSourceImpl({required this.localDataSource});

  @override
  Future<List<OrderbookDataModel>> fetchMultiOrderbooks() async {
    // Simulates remote API network call with latency
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final cached = await localDataSource.getCachedOrderbooks();
      return cached;
    } catch (e) {
      throw ServerException(
        message: 'Failed to fetch orderbooks from server: $e',
      );
    }
  }

  @override
  Future<OrderbookDataModel> fetchOrderbookBySymbol(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      final list = await localDataSource.getCachedOrderbooks();
      final match = list.firstWhere(
        (element) =>
            element.summary.symbol.toUpperCase() == symbol.toUpperCase(),
        orElse: () =>
            throw ServerException(message: 'Symbol $symbol not found'),
      );
      return match;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error fetching symbol $symbol');
    }
  }

  @override
  Stream<OrderbookDataModel> streamOrderbookUpdates(String symbol) async* {
    final initial = await fetchOrderbookBySymbol(symbol);
    yield initial;

    // Stream small simulated ticks for orderbook depth
    while (true) {
      await Future.delayed(
        Duration(milliseconds: 1500 + _random.nextInt(1500)),
      );
      final jitter = (_random.nextDouble() - 0.5) * 2;
      final newPrice = (initial.summary.price + jitter).roundToDouble();
      final change = newPrice - initial.summary.prev;
      final changePct = (change / initial.summary.prev) * 100;

      final updatedSummary = initial.summary.copyWith(
        price: newPrice,
        change: change,
        changePercent: changePct,
      );

      yield OrderbookDataModel(
        summary: updatedSummary,
        entries: initial.entries,
        totalBidLot: initial.totalBidLot + _random.nextInt(100) - 50,
        totalOfferLot: initial.totalOfferLot + _random.nextInt(100) - 50,
      );
    }
  }
}
