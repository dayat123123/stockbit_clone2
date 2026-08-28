import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String accountType;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.accountType = 'PRO TRADER',
  });

  @override
  List<Object?> get props => [id, username, email, fullName, accountType];
}
