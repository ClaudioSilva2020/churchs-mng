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
  }

  final AuthRepository _authRepository;

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = await _authRepository.getCurrentUser();
    emit(user != null ? AuthState.authenticated(user) : const AuthState.unauthenticated());
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.login(email: event.email, password: event.password);
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.loading());
    try {
      final user = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(const AuthState.unauthenticated());
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
}

const _devNames = {
  UserRole.nonMember: 'Visitante',
  UserRole.member: 'Membro Teste',
  UserRole.servant: 'Servo Teste',
  UserRole.leader: 'Líder Teste',
  UserRole.media: 'Mídia Teste',
  UserRole.pastor: 'Pastor Teste',
};
