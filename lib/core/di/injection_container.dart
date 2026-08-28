import 'package:get_it/get_it.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/features/orderbook/data/datasources/orderbook_local_data_source.dart';
import 'package:stockbit_clone2/features/orderbook/data/datasources/orderbook_remote_data_source.dart';
import 'package:stockbit_clone2/features/orderbook/data/datasources/orderbook_remote_data_source_impl.dart';
import 'package:stockbit_clone2/features/orderbook/data/repositories/orderbook_repository_impl.dart';
import 'package:stockbit_clone2/features/orderbook/domain/repositories/orderbook_repository.dart';
import 'package:stockbit_clone2/features/orderbook/domain/usecases/get_multi_orderbooks_usecase.dart';
import 'package:stockbit_clone2/features/orderbook/domain/usecases/get_orderbook_by_symbol_usecase.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_bloc.dart';
import 'package:stockbit_clone2/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:stockbit_clone2/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:stockbit_clone2/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:stockbit_clone2/features/watchlist/domain/usecases/get_watchlist_items_usecase.dart';
import 'package:stockbit_clone2/features/watchlist/presentation/bloc/watchlist_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  //! Core - Workspace
  sl.registerFactory(() => WorkspaceBloc());

  //! Features - Watchlist
  // Bloc
  sl.registerFactory(
    () => WatchlistBloc(getWatchlistItemsUseCase: sl()),
  );
  // Use case
  sl.registerLazySingleton(() => GetWatchlistItemsUseCase(sl()));
  // Repository
  sl.registerLazySingleton<WatchlistRepository>(
    () => WatchlistRepositoryImpl(localDataSource: sl()),
  );
  // Data source
  sl.registerLazySingleton<WatchlistLocalDataSource>(
    () => WatchlistLocalDataSourceImpl(),
  );

  //! Features - Orderbook
  // Bloc
  sl.registerFactory(
    () => OrderbookBloc(
      getMultiOrderbooksUseCase: sl(),
      getOrderbookBySymbolUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMultiOrderbooksUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderbookBySymbolUseCase(sl()));

  // Repository
  sl.registerLazySingleton<OrderbookRepository>(
    () => OrderbookRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<OrderbookRemoteDataSource>(
    () => OrderbookRemoteDataSourceImpl(
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<OrderbookLocalDataSource>(
    () => OrderbookLocalDataSourceImpl(),
  );
}
