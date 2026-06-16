import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/repertoire_plan.dart';
import '../../domain/entities/repertoire_song.dart';
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
    final tabCount = 2 + (hasSchedule ? 1 : 0) + (hasRepertoire ? 1 : 0);

    return BlocProvider(
      create: (_) => MinistryDetailCubit(ministryId: ministryId, ministryName: ministryName),
      child: DefaultTabController(
        length: tabCount,
        child: Scaffold(
          appBar: AppBar(
            title: Text(ministryName),
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
    return BlocBuilder<MinistryDetailCubit, MinistryDetailState>(
      builder: (context, state) {
        if (state.events.isEmpty) {
          return const Center(child: Text('Nenhuma reunião agendada.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
              ),
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
    return BlocBuilder<MinistryDetailCubit, MinistryDetailState>(
      builder: (context, state) {
        if (state.slots.isEmpty) {
          return const Center(child: Text('Nenhuma escala publicada.'));
        }

        final groups = <String, List<dynamic>>{};
        for (final slot in state.slots) {
          final key = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(slot.serviceDate);
          groups.putIfAbsent(key, () => []).add(slot);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: groups.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key[0].toUpperCase() + entry.key.substring(1),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.navy),
                    ),
                    const Divider(),
                    for (final slot in entry.value)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(slot.role)),
                            Text(slot.memberName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
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
                      child: Text(song.key, style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
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
                  child: Text('Escalas de Louvor', style: Theme.of(context).textTheme.titleLarge),
                ),
                if (canManage)
                  TextButton.icon(
                    onPressed: state.songs.isEmpty ? null : () => _showCreatePlanDialog(context, state.songs),
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
                        Text(
                          DateFormat("EEEE, d 'de' MMMM 'às' HH:mm", 'pt_BR').format(plan.serviceDate),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.navy),
                        ),
                        const Divider(),
                        for (final assignment in plan.assignments)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    state.songs
                                        .firstWhere(
                                          (song) => song.id == assignment.songId,
                                          orElse: () => RepertoireSong(
                                            id: assignment.songId,
                                            title: 'Música removida',
                                            key: '-',
                                            addedBy: '-',
                                          ),
                                        )
                                        .title,
                                  ),
                                ),
                                Text(assignment.vocalist, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Informe o título' : null,
                ),
                TextFormField(
                  controller: keyController,
                  decoration: const InputDecoration(labelText: 'Tom (ex.: G, D, Capo 2)'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Informe o tom' : null,
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
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                cubit.addSong(
                  title: titleController.text.trim(),
                  key: keyController.text.trim(),
                  referenceUrl: urlController.text.trim().isEmpty ? null : urlController.text.trim(),
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePlanDialog(BuildContext context, List<RepertoireSong> songs) {
    final cubit = context.read<MinistryDetailCubit>();
    var serviceDate = DateTime.now().add(const Duration(days: 7));
    final selectedSongs = <String>{};
    final vocalistControllers = <String, TextEditingController>{
      for (final song in songs) song.id: TextEditingController(),
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
                        title: Text(DateFormat("d 'de' MMMM 'de' y, HH:mm", 'pt_BR').format(serviceDate)),
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
                            serviceDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          });
                        },
                      ),
                      const Divider(),
                      Text('Selecione as músicas e o vocalista de cada uma:', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      for (final song in songs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                              Expanded(flex: 2, child: Text(song.title)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: vocalistControllers[song.id],
                                  enabled: selectedSongs.contains(song.id),
                                  decoration: const InputDecoration(labelText: 'Vocalista', isDense: true),
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
                  onPressed: () {
                    final assignments = <RepertoireAssignment>[
                      for (final songId in selectedSongs)
                        if (vocalistControllers[songId]!.text.trim().isNotEmpty)
                          RepertoireAssignment(songId: songId, vocalist: vocalistControllers[songId]!.text.trim()),
                    ];
                    if (assignments.isEmpty) return;
                    cubit.createPlan(serviceDate: serviceDate, assignments: assignments);
                    Navigator.of(dialogContext).pop();
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
