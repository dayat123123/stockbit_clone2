import 'package:stockbit_clone2/core/domain/orderbook/orderbook_data.dart';
import 'package:stockbit_clone2/core/domain/orderbook/orderbook_repository.dart';
import 'package:stockbit_clone2/core/usecase/usecase.dart';
import 'package:stockbit_clone2/core/utils/result.dart';

class GetMultiOrderbooksUseCase
    implements UseCase<List<OrderbookData>, List<String>> {
  final OrderbookRepository repository;

  GetMultiOrderbooksUseCase(this.repository);

  @override
  Future<Result<List<OrderbookData>>> call(List<String> params) async {
    return await repository.getMultiOrderbooks(params);
  }
}
