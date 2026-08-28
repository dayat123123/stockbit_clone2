import 'package:get_it/get_it.dart';
import 'package:stockbit_clone2/features/orderbook/data/datasources/orderbook_local_data_source.dart';
import 'package:stockbit_clone2/features/orderbook/data/datasources/orderbook_remote_data_source.dart';
import 'package:stockbit_clone2/features/orderbook/data/datasources/orderbook_remote_data_source_impl.dart';
import 'package:stockbit_clone2/features/orderbook/data/repositories/orderbook_repository_impl.dart';
import 'package:stockbit_clone2/features/orderbook/domain/repositories/orderbook_repository.dart';
import 'package:stockbit_clone2/features/orderbook/domain/usecases/get_multi_orderbooks_usecase.dart';
import 'package:stockbit_clone2/features/orderbook/domain/usecases/get_orderbook_by_symbol_usecase.dart';
import 'package:stockbit_clone2/features/orderbook/presentation/bloc/orderbook_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
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
