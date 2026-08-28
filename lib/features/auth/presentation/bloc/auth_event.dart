import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmittedEvent extends AuthEvent {
  final String username;
  final String password;

  const LoginSubmittedEvent({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
