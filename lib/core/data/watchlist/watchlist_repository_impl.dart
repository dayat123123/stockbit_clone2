import 'package:stockbit_clone2/core/data/watchlist/watchlist_local_data_source.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_group.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_item.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_repository.dart';
import 'package:stockbit_clone2/core/errors/failures.dart';
import 'package:stockbit_clone2/core/utils/result.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource localDataSource;

  WatchlistRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<List<WatchlistItem>>> getWatchlistItems() async {
    try {
      final items = await localDataSource.getWatchlistItems();
      return Result.success(items);
    } catch (e) {
      return Result.failure(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<WatchlistGroup>>> getWatchlistGroups() async {
    try {
      final groups = await localDataSource.getWatchlistGroups();
      return Result.success(groups);
    } catch (e) {
      return Result.failure(CacheFailure(message: e.toString()));
    }
  }
}
