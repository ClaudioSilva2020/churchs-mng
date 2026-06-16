import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/automation/presentation/pages/automation_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/institutional/presentation/pages/principles_page.dart';
import '../../features/institutional/presentation/pages/schedule_page.dart';
import '../../features/ministries/domain/entities/ministry.dart';
import '../../features/ministries/presentation/pages/ministries_page.dart';
import '../../features/ministries/presentation/pages/ministry_detail_page.dart';
import '../../features/members/presentation/pages/members_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/app_shell.dart';

/// Rotas e guards de navegação.
///
/// - `/login`, `/register`: públicas, fora do shell.
/// - `/home`: pública (RF-002 — não-membro/visitante).
/// - `/ministries`: requer usuário autenticado com `role.isMember`.
/// - `/automation`: requer `hasAutomationAccess` (RF-004).
GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: _AuthBlocListenable(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (authState.status == AuthStatus.unknown) return null;

      final isAuthenticated = authState.status == AuthStatus.authenticated;

      if (state.matchedLocation.startsWith('/ministries') && !isAuthenticated) {
        return '/login';
      }

      if (state.matchedLocation == '/automation' &&
          !(authState.user?.hasAutomationAccess ?? false)) {
        return '/home';
      }

      if (state.matchedLocation.startsWith('/members') &&
          !(authState.role.canManageMembers)) {
        return '/home';
      }

      if (isAuthRoute && isAuthenticated) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/principles', builder: (context, state) => const PrinciplesPage()),
      GoRoute(path: '/schedule', builder: (context, state) => const SchedulePage()),
      GoRoute(
        path: '/ministries/:id',
        builder: (context, state) {
          final ministry = state.extra as Ministry?;
          return MinistryDetailPage(
            ministryId: state.pathParameters['id']!,
            ministryName: ministry?.name ?? state.uri.queryParameters['name'] ?? 'Ministério',
            hasSchedule: ministry?.hasSchedule ?? false,
            hasRepertoire: ministry?.hasRepertoire ?? false,
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          GoRoute(path: '/ministries', builder: (context, state) => const MinistriesPage()),
          GoRoute(path: '/automation', builder: (context, state) => const AutomationPage()),
          GoRoute(path: '/members', builder: (context, state) => const MembersPage()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
        ],
      ),
    ],
  );
}

/// Adapta o `Stream` do [AuthBloc] para [Listenable], conforme exigido
/// por `GoRouter.refreshListenable`.
class _AuthBlocListenable extends ChangeNotifier {
  _AuthBlocListenable(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
