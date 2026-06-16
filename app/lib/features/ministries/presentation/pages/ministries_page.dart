import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/ministry.dart';
import '../bloc/ministries_cubit.dart';

/// RF-009/RF-010: lista de ministérios do usuário autenticado.
/// Cada ministério dá acesso a chat, agenda e escala (RF-012 a RF-014),
/// e ao Louvor seu repertório (RF-016).
///
/// TODO(backend): substituir lista mockada por GET /api/ministries/.
class MinistriesPage extends StatelessWidget {
  const MinistriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final canManage = context.watch<AuthBloc>().state.role.canManageMinistries;

    return BlocProvider(
      create: (_) => MinistriesCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Ministérios')),
        body: BlocBuilder<MinistriesCubit, List<Ministry>>(
          builder: (context, ministries) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ministries.length,
              itemBuilder: (context, index) {
                final ministry = ministries[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.gold,
                      child: Icon(Icons.groups, color: AppColors.navy),
                    ),
                    title: Text(ministry.name),
                    subtitle: Text(ministry.description),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/ministries/${ministry.id}?name=${ministry.name}', extra: ministry),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: canManage
            ? Builder(
                builder: (context) => FloatingActionButton(
                  onPressed: () => _showCreateDialog(context),
                  tooltip: 'Criar ministério',
                  child: const Icon(Icons.add),
                ),
              )
            : null,
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final cubit = context.read<MinistriesCubit>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    var hasSchedule = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Novo ministério'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Possui escala de serviço'),
                    value: hasSchedule,
                    onChanged: (value) => setState(() => hasSchedule = value ?? false),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;
                    cubit.createMinistry(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      hasSchedule: hasSchedule,
                    );
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Criar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
