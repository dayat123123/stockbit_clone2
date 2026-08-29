import 'package:stockbit_clone2/core/domain/watchlist/watchlist_group.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_item.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_repository.dart';
import 'package:stockbit_clone2/core/usecase/usecase.dart';
import 'package:stockbit_clone2/core/utils/result.dart';

class GetWatchlistItemsUseCase
    implements
        UseCase<
          ({List<WatchlistItem> items, List<WatchlistGroup> groups}),
          NoParams
        > {
  final WatchlistRepository repository;

  GetWatchlistItemsUseCase(this.repository);

  @override
  Future<Result<({List<WatchlistItem> items, List<WatchlistGroup> groups})>>
  call(NoParams params) async {
    final itemsResult = await repository.getWatchlistItems();
    final groupsResult = await repository.getWatchlistGroups();

    if (itemsResult.isFailure) {
      return Result.failure(itemsResult.failureOrNull!);
    }
    if (groupsResult.isFailure) {
      return Result.failure(groupsResult.failureOrNull!);
    }

    return Result.success((
      items: itemsResult.dataOrNull ?? [],
      groups: groupsResult.dataOrNull ?? [],
    ));
  }
}
