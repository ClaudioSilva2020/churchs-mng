import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/user_role_labels.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Tela de Perfil — ponto único de acesso a login/logout e dados do usuário.
/// Para Não-membro/visitante, exibe call-to-action de login/cadastro (RF-001).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final isAuthenticated = state.status == AuthStatus.authenticated;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: isAuthenticated ? _AuthenticatedProfile(state: state) : const _GuestProfile(),
      ),
    );
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_circle, size: 96, color: AppColors.navyLight),
        const SizedBox(height: 16),
        const Text(
          'Você está navegando como visitante.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push('/login'),
            child: const Text('Entrar'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.push('/register'),
            child: const Text('Criar conta'),
          ),
        ),
      ],
    );
  }
}

class _AuthenticatedProfile extends StatelessWidget {
  const _AuthenticatedProfile({required this.state});

  final AuthState state;

  @override
  Widget build(BuildContext context) {
    final user = state.user!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.gold,
              child: Icon(Icons.person, color: AppColors.navy, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                  Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
                  Text(roleLabel(user.role)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ),
      ],
    );
  }
}
