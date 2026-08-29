import 'package:get_it/get_it.dart';
import 'package:stockbit_clone2/core/blocs/auth/auth_bloc.dart';
import 'package:stockbit_clone2/core/navigation/cubit/navigation_cubit.dart';
import 'package:stockbit_clone2/core/workspace/bloc/workspace_bloc.dart';
import 'package:stockbit_clone2/core/data/orderbook/orderbook_local_data_source.dart';
import 'package:stockbit_clone2/core/data/orderbook/orderbook_remote_data_source.dart';
import 'package:stockbit_clone2/core/data/orderbook/orderbook_remote_data_source_impl.dart';
import 'package:stockbit_clone2/core/data/orderbook/orderbook_repository_impl.dart';
import 'package:stockbit_clone2/core/domain/orderbook/orderbook_repository.dart';
import 'package:stockbit_clone2/core/domain/orderbook/get_multi_orderbooks_usecase.dart';
import 'package:stockbit_clone2/core/domain/orderbook/get_orderbook_by_symbol_usecase.dart';
import 'package:stockbit_clone2/core/blocs/orderbook/orderbook_bloc.dart';
import 'package:stockbit_clone2/core/data/watchlist/watchlist_local_data_source.dart';
import 'package:stockbit_clone2/core/data/watchlist/watchlist_repository_impl.dart';
import 'package:stockbit_clone2/core/domain/watchlist/watchlist_repository.dart';
import 'package:stockbit_clone2/core/domain/watchlist/get_watchlist_items_usecase.dart';
import 'package:stockbit_clone2/core/blocs/watchlist/watchlist_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  //! 1. Auth & Navigation
  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory(() => AuthBloc());
  }

  if (!sl.isRegistered<NavigationCubit>()) {
    sl.registerFactory(() => NavigationCubit());
  }

  //! 2. Core - Workspace
  if (!sl.isRegistered<WorkspaceBloc>()) {
    sl.registerFactory(() => WorkspaceBloc());
  }

  //! 3. Watchlist Module
  if (!sl.isRegistered<WatchlistLocalDataSource>()) {
    sl.registerLazySingleton<WatchlistLocalDataSource>(
      () => WatchlistLocalDataSourceImpl(),
    );
  }

  if (!sl.isRegistered<WatchlistRepository>()) {
    sl.registerLazySingleton<WatchlistRepository>(
      () => WatchlistRepositoryImpl(localDataSource: sl()),
    );
  }

  if (!sl.isRegistered<GetWatchlistItemsUseCase>()) {
    sl.registerLazySingleton(() => GetWatchlistItemsUseCase(sl()));
  }

  if (!sl.isRegistered<WatchlistBloc>()) {
    sl.registerFactory(
      () => WatchlistBloc(getWatchlistItemsUseCase: sl()),
    );
  }

  //! 4. Orderbook Module
  if (!sl.isRegistered<OrderbookLocalDataSource>()) {
    sl.registerLazySingleton<OrderbookLocalDataSource>(
      () => OrderbookLocalDataSourceImpl(),
    );
  }

  if (!sl.isRegistered<OrderbookRemoteDataSource>()) {
    sl.registerLazySingleton<OrderbookRemoteDataSource>(
      () => OrderbookRemoteDataSourceImpl(
        localDataSource: sl(),
      ),
    );
  }

  if (!sl.isRegistered<OrderbookRepository>()) {
    sl.registerLazySingleton<OrderbookRepository>(
      () => OrderbookRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ),
    );
  }

  if (!sl.isRegistered<GetMultiOrderbooksUseCase>()) {
    sl.registerLazySingleton(() => GetMultiOrderbooksUseCase(sl()));
  }

  if (!sl.isRegistered<GetOrderbookBySymbolUseCase>()) {
    sl.registerLazySingleton(() => GetOrderbookBySymbolUseCase(sl()));
  }

  if (!sl.isRegistered<OrderbookBloc>()) {
    sl.registerFactory(
      () => OrderbookBloc(
        getMultiOrderbooksUseCase: sl(),
        getOrderbookBySymbolUseCase: sl(),
      ),
    );
  }
}
