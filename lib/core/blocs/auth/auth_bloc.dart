import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/blocs/auth/auth_event.dart';
import 'package:stockbit_clone2/core/blocs/auth/auth_state.dart';
import 'package:stockbit_clone2/core/domain/entities/user_entity.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthUnauthenticatedState()) {
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    await Future.delayed(const Duration(milliseconds: 600));

    final user = UserEntity(
      id: 'user_1',
      email: event.usernameOrEmail.contains('@')
          ? event.usernameOrEmail
          : '${event.usernameOrEmail}@stockbit.com',
      username: event.usernameOrEmail,
      fullName: 'Professional Trader',
    );
    emit(AuthAuthenticatedState(user));
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    await Future.delayed(const Duration(milliseconds: 600));

    final user = const UserEntity(
      id: 'google_user_1',
      email: 'trader@gmail.com',
      username: 'GoogleTrader',
      fullName: 'Google Authenticated Trader',
    );
    emit(AuthAuthenticatedState(user));
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthUnauthenticatedState());
  }
}
