import 'package:stockbit_clone2/core/domain/watchlist/watchlist_group.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_item.dart';
import 'package:stockbit_clone2/core/utils/result.dart';

abstract class WatchlistRepository {
  Future<Result<List<WatchlistItem>>> getWatchlistItems();
  Future<Result<List<WatchlistGroup>>> getWatchlistGroups();
}
