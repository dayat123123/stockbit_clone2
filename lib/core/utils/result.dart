import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/core/errors/failures.dart';

abstract class Result<T> extends Equatable {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  Failure? get failureOrNull => isFailure ? (this as Error<T>).failure : null;

  R fold<R>(R Function(Failure failure) onError, R Function(T data) onSuccess) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else if (this is Error<T>) {
      return onError((this as Error<T>).failure);
    }
    throw StateError('Unknown Result type');
  }
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

class Error<T> extends Result<T> {
  final Failure failure;

  const Error(this.failure);

  @override
  List<Object?> get props => [failure];
}
