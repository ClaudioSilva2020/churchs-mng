import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/user_role.dart';
import '../../../../core/constants/user_role_labels.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/member.dart';
import '../bloc/members_cubit.dart';

/// RF-017b/RF-017c: perfil de um membro, com troca de papel e remoção.
class MemberDetailPage extends StatelessWidget {
  const MemberDetailPage({super.key, required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MembersCubit, List<Member>>(
      builder: (context, members) {
        final current = members.firstWhere(
          (m) => m.id == member.id,
          orElse: () => member,
        );

        return Scaffold(
          appBar: AppBar(title: Text(current.name)),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
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
                          Text(current.name, style: Theme.of(context).textTheme.titleLarge),
                          Text(current.email, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Papel', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserRole>(
                  initialValue: current.role,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: UserRole.values
                      .map((role) => DropdownMenuItem(value: role, child: Text(roleLabel(role))))
                      .toList(),
                  onChanged: (role) {
                    if (role != null) {
                      context.read<MembersCubit>().updateRole(current.id, role);
                    }
                  },
                ),
                if (current.ministries.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Ministérios', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: current.ministries.map((m) => Chip(label: Text(m))).toList(),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    onPressed: () => _confirmRemove(context, current),
                    icon: const Icon(Icons.person_remove_outlined),
                    label: const Text('Remover membro'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmRemove(BuildContext context, Member current) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover membro'),
        content: Text('Tem certeza que deseja remover ${current.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<MembersCubit>().removeMember(current.id);
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
