import 'package:stockbit_clone2/core/errors/failures.dart';
import 'package:stockbit_clone2/core/utils/result.dart';
import 'package:stockbit_clone2/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_group.dart';
import 'package:stockbit_clone2/features/watchlist/domain/repositories/watchlist_repository.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource localDataSource;

  const WatchlistRepositoryImpl({required this.localDataSource});

  @override
  Future<Result<List<WatchlistGroup>>> getWatchlistGroups() async {
    try {
      final groups = await localDataSource.getWatchlistGroups();
      return Success(groups);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }
}
