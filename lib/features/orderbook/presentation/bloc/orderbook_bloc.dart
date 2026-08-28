import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/usecase/usecase.dart';
import 'package:stockbit_clone2/features/orderbook/domain/entities/orderbook_data.dart';
import 'package:stockbit_clone2/features/orderbook/domain/usecases/get_multi_orderbooks_usecase.dart';
import 'package:stockbit_clone2/features/orderbook/domain/usecases/get_orderbook_by_symbol_usecase.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_event.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_state.dart';

/// Pure data bloc — fetches and caches orderbook data by symbol.
///
/// No window management, tab management, or layout logic here.
/// The workspace canvas reads orderbook data from this bloc's state
/// using the symbol stored in the window metadata.
class OrderbookBloc extends Bloc<OrderbookEvent, OrderbookState> {
  final GetMultiOrderbooksUseCase getMultiOrderbooksUseCase;
  final GetOrderbookBySymbolUseCase getOrderbookBySymbolUseCase;

  OrderbookBloc({
    required this.getMultiOrderbooksUseCase,
    required this.getOrderbookBySymbolUseCase,
  }) : super(const OrderbookInitialState()) {
    on<LoadMultiOrderbooksEvent>(_onLoadMultiOrderbooks);
    on<RefreshOrderbooksEvent>(_onRefreshOrderbooks);
    on<LoadOrderbookForSymbolEvent>(_onLoadOrderbookForSymbol);
  }

  // ─── Data Loading ─────────────────────────────────────────────────────────

  Future<void> _onLoadMultiOrderbooks(
    LoadMultiOrderbooksEvent _,
    Emitter<OrderbookState> emit,
  ) async {
    emit(const OrderbookLoadingState());
    final result = await getMultiOrderbooksUseCase(const NoParams());
    result.fold(
      (failure) => emit(OrderbookErrorState(message: failure.message)),
      (data) {
        final map = <String, OrderbookData>{};
        for (final ob in data) {
          map[ob.summary.symbol.toUpperCase()] = ob;
        }
        emit(OrderbookLoadedState(
          orderbooksBySymbol: map,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onRefreshOrderbooks(
    RefreshOrderbooksEvent _,
    Emitter<OrderbookState> emit,
  ) async {
    if (state is! OrderbookLoadedState) return;
    final current = state as OrderbookLoadedState;
    // Re-fetch all data
    final result = await getMultiOrderbooksUseCase(const NoParams());
    result.fold(
      (_) {}, // keep existing data on failure
      (data) {
        final map = Map<String, OrderbookData>.from(current.orderbooksBySymbol);
        for (final ob in data) {
          map[ob.summary.symbol.toUpperCase()] = ob;
        }
        emit(current.copyWith(
          orderbooksBySymbol: map,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadOrderbookForSymbol(
    LoadOrderbookForSymbolEvent event,
    Emitter<OrderbookState> emit,
  ) async {
    final symbol = event.symbol.toUpperCase();

    // If already loaded, check state
    if (state is OrderbookLoadedState) {
      final current = state as OrderbookLoadedState;
      if (current.orderbooksBySymbol.containsKey(symbol)) return;
    }

    final res = await getOrderbookBySymbolUseCase(
        GetOrderbookParams(symbol: symbol));

    res.fold((_) {}, (data) {
      if (state is OrderbookLoadedState) {
        final current = state as OrderbookLoadedState;
        final map =
            Map<String, OrderbookData>.from(current.orderbooksBySymbol);
        map[symbol] = data;
        emit(current.copyWith(orderbooksBySymbol: map));
      } else {
        emit(OrderbookLoadedState(
          orderbooksBySymbol: {symbol: data},
          lastUpdated: DateTime.now(),
        ));
      }
    });
  }
}
