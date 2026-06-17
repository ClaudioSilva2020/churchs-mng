import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/user_role.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthState.unknown()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthDevLoginRequested>(_onDevLoginRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    try {
      final user = await _authRepository.getCurrentUser();
      emit(user != null ? AuthState.authenticated(user) : const AuthState.unauthenticated());
    } catch (_) {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.login(username: event.username, password: event.password);
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.failure(_dioError(e, 'Usuário ou senha incorretos.')));
    }
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.register(
        username: event.username,
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
      );
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.failure(_dioError(e, 'Erro ao criar conta.')));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> _onProfileUpdateRequested(
      AuthProfileUpdateRequested event, Emitter<AuthState> emit) async {
    try {
      final user = await _authRepository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
      );
      emit(AuthState.authenticated(user));
    } catch (_) {
      // Não altera o estado de auth — a UI exibe o erro via SnackBar.
    }
  }

  Future<void> _onDevLoginRequested(AuthDevLoginRequested event, Emitter<AuthState> emit) async {
    final user = AppUser(
      id: 'dev-${event.role.name}',
      name: _devNames[event.role] ?? 'Usuário de teste',
      email: '${event.role.name}@ibbe.dev',
      role: event.role,
      hasAutomationAccess: event.role == UserRole.pastor,
    );
    emit(AuthState.authenticated(user));
  }

  /// Extrai a mensagem de erro legível de uma DioException (resposta DRF).
  /// Quando o servidor retorna um JSON com erros de validação, mostra o
  /// texto em português vindo do Django em vez da mensagem técnica do Dio.
  String _dioError(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data.isNotEmpty) {
        final lines = <String>[];
        data.forEach((_, val) {
          if (val is List) {
            lines.add(val.map((v) => v.toString()).join(', '));
          } else {
            lines.add(val.toString());
          }
        });
        if (lines.isNotEmpty) return lines.join('\n');
      }
    }
    return fallback;
  }
}

const _devNames = {
  UserRole.nonMember: 'Visitante',
  UserRole.member: 'Membro Teste',
  UserRole.servant: 'Servo Teste',
  UserRole.leader: 'Líder Teste',
  UserRole.media: 'Mídia Teste',
  UserRole.pastor: 'Pastor Teste',
};
