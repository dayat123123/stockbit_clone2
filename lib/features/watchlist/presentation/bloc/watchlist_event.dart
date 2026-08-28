import 'package:equatable/equatable.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWatchlistEvent extends WatchlistEvent {
  const LoadWatchlistEvent();
}

class SelectWatchlistGroupEvent extends WatchlistEvent {
  final String groupId;
  const SelectWatchlistGroupEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class FilterWatchlistQueryEvent extends WatchlistEvent {
  final String query;
  const FilterWatchlistQueryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectActiveStockEvent extends WatchlistEvent {
  final String symbol;
  const SelectActiveStockEvent(this.symbol);

  @override
  List<Object?> get props => [symbol];
}

class ToggleWatchlistPanelEvent extends WatchlistEvent {
  const ToggleWatchlistPanelEvent();
}
