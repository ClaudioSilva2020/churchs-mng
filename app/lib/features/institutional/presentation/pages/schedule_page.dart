import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/institutional_api_service.dart';
import '../../domain/entities/service_schedule_item.dart';
import '../bloc/schedule_cubit.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleCubit(injector<InstitutionalApiService>()),
      child: const _ScheduleView(),
    );
  }
}

class _ScheduleView extends StatelessWidget {
  const _ScheduleView();

  @override
  Widget build(BuildContext context) {
    final canEdit = context.watch<AuthBloc>().state.role.canPublishContent;

    return Scaffold(
      appBar: AppBar(title: const Text('Programação')),
      body: BlocBuilder<ScheduleCubit, List<ServiceScheduleItem>>(
        builder: (context, items) {
          if (items.isEmpty) {
            return const Center(child: Text('Nenhum item cadastrado.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.navy,
                    child: Text(
                      item.time.length >= 2 ? item.time.substring(0, 2) : item.time,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text(
                    [
                      '${item.dayOfWeek} · ${item.time}',
                      if (item.subtitle != null) item.subtitle!,
                    ].join('\n'),
                  ),
                  isThreeLine: item.subtitle != null,
                  trailing: canEdit
                      ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showItemDialog(context, item: item);
                            } else if (value == 'delete') {
                              _confirmDelete(context, item);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(children: [
                                Icon(Icons.edit_outlined),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ]),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [
                                Icon(Icons.delete_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir', style: TextStyle(color: Colors.red)),
                              ]),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: canEdit
          ? Builder(
              builder: (ctx) => FloatingActionButton(
                onPressed: () => _showItemDialog(ctx),
                child: const Icon(Icons.add),
              ),
            )
          : null,
    );
  }

  void _showItemDialog(BuildContext context, {ServiceScheduleItem? item}) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => _ScheduleItemDialog(
        cubit: context.read<ScheduleCubit>(),
        messenger: ScaffoldMessenger.of(context),
        item: item,
      ),
    );
  }

  void _confirmDelete(BuildContext context, ServiceScheduleItem item) {
    final cubit = context.read<ScheduleCubit>();
    final messenger = ScaffoldMessenger.of(context);
    showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Excluir item'),
        content: Text('Excluir "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      final ok = await cubit.deleteItem(item.id);
      messenger.showSnackBar(SnackBar(
        content: Text(ok ? 'Item removido.' : 'Erro ao remover.'),
        backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
      ));
    });
  }
}

class _ScheduleItemDialog extends StatefulWidget {
  const _ScheduleItemDialog({
    required this.cubit,
    required this.messenger,
    this.item,
  });

  final ScheduleCubit cubit;
  final ScaffoldMessengerState messenger;
  final ServiceScheduleItem? item;

  @override
  State<_ScheduleItemDialog> createState() => _ScheduleItemDialogState();
}

class _ScheduleItemDialogState extends State<_ScheduleItemDialog> {
  static const _days = [
    'Domingo',
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
  ];

  late String _day;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _day = (item != null && _days.contains(item.dayOfWeek)) ? item.dayOfWeek : _days.first;
    _timeCtrl = TextEditingController(text: item?.time ?? '');
    _titleCtrl = TextEditingController(text: item?.title ?? '');
    _subtitleCtrl = TextEditingController(text: item?.subtitle ?? '');
  }

  @override
  void dispose() {
    _timeCtrl.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return AlertDialog(
      title: Text(isEdit ? 'Editar item' : 'Novo item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _day,
              decoration: const InputDecoration(labelText: 'Dia da semana'),
              items: _days
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (v) => setState(() => _day = v ?? _days.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _timeCtrl,
              decoration: const InputDecoration(
                labelText: 'Horário',
                hintText: '19:00',
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subtitleCtrl,
              decoration: const InputDecoration(labelText: 'Subtítulo (opcional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(isEdit ? 'Salvar' : 'Adicionar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final time = _timeCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    if (time.isEmpty || title.isEmpty) return;

    Navigator.of(context).pop();

    final subtitle = _subtitleCtrl.text.trim().isEmpty ? null : _subtitleCtrl.text.trim();
    final isEdit = widget.item != null;
    final bool ok;

    if (!isEdit) {
      ok = await widget.cubit.createItem(
        dayOfWeek: _day,
        time: time,
        title: title,
        subtitle: subtitle,
      );
    } else {
      ok = await widget.cubit.updateItem(
        id: widget.item!.id,
        dayOfWeek: _day,
        time: time,
        title: title,
        subtitle: subtitle,
      );
    }

    widget.messenger.showSnackBar(SnackBar(
      content: Text(ok
          ? (isEdit ? 'Item atualizado.' : 'Item adicionado.')
          : 'Erro ao salvar.'),
      backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
    ));
  }
}
