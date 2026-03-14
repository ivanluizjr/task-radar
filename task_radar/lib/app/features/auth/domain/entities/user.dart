import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? image;
  final String role;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image,
    required this.role,
  });

  String get fullName => '$firstName $lastName';

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    firstName,
    lastName,
    image,
    role,
  ];
}
