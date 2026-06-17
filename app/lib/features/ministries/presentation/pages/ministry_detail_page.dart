import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../members/data/members_api_service.dart';
import '../../../members/domain/entities/member.dart';
import '../../data/ministry_api_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/ministry_member.dart';
import '../../domain/entities/repertoire_song.dart';
import '../../domain/entities/service_slot.dart';
import '../bloc/ministry_detail_cubit.dart';

/// Detalhe do ministério (RF-012 a RF-014, RF-016): chat, agenda, escala e
/// repertório.
class MinistryDetailPage extends StatelessWidget {
  const MinistryDetailPage({
    super.key,
    required this.ministryId,
    required this.ministryName,
    this.hasSchedule = false,
    this.hasRepertoire = false,
  });

  final String ministryId;
  final String ministryName;

  /// RF-014: apenas Louvor, PGs, Missões, Libras e Mulheres têm escala.
  final bool hasSchedule;

  /// RF-016: apenas o Ministério de Louvor tem repertório de músicas.
  final bool hasRepertoire;

  @override
  Widget build(BuildContext context) {
    final canManageMinistries = context.watch<AuthBloc>().state.role.canManageMinistries;
    final tabCount = 2 + (hasSchedule ? 1 : 0) + (hasRepertoire ? 1 : 0);

    return BlocProvider(
      create: (_) => MinistryDetailCubit(
        ministryId: ministryId,
        ministryName: ministryName,
        api: injector<MinistryApiService>(),
      ),
      child: DefaultTabController(
        length: tabCount,
        child: Scaffold(
          appBar: AppBar(
            title: Text(ministryName),
            actions: [
              if (canManageMinistries)
                Builder(
                  builder: (builderCtx) => IconButton(
                    icon: const Icon(Icons.group_outlined),
                    tooltip: 'Gerenciar membros',
                    onPressed: () => _showManageMembersSheet(builderCtx),
                  ),
                ),
            ],
            bottom: TabBar(
              tabs: [
                const Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
                const Tab(icon: Icon(Icons.event_outlined), text: 'Agenda'),
                if (hasSchedule) const Tab(icon: Icon(Icons.assignment_outlined), text: 'Escala'),
                if (hasRepertoire) const Tab(icon: Icon(Icons.music_note_outlined), text: 'Repertório'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              const _ChatTab(),
              const _AgendaTab(),
              if (hasSchedule) const _ScheduleTab(),
              if (hasRepertoire) const _RepertoireTab(),
            ],
          ),
        ),
      ),
    );
  }

  void _showManageMembersSheet(BuildContext context) {
    final cubit = context.read<MinistryDetailCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _ManageMembersSheet(),
      ),
    );
  }
}

