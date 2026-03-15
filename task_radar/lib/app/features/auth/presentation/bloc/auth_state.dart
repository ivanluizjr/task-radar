import 'package:equatable/equatable.dart';
import 'package:task_radar/app/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado intermediário emitido apenas ao refrescar o perfil já autenticado.
/// Carrega o usuário anterior para evitar piscar durante a transição.
class AuthRefreshing extends AuthState {
  final User user;

  const AuthRefreshing(this.user);

  @override
  List<Object?> get props => [user];
}
