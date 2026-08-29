import 'package:stockbit_clone2/core/domain/orderbook/orderbook_data.dart';
import 'package:stockbit_clone2/core/domain/orderbook/orderbook_repository.dart';
import 'package:stockbit_clone2/core/usecase/usecase.dart';
import 'package:stockbit_clone2/core/utils/result.dart';

class GetOrderbookBySymbolUseCase implements UseCase<OrderbookData, String> {
  final OrderbookRepository repository;

  GetOrderbookBySymbolUseCase(this.repository);

  @override
  Future<Result<OrderbookData>> call(String params) async {
    return await repository.getOrderbook(params);
  }
}
