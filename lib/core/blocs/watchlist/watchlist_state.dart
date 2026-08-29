import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_bloc.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_group.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_item.dart';

abstract class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

class WatchlistInitialState extends WatchlistState {
  const WatchlistInitialState();
}

class WatchlistLoadingState extends WatchlistState {
  const WatchlistLoadingState();
}

class WatchlistLoadedState extends WatchlistState {
  final List<WatchlistGroup> groups;
  final String activeGroupId;
  final String activeSymbol;

  const WatchlistLoadedState({
    required this.groups,
    required this.activeGroupId,
    required this.activeSymbol,
  });

  WatchlistGroup get activeGroup {
    if (groups.isEmpty) {
      return const WatchlistGroup(id: 'all', title: 'Watchlist', symbols: []);
    }
    return groups.firstWhere(
      (g) => g.id == activeGroupId,
      orElse: () => groups.first,
    );
  }

  /// List of symbols saved in the active watchlist group
  List<String> get currentGroupSymbols => activeGroup.symbols;

  /// List of resolved WatchlistItem objects for the active group
  List<WatchlistItem> get items =>
      currentGroupSymbols.map((s) => WatchlistBloc.resolveStockItem(s)).toList();

  /// Resolved WatchlistItem for the currently inspected stock
  WatchlistItem get activeItem => WatchlistBloc.resolveStockItem(activeSymbol);

  /// Check if the currently viewed stock is in the active watchlist
  bool get isCurrentStockInWatchlist =>
      currentGroupSymbols.any((s) => s.toUpperCase() == activeSymbol.toUpperCase());

  WatchlistLoadedState copyWith({
    List<WatchlistGroup>? groups,
    String? activeGroupId,
    String? activeSymbol,
  }) {
    return WatchlistLoadedState(
      groups: groups ?? this.groups,
      activeGroupId: activeGroupId ?? this.activeGroupId,
      activeSymbol: activeSymbol ?? this.activeSymbol,
    );
  }

  @override
  List<Object?> get props => [groups, activeGroupId, activeSymbol];
}

class WatchlistErrorState extends WatchlistState {
  final String message;

  const WatchlistErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
