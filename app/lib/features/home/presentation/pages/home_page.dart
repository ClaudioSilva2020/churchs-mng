import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/banners_cubit.dart';
import '../widgets/banner_carousel.dart';
import 'create_post_page.dart';

/// Tela inicial pública (RF-002, RF-005 a RF-007).
/// Acessível a Não-membros, sem necessidade de login.
///
/// TODO(backend): substituir a lista mockada por
/// GET /api/banners/, /api/principles/ e /api/schedule/.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isMember = authState.role.isMember;
    final hasAutomation = authState.user?.hasAutomationAccess ?? false;
    final canPublish = authState.role.canPublishContent;
    final canManageMembers = authState.role.canManageMembers;

    return BlocProvider(
      create: (_) => BannersCubit(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/logo.png', height: 32),
              const SizedBox(width: 8),
              const Text('IBBE Connect'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Perfil',
              onPressed: () => context.push('/profile'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _QuickAccessGrid(
              isMember: isMember,
              hasAutomation: hasAutomation,
              canManageMembers: canManageMembers,
            ),
            const SizedBox(height: 24),
            Text('Avisos e Eventos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const BannerCarousel(),
          ],
        ),
        floatingActionButton: canPublish
            ? Builder(
                builder: (context) => FloatingActionButton.extended(
                  onPressed: () => _openCreatePost(context),
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Nova publicação'),
                ),
              )
            : null,
      ),
    );
  }

  void _openCreatePost(BuildContext context) {
    final bannersCubit = context.read<BannersCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bannersCubit,
          child: const CreatePostPage(),
        ),
      ),
    );
  }
}

/// Acesso rápido às áreas do app, conforme o papel do usuário (RF-001/RF-002).
class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({
    required this.isMember,
    required this.hasAutomation,
    required this.canManageMembers,
  });

  final bool isMember;
  final bool hasAutomation;
  final bool canManageMembers;

  @override
  Widget build(BuildContext context) {
    final items = <_QuickAccessItem>[
      _QuickAccessItem(
        icon: Icons.menu_book,
        label: 'Princípios',
        onTap: () => context.push('/principles'),
      ),
      _QuickAccessItem(
        icon: Icons.calendar_month,
        label: 'Programação',
        onTap: () => context.push('/schedule'),
      ),
      if (isMember)
        _QuickAccessItem(
          icon: Icons.groups,
          label: 'Ministérios',
          onTap: () => context.push('/ministries'),
        ),
      if (canManageMembers)
        _QuickAccessItem(
          icon: Icons.badge_outlined,
          label: 'Membros',
          onTap: () => context.push('/members'),
        ),
      if (hasAutomation)
        _QuickAccessItem(
          icon: Icons.settings_remote,
          label: 'Automação',
          onTap: () => context.push('/automation'),
        ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: items,
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  const _QuickAccessItem({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.navy),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: Theme.of(context).textTheme.titleSmall),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
