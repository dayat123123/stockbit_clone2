import 'package:stockbit_clone2/core/utils/result.dart';
import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_group.dart';

abstract class WatchlistRepository {
  Future<Result<List<WatchlistGroup>>> getWatchlistGroups();
}
