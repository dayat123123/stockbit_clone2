import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/core/usecase/usecase.dart';
import 'package:stockbit_clone2/core/utils/result.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_data.dart';
import 'package:stockbit_clone2/features/orderbook/domain/repositories/orderbook_repository.dart';

class GetOrderbookBySymbolUseCase
    implements UseCase<OrderbookData, GetOrderbookParams> {
  final OrderbookRepository repository;

  GetOrderbookBySymbolUseCase(this.repository);

  @override
  Future<Result<OrderbookData>> call(GetOrderbookParams params) {
    return repository.getOrderbookBySymbol(params.symbol);
  }
}

class GetOrderbookParams extends Equatable {
  final String symbol;

  const GetOrderbookParams({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}
