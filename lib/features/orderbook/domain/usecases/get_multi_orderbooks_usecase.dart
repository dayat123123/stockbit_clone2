import 'package:stockbit_clone2/core/usecase/usecase.dart';
import 'package:stockbit_clone2/core/utils/result.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_data.dart';
import 'package:stockbit_clone2/features/orderbook/domain/repositories/orderbook_repository.dart';

class GetMultiOrderbooksUseCase
    implements UseCase<List<OrderbookData>, NoParams> {
  final OrderbookRepository repository;

  GetMultiOrderbooksUseCase(this.repository);

  @override
  Future<Result<List<OrderbookData>>> call(NoParams params) {
    return repository.getMultiOrderbooks();
  }
}
