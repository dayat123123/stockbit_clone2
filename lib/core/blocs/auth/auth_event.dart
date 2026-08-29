import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginWithEmailEvent extends AuthEvent {
  final String usernameOrEmail;
  final String password;

  const LoginWithEmailEvent({
    required this.usernameOrEmail,
    required this.password,
  });

  @override
  List<Object?> get props => [usernameOrEmail, password];
}

class LoginWithGoogleEvent extends AuthEvent {
  const LoginWithGoogleEvent();
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
