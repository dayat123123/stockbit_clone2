import 'package:equatable/equatable.dart';
import 'package:stockbit_clone2/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthAuthenticatedState extends AuthState {
  final UserEntity user;

  const AuthAuthenticatedState(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticatedState extends AuthState {
  final String? errorMessage;

  const AuthUnauthenticatedState({this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
