import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Shell com navegação inferior, adaptada ao papel do usuário (RF-001/RF-002).
/// - Não-membro: apenas "Início".
/// - Membro/Servo/Líder/Mídia/Pastor: "Início" + "Ministérios".
/// - Usuário com `hasAutomationAccess`: + "Automação" (RF-004, RF-018 a RF-021).
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final isMember = state.role.isMember;
    final hasAutomation = state.user?.hasAutomationAccess ?? false;

    final destinations = <_NavDestination>[
      const _NavDestination(route: '/home', icon: Icons.home, label: 'Início'),
      if (isMember)
        const _NavDestination(route: '/ministries', icon: Icons.groups, label: 'Ministérios'),
      if (hasAutomation)
        const _NavDestination(route: '/automation', icon: Icons.settings_remote, label: 'Automação'),
    ];

    final currentIndex = destinations
        .indexWhere((d) => GoRouterState.of(context).uri.toString().startsWith(d.route))
        .clamp(0, destinations.length - 1);

    return Scaffold(
      body: child,
      bottomNavigationBar: destinations.length > 1
          ? BottomNavigationBar(
              currentIndex: currentIndex,
              items: destinations
                  .map((d) => BottomNavigationBarItem(icon: Icon(d.icon), label: d.label))
                  .toList(),
              onTap: (index) => context.go(destinations[index].route),
            )
          : null,
    );
  }
}

class _NavDestination {
  const _NavDestination({required this.route, required this.icon, required this.label});

  final String route;
  final IconData icon;
  final String label;
}
