import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_item.dart';

/// Domain Entity representing a collection/group of Watchlist items (e.g. All, Banking, LQ45).
class WatchlistGroup extends Equatable {
  final String id;
  final String title;
  final List<WatchlistItem> items;

  const WatchlistGroup({
    required this.id,
    required this.title,
    required this.items,
  });

  @override
  List<Object?> get props => [id, title, items];
}
