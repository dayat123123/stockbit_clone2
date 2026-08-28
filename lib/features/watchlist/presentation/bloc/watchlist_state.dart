import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_group.dart';
import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_item.dart';

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
  final String selectedGroupId;
  final String searchQuery;
  final String? activeSymbol;
  final bool isPanelVisible;

  const WatchlistLoadedState({
    required this.groups,
    required this.selectedGroupId,
    this.searchQuery = '',
    this.activeSymbol,
    this.isPanelVisible = true,
  });

  WatchlistGroup get selectedGroup {
    try {
      return groups.firstWhere((g) => g.id == selectedGroupId);
    } catch (_) {
      return groups.first;
    }
  }

  List<WatchlistItem> get filteredItems {
    final raw = selectedGroup.items;
    if (searchQuery.trim().isEmpty) return raw;
    final q = searchQuery.trim().toLowerCase();
    return raw.where((item) {
      return item.symbol.toLowerCase().contains(q) ||
          item.name.toLowerCase().contains(q);
    }).toList();
  }

  WatchlistLoadedState copyWith({
    List<WatchlistGroup>? groups,
    String? selectedGroupId,
    String? searchQuery,
    String? activeSymbol,
    bool? isPanelVisible,
  }) {
    return WatchlistLoadedState(
      groups: groups ?? this.groups,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      searchQuery: searchQuery ?? this.searchQuery,
      activeSymbol: activeSymbol ?? this.activeSymbol,
      isPanelVisible: isPanelVisible ?? this.isPanelVisible,
    );
  }

  @override
  List<Object?> get props => [
    groups,
    selectedGroupId,
    searchQuery,
    activeSymbol,
    isPanelVisible,
  ];
}

class WatchlistErrorState extends WatchlistState {
  final String message;
  const WatchlistErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
