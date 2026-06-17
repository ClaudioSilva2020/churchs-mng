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
  const AuthLoginRequested({required this.username, required this.password});

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  @override
  List<Object?> get props => [username, firstName, lastName, email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// RF-003: atualização de dados de perfil do usuário autenticado.
class AuthProfileUpdateRequested extends AuthEvent {
  const AuthProfileUpdateRequested({this.firstName, this.lastName, this.email});

  final String? firstName;
  final String? lastName;
  final String? email;

  @override
  List<Object?> get props => [firstName, lastName, email];
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
