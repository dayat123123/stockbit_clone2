import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String fullName;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
  });

  @override
  List<Object?> get props => [id, email, username, fullName];
}
