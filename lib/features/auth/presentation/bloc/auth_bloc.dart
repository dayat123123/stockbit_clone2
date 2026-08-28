import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stockbit_clone2/core/utils/desktop_window_helper.dart';
import 'package:stockbit_clone2/features/auth/domain/entities/user_entity.dart';
import 'package:stockbit_clone2/features/auth/presentation/bloc/auth_event.dart';
import 'package:stockbit_clone2/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthUnauthenticatedState()) {
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    await Future.delayed(const Duration(milliseconds: 500));

    if (event.username.isNotEmpty && event.password.isNotEmpty) {
      emit(
        AuthAuthenticatedState(
          UserEntity(
            id: 'usr_001',
            username: event.username,
            email: '${event.username.toLowerCase()}@stockbit.com',
            fullName: 'Pro Trader (${event.username})',
          ),
        ),
      );
      // Automatically expand OS desktop window to full resizable terminal
      await DesktopWindowHelper.setToTerminalMode();
    } else {
      emit(
        const AuthUnauthenticatedState(
          errorMessage: 'Please enter username and password',
        ),
      );
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthUnauthenticatedState());
    await DesktopWindowHelper.setToLoginMode();
  }
}
