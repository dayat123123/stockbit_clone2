import 'package:stockbit_clone2/core/usecase/usecase.dart';
import 'package:stockbit_clone2/core/utils/result.dart';
import 'package:stockbit_clone2/features/watchlist/domain/entities/watchlist_group.dart';
import 'package:stockbit_clone2/features/watchlist/domain/repositories/watchlist_repository.dart';

class GetWatchlistItemsUseCase implements UseCase<List<WatchlistGroup>, NoParams> {
  final WatchlistRepository repository;

  const GetWatchlistItemsUseCase(this.repository);

  @override
  Future<Result<List<WatchlistGroup>>> call(NoParams params) {
    return repository.getWatchlistGroups();
  }
}
