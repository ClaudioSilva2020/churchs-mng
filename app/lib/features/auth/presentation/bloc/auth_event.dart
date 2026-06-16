part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Disparado na inicialização do app para verificar sessão existente.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Login local de demonstração, sem chamar a API (backend ainda não
/// disponível). Permite validar telas restritas por papel durante o
/// desenvolvimento do template.
///
/// TODO(backend): remover quando o login real estiver disponível.
class AuthDevLoginRequested extends AuthEvent {
  const AuthDevLoginRequested(this.role);

  final UserRole role;

  @override
  List<Object?> get props => [role];
}
