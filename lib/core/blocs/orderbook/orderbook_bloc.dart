import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/blocs/orderbook/orderbook_event.dart';
import 'package:stockbit_clone2/core/blocs/orderbook/orderbook_state.dart';
import 'package:stockbit_clone2/core/domain/orderbook/orderbook_data.dart';
import 'package:stockbit_clone2/core/domain/orderbook/get_multi_orderbooks_usecase.dart';
import 'package:stockbit_clone2/core/domain/orderbook/get_orderbook_by_symbol_usecase.dart';

class OrderbookBloc extends Bloc<OrderbookEvent, OrderbookState> {
  final GetMultiOrderbooksUseCase getMultiOrderbooksUseCase;
  final GetOrderbookBySymbolUseCase getOrderbookBySymbolUseCase;

  OrderbookBloc({
    required this.getMultiOrderbooksUseCase,
    required this.getOrderbookBySymbolUseCase,
  }) : super(const OrderbookInitialState()) {
    on<LoadOrderbookEvent>(_onLoadOrderbook);
    on<LoadMultiOrderbooksEvent>(_onLoadMultiOrderbooks);
  }

  Future<void> _onLoadOrderbook(
    LoadOrderbookEvent event,
    Emitter<OrderbookState> emit,
  ) async {
    final result = await getOrderbookBySymbolUseCase(event.symbol);
    result.when(
      success: (data) {
        if (state is OrderbookLoadedState) {
          final current = state as OrderbookLoadedState;
          final updated = Map<String, OrderbookData>.from(current.orderbooks);
          updated[data.symbol] = data;
          emit(
            current.copyWith(orderbooks: updated, activeSymbol: event.symbol),
          );
        } else {
          emit(
            OrderbookLoadedState(
              orderbooks: {data.symbol: data},
              activeSymbol: event.symbol,
            ),
          );
        }
      },
      failure: (failure) => emit(OrderbookErrorState(failure.message)),
    );
  }

  Future<void> _onLoadMultiOrderbooks(
    LoadMultiOrderbooksEvent event,
    Emitter<OrderbookState> emit,
  ) async {
    emit(const OrderbookLoadingState());
    final result = await getMultiOrderbooksUseCase(event.symbols);
    result.when(
      success: (list) {
        final Map<String, OrderbookData> map = {
          for (var item in list) item.symbol: item,
        };
        emit(
          OrderbookLoadedState(
            orderbooks: map,
            activeSymbol: event.symbols.isNotEmpty ? event.symbols.first : '',
          ),
        );
      },
      failure: (failure) => emit(OrderbookErrorState(failure.message)),
    );
  }
}
