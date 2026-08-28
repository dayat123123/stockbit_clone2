import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/usecase/usecase.dart';
import 'package:stockbit_clone2/features/watchlist/domain/usecases/get_watchlist_items_usecase.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_event.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final GetWatchlistItemsUseCase getWatchlistItemsUseCase;

  WatchlistBloc({required this.getWatchlistItemsUseCase})
      : super(const WatchlistInitialState()) {
    on<LoadWatchlistEvent>(_onLoadWatchlist);
    on<SelectWatchlistGroupEvent>(_onSelectWatchlistGroup);
    on<FilterWatchlistQueryEvent>(_onFilterWatchlistQuery);
    on<SelectActiveStockEvent>(_onSelectActiveStock);
    on<ToggleWatchlistPanelEvent>(_onToggleWatchlistPanel);
  }

  Future<void> _onLoadWatchlist(
    LoadWatchlistEvent event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoadingState());
    final result = await getWatchlistItemsUseCase(const NoParams());

    result.fold(
      (failure) {
        emit(WatchlistErrorState(failure.message));
      },
      (groups) {
        emit(WatchlistLoadedState(
          groups: groups,
          selectedGroupId: groups.isNotEmpty ? groups.first.id : '',
          activeSymbol: groups.isNotEmpty && groups.first.items.isNotEmpty
              ? groups.first.items.first.symbol
              : null,
          isPanelVisible: true,
        ));
      },
    );
  }

  void _onSelectWatchlistGroup(
    SelectWatchlistGroupEvent event,
    Emitter<WatchlistState> emit,
  ) {
    if (state is WatchlistLoadedState) {
      final current = state as WatchlistLoadedState;
      emit(current.copyWith(selectedGroupId: event.groupId));
    }
  }

  void _onFilterWatchlistQuery(
    FilterWatchlistQueryEvent event,
    Emitter<WatchlistState> emit,
  ) {
    if (state is WatchlistLoadedState) {
      final current = state as WatchlistLoadedState;
      emit(current.copyWith(searchQuery: event.query));
    }
  }

  void _onSelectActiveStock(
    SelectActiveStockEvent event,
    Emitter<WatchlistState> emit,
  ) {
    if (state is WatchlistLoadedState) {
      final current = state as WatchlistLoadedState;
      emit(current.copyWith(activeSymbol: event.symbol));
    }
  }

  void _onToggleWatchlistPanel(
    ToggleWatchlistPanelEvent event,
    Emitter<WatchlistState> emit,
  ) {
    if (state is WatchlistLoadedState) {
      final current = state as WatchlistLoadedState;
      emit(current.copyWith(isPanelVisible: !current.isPanelVisible));
    }
  }
}
