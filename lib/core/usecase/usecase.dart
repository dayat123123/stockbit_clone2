import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/core/utils/result.dart';

abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