class _ChatTab extends StatefulWidget {
  const _ChatTab();

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    context.read<MinistryDetailCubit>().sendMessage(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MinistryDetailCubit, MinistryDetailState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: state.messages.length,
                itemBuilder: (context, index) => _ChatBubble(message: state.messages[index]),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Escreva uma mensagem...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.send),
                      onPressed: _send,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final align = message.isMine ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isMine ? AppColors.navy : AppColors.background;
    final textColor = message.isMine ? AppColors.white : AppColors.textPrimary;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isMine)
              Text(
                message.author,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            Text(message.text, style: TextStyle(color: textColor)),
            const SizedBox(height: 2),
            Text(
              DateFormat('HH:mm').format(message.sentAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaTab extends StatelessWidget {
  const _AgendaTab();

  @override
  Widget build(BuildContext context) {
    final canManage = context.watch<AuthBloc>().state.role.canManageMinistries ||
        context.watch<AuthBloc>().state.role.canPublishContent;

    return BlocBuilder<MinistryDetailCubit, MinistryDetailState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            state.events.isEmpty
                ? const Center(child: Text('Nenhuma reunião agendada.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: state.events.length,
                    itemBuilder: (context, index) {
                      final event = state.events[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.gold,
                            child: Icon(Icons.event, color: AppColors.navy),
                          ),
                          title: Text(event.title),
                          subtitle: Text(
                            '${event.description}\n${DateFormat("d 'de' MMMM, HH:mm", 'pt_BR').format(event.startsAt)} · ${event.location}',
                          ),
                          isThreeLine: true,
                          trailing: canManage
                              ? IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color: Colors.red.shade400),
                                  onPressed: () async {
                                    final cubit =
                                        context.read<MinistryDetailCubit>();
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final ok =
                                        await cubit.deleteEvent(event.id);
                                    messenger.showSnackBar(SnackBar(
                                      content: Text(ok
                                          ? 'Evento removido.'
                                          : 'Erro ao remover.'),
                                      backgroundColor: ok
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                    ));
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  ),
            if (canManage)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  heroTag: 'fab_agenda',
                  onPressed: () => _showCreateEventDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Novo evento'),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    final cubit = context.read<MinistryDetailCubit>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Novo evento'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Título'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
                      ),
                      TextFormField(
                        controller: locationController,
                        decoration: const InputDecoration(labelText: 'Local'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Informe o local' : null,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                            DateFormat("d 'de' MMMM 'de' y, HH:mm", 'pt_BR').format(selectedDate)),
                        trailing: const Icon(Icons.edit_calendar_outlined),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 730)),
                          );
                          if (date == null || !dialogContext.mounted) return;
                          final time = await showTimePicker(
                            context: dialogContext,
                            initialTime: TimeOfDay.fromDateTime(selectedDate),
                          );
                          if (time == null) return;
                          setState(() {
                            selectedDate = DateTime(
                                date.year, date.month, date.day, time.hour, time.minute);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    Navigator.of(dialogContext).pop();
                    final ok = await cubit.createEvent(
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      location: locationController.text.trim(),
                      startsAt: selectedDate,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Evento criado.' : 'Erro ao criar evento.'),
                          backgroundColor: ok ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab();

  @override
  Widget build(BuildContext context) {
    final canManage = context.watch<AuthBloc>().state.role.canManageMinistries;

    return BlocBuilder<MinistryDetailCubit, MinistryDetailState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            state.slots.isEmpty
                ? const Center(child: Text('Nenhuma escala publicada.'))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    children: _buildSlotGroups(context, state.slots, canManage: canManage),
                  ),
            if (canManage)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  heroTag: 'fab_schedule',
                  onPressed: state.members.isEmpty
                      ? null
                      : () => _showCreateSlotDialog(context, state.members),
                  icon: const Icon(Icons.add),
                  label: const Text('Nova escala'),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildSlotGroups(
    BuildContext context,
    List<ServiceSlot> slots, {
    required bool canManage,
  }) {
    final groups = <String, List<ServiceSlot>>{};
    for (final slot in slots) {
      final key = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(slot.serviceDate);
      groups.putIfAbsent(key, () => []).add(slot);
    }

    return groups.entries.map((entry) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key[0].toUpperCase() + entry.key.substring(1),
                style:
                    Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.navy),
              ),
              const Divider(),
              for (final slot in entry.value)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(child: Text(slot.role)),
                      Text(slot.memberName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (canManage)
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                            onPressed: () async {
                              final cubit = context.read<MinistryDetailCubit>();
                              final messenger = ScaffoldMessenger.of(context);
                              final ok = await cubit.deleteSlot(slot.id);
                              messenger.showSnackBar(SnackBar(
                                content: Text(
                                    ok ? 'Escala removida.' : 'Erro ao remover.'),
                                backgroundColor:
                                    ok ? Colors.green.shade700 : Colors.red.shade700,
                              ));
                            },
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  static const _serviceRoles = [
    'Vocalista',
    'Back-vocal 1',
    'Back-vocal 2',
    'Back-vocal 3',
    'Baterista',
    'Baixista',
    'Tecladista',
    'Violão Base',
    'Guitarra Base',
    'Guitarra Solo',
    'Cajón',
    'Outros',
  ];

  void _showCreateSlotDialog(BuildContext context, List<MinistryMember> members) {
    final cubit = context.read<MinistryDetailCubit>();
    final formKey = GlobalKey<FormState>();
    var selectedDate = DateTime.now().add(const Duration(days: 7));
    MinistryMember? selectedMember;
    String? selectedRole;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Nova entrada na escala'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(DateFormat("d 'de' MMMM 'de' y", 'pt_BR').format(selectedDate)),
                        trailing: const Icon(Icons.edit_calendar_outlined),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 730)),
                          );
                          if (date == null) return;
                          setState(() {
                            selectedDate =
                                DateTime(date.year, date.month, date.day);
                          });
                        },
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Função'),
                        items: _serviceRoles
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (r) => setState(() => selectedRole = r),
                        validator: (v) => v == null ? 'Selecione uma função' : null,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<MinistryMember>(
                        value: selectedMember,
                        decoration: const InputDecoration(labelText: 'Membro'),
                        items: members
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m.displayName),
                                ))
                            .toList(),
                        onChanged: (m) => setState(() => selectedMember = m),
                        validator: (v) => v == null ? 'Selecione um membro' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    Navigator.of(dialogContext).pop();
                    final ok = await cubit.createSlot(
                      serviceDate: selectedDate,
                      role: selectedRole!,
                      memberId: selectedMember!.userId,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Escala salva.' : 'Erro ao salvar escala.'),
                          backgroundColor: ok ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// RF-016: repertório de músicas (cadastrado por qualquer membro do
/// Ministério de Louvor) e escalas de louvor por culto (montadas pelo
/// Líder do Ministério de Louvor).
class _RepertoireTab extends StatelessWidget {
  const _RepertoireTab();

  @override
  Widget build(BuildContext context) {
    final canManage = context.watch<AuthBloc>().state.role.canManageMinistries;

    return BlocBuilder<MinistryDetailCubit, MinistryDetailState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Músicas', style: Theme.of(context).textTheme.titleLarge),
                ),
                TextButton.icon(
                  onPressed: () => _showAddSongDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar música'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.songs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Nenhuma música cadastrada ainda.'),
              )
            else
              ...state.songs.map(
                (song) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.gold,
                      child: Text(song.key,
                          style: const TextStyle(
                              color: AppColors.navy, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(song.title),
                    subtitle: Text(
                      song.referenceUrl != null
                          ? '${song.referenceUrl}\nAdicionada por ${song.addedBy}'
                          : 'Adicionada por ${song.addedBy}',
                    ),
                    isThreeLine: song.referenceUrl != null,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text('Escalas de Louvor',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                if (canManage)
                  TextButton.icon(
                    onPressed: (state.songs.isEmpty || state.members.isEmpty)
                        ? null
                        : () => _showCreatePlanDialog(
                            context, state.songs, state.members),
                    icon: const Icon(Icons.add),
                    label: const Text('Nova escala'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.plans.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Nenhuma escala de louvor publicada ainda.'),
              )
            else
              ...state.plans.map((plan) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat("EEEE, d 'de' MMMM 'às' HH:mm", 'pt_BR')
                                    .format(plan.serviceDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(color: AppColors.navy),
                              ),
                            ),
                            if (canManage)
                              IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 20,
                                icon: Icon(Icons.delete_outline,
                                    color: Colors.red.shade400),
                                onPressed: () async {
                                  final cubit = context.read<MinistryDetailCubit>();
                                  final messenger = ScaffoldMessenger.of(context);
                                  final ok = await cubit.deletePlan(plan.id);
                                  messenger.showSnackBar(SnackBar(
                                    content: Text(ok
                                        ? 'Escala de louvor removida.'
                                        : 'Erro ao remover.'),
                                    backgroundColor: ok
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ));
                                },
                              ),
                          ],
                        ),
                        const Divider(),
                        for (final assignment in plan.assignments)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(child: Text(assignment.songTitle)),
                                Text(assignment.vocalistName,
                                    style:
                                        const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  void _showAddSongDialog(BuildContext context) {
    final cubit = context.read<MinistryDetailCubit>();
    final titleController = TextEditingController();
    final keyController = TextEditingController();
    final urlController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Adicionar música'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
                ),
                TextFormField(
                  controller: keyController,
                  decoration: const InputDecoration(labelText: 'Tom (ex.: G, D, Capo 2)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o tom' : null,
                ),
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'Link de referência (opcional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.of(dialogContext).pop();
                final ok = await cubit.addSong(
                  title: titleController.text.trim(),
                  key: keyController.text.trim(),
                  referenceUrl:
                      urlController.text.trim().isEmpty ? null : urlController.text.trim(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok ? 'Música adicionada.' : 'Erro ao adicionar música.'),
                      backgroundColor: ok ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePlanDialog(
      BuildContext context, List<RepertoireSong> songs, List<MinistryMember> members) {
    final cubit = context.read<MinistryDetailCubit>();
    var serviceDate = DateTime.now().add(const Duration(days: 7));
    final selectedSongs = <String>{};
    final vocalistSelection = <String, MinistryMember?>{
      for (final song in songs) song.id: null,
    };

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Nova escala de louvor'),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                            DateFormat("d 'de' MMMM 'de' y, HH:mm", 'pt_BR')
                                .format(serviceDate)),
                        trailing: const Icon(Icons.edit_calendar_outlined),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: dialogContext,
                            initialDate: serviceDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date == null || !dialogContext.mounted) return;
                          final time = await showTimePicker(
                            context: dialogContext,
                            initialTime: TimeOfDay.fromDateTime(serviceDate),
                          );
                          if (time == null) return;
                          setState(() {
                            serviceDate = DateTime(
                                date.year, date.month, date.day, time.hour, time.minute);
                          });
                        },
                      ),
                      const Divider(),
                      Text(
                        'Selecione as músicas e o vocalista de cada uma:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      for (final song in songs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: selectedSongs.contains(song.id),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked ?? false) {
                                          selectedSongs.add(song.id);
                                        } else {
                                          selectedSongs.remove(song.id);
                                        }
                                      });
                                    },
                                  ),
                                  Expanded(child: Text(song.title)),
                                ],
                              ),
                              if (selectedSongs.contains(song.id))
                                Padding(
                                  padding: const EdgeInsets.only(left: 48),
                                  child: DropdownButtonFormField<MinistryMember>(
                                    value: vocalistSelection[song.id],
                                    decoration: const InputDecoration(
                                        labelText: 'Vocalista', isDense: true),
                                    items: members
                                        .map((m) => DropdownMenuItem(
                                              value: m,
                                              child: Text(m.displayName),
                                            ))
                                        .toList(),
                                    onChanged: (m) =>
                                        setState(() => vocalistSelection[song.id] = m),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    final assignments = <Map<String, int>>[];
                    for (final songId in selectedSongs) {
                      final member = vocalistSelection[songId];
                      if (member == null) return;
                      assignments.add({
                        'song': int.parse(songId),
                        'vocalist': int.parse(member.userId),
                      });
                    }
                    if (assignments.isEmpty) return;
                    Navigator.of(dialogContext).pop();
                    final ok = await cubit.createPlan(
                      serviceDate: serviceDate,
                      assignments: assignments,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(ok ? 'Escala publicada.' : 'Erro ao publicar escala.'),
                          backgroundColor: ok ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Publicar escala'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gerenciar membros do ministério
// ─────────────────────────────────────────────────────────────────────────────

class _ManageMembersSheet extends StatelessWidget {
  const _ManageMembersSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MinistryDetailCubit, MinistryDetailState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Membros do ministério',
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.person_add_outlined),
                        label: const Text('Adicionar'),
                        onPressed: () => _showAddMemberDialog(context, state.members),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: state.members.isEmpty
                      ? const Center(child: Text('Nenhum membro neste ministério.'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: state.members.length,
                          itemBuilder: (_, i) {
                            final m = state.members[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.gold,
                                child: Text(
                                  m.displayName.isNotEmpty
                                      ? m.displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(color: AppColors.navy),
                                ),
                              ),
                              title: Text(m.displayName),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddMemberDialog(BuildContext context, List<MinistryMember> currentMembers) {
    final cubit = context.read<MinistryDetailCubit>();
    final currentIds = currentMembers.map((m) => m.userId).toSet();
    showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _AddMemberDialog(excludeIds: currentIds),
      ),
    );
  }
}

class _AddMemberDialog extends StatefulWidget {
  const _AddMemberDialog({required this.excludeIds});
  final Set<String> excludeIds;

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  List<Member>? _allMembers;
  Member? _selected;
  String _role = 'servant';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await injector<MembersApiService>().fetchMembers();
      setState(() {
        _allMembers = members.where((m) => !widget.excludeIds.contains(m.id)).toList();
      });
    } catch (_) {
      setState(() => _allMembers = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = _allMembers;
    return AlertDialog(
      title: const Text('Adicionar membro'),
      content: available == null
          ? const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            )
          : available.isEmpty
              ? const Text('Todos os membros já fazem parte deste ministério.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Member>(
                      decoration: const InputDecoration(labelText: 'Membro'),
                      items: available
                          .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                          .toList(),
                      onChanged: (m) => setState(() => _selected = m),
                      validator: (v) => v == null ? 'Selecione' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Função no ministério'),
                      value: _role,
                      items: const [
                        DropdownMenuItem(value: 'servant', child: Text('Servo')),
                        DropdownMenuItem(value: 'leader', child: Text('Líder')),
                      ],
                      onChanged: (r) => setState(() => _role = r ?? 'servant'),
                    ),
                  ],
                ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (available != null && available.isNotEmpty)
          FilledButton(
            onPressed: (_selected == null || _loading)
                ? null
                : () async {
                    setState(() => _loading = true);
                    final cubit = context.read<MinistryDetailCubit>();
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final ok = await cubit.addMinistryMember(
                      userId: _selected!.id,
                      role: _role,
                    );
                    navigator.pop();
                    messenger.showSnackBar(SnackBar(
                      content: Text(ok
                          ? '${_selected!.name} adicionado ao ministério.'
                          : 'Erro ao adicionar membro.'),
                      backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
                    ));
                  },
            child: const Text('Adicionar'),
          ),
      ],
    );
  }
}
