import 'package:stockbit_clone2/core/domain/orderbook/orderbook_data.dart';
import 'package:stockbit_clone2/core/utils/result.dart';

abstract class OrderbookRepository {
  Future<Result<OrderbookData>> getOrderbook(String symbol);
  Future<Result<List<OrderbookData>>> getMultiOrderbooks(List<String> symbols);
}
