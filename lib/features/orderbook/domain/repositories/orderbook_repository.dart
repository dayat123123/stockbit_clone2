import 'package:stockbit_clone2/core/utils/result.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_data.dart';

abstract class OrderbookRepository {
  Future<Result<List<OrderbookData>>> getMultiOrderbooks();
  Future<Result<OrderbookData>> getOrderbookBySymbol(String symbol);
  Stream<OrderbookData> watchOrderbook(String symbol);
}
