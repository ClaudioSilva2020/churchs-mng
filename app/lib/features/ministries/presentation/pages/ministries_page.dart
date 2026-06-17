import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/ministries_api_service.dart';
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
      create: (_) => MinistriesCubit(injector<MinistriesApiService>()),
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
                    trailing: canManage
                        ? PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'delete') {
                                final cubit = context.read<MinistriesCubit>();
                                final messenger = ScaffoldMessenger.of(context);
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogCtx) => AlertDialog(
                                    title: const Text('Excluir ministério'),
                                    content: Text(
                                        'Deseja excluir "${ministry.name}"? Esta ação não pode ser desfeita.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(dialogCtx).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                            backgroundColor: Colors.red.shade700),
                                        onPressed: () => Navigator.of(dialogCtx).pop(true),
                                        child: const Text('Excluir'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed != true) return;
                                final ok = await cubit.deleteMinistry(ministry.id);
                                messenger.showSnackBar(SnackBar(
                                  content: Text(ok
                                      ? 'Ministério excluído.'
                                      : 'Erro ao excluir ministério.'),
                                  backgroundColor:
                                      ok ? Colors.green.shade700 : Colors.red.shade700,
                                ));
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Excluir', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const Icon(Icons.chevron_right),
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
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    Navigator.of(dialogContext).pop();
                    final ok = await cubit.createMinistry(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      hasSchedule: hasSchedule,
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok ? 'Ministério criado!' : 'Erro ao criar. Verifique se está autenticado.'),
                      backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
                    ));
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
