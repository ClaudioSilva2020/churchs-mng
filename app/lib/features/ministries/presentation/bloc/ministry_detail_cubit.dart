import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/ministry_event.dart';
import '../../domain/entities/repertoire_plan.dart';
import '../../domain/entities/repertoire_song.dart';
import '../../domain/entities/service_slot.dart';

/// Estado da tela de detalhe de um ministério (RF-012 a RF-014, RF-016).
class MinistryDetailState extends Equatable {
  const MinistryDetailState({
    required this.ministryId,
    required this.ministryName,
    required this.messages,
    required this.events,
    required this.slots,
    required this.songs,
    required this.plans,
  });

  final String ministryId;
  final String ministryName;
  final List<ChatMessage> messages;
  final List<MinistryEvent> events;
  final List<ServiceSlot> slots;
  final List<RepertoireSong> songs;
  final List<RepertoirePlan> plans;

  MinistryDetailState copyWith({
    List<ChatMessage>? messages,
    List<RepertoireSong>? songs,
    List<RepertoirePlan>? plans,
  }) {
    return MinistryDetailState(
      ministryId: ministryId,
      ministryName: ministryName,
      messages: messages ?? this.messages,
      events: events,
      slots: slots,
      songs: songs ?? this.songs,
      plans: plans ?? this.plans,
    );
  }

  @override
  List<Object?> get props =>
      [ministryId, ministryName, messages, events, slots, songs, plans];
}

/// TODO(backend): substituir dados mockados por:
/// - chat: WebSocket via Django Channels (RF-012)
/// - agenda: GET /api/ministries/{id}/events/ (RF-013)
/// - escala: GET /api/ministries/{id}/schedule/ (RF-014)
/// - repertório: GET/POST /api/ministries/{id}/songs/ (RF-016)
/// - plano de louvor: GET/POST /api/ministries/{id}/repertoire-plans/ (RF-016)
class MinistryDetailCubit extends Cubit<MinistryDetailState> {
  MinistryDetailCubit({required String ministryId, required String ministryName})
      : super(
          MinistryDetailState(
            ministryId: ministryId,
            ministryName: ministryName,
            messages: _mockMessages,
            events: _mockEvents,
            slots: _mockSlots,
            songs: _mockSongs,
            plans: _mockPlans,
          ),
        );

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      author: 'Você',
      text: text.trim(),
      sentAt: DateTime.now(),
      isMine: true,
    );

    emit(state.copyWith(messages: [...state.messages, message]));
  }

  /// RF-016: qualquer membro do Ministério de Louvor pode cadastrar uma
  /// música no repertório.
  void addSong({required String title, required String key, String? referenceUrl}) {
    final song = RepertoireSong(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      key: key,
      referenceUrl: referenceUrl,
      addedBy: 'Você',
    );
    emit(state.copyWith(songs: [...state.songs, song]));
  }

  /// RF-016: o Líder do Ministério de Louvor monta o plano de louvor de um
  /// culto, associando músicas a vocalistas.
  void createPlan({required DateTime serviceDate, required List<RepertoireAssignment> assignments}) {
    final plan = RepertoirePlan(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      serviceDate: serviceDate,
      assignments: assignments,
    );
    emit(state.copyWith(plans: [...state.plans, plan]));
  }
}

final _mockMessages = [
  ChatMessage(
    id: '1',
    author: 'Liderança',
    text: 'Bom dia, equipe! Reunião confirmada para esta semana.',
    sentAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  ChatMessage(
    id: '2',
    author: 'João',
    text: 'Combinado, estarei presente!',
    sentAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];

final _mockEvents = [
  MinistryEvent(
    id: '1',
    title: 'Reunião de planejamento',
    description: 'Pauta: próximos eventos do trimestre.',
    startsAt: DateTime.now().add(const Duration(days: 3)),
    location: 'Sala 2 — IBBE',
  ),
  MinistryEvent(
    id: '2',
    title: 'Encontro mensal',
    description: 'Confraternização e estudo em grupo.',
    startsAt: DateTime.now().add(const Duration(days: 10)),
    location: 'Salão principal',
  ),
];

final _mockSlots = [
  ServiceSlot(
    id: '1',
    serviceDate: DateTime.now().add(const Duration(days: 2)),
    role: 'Responsável',
    memberName: 'Maria Silva',
  ),
  ServiceSlot(
    id: '2',
    serviceDate: DateTime.now().add(const Duration(days: 2)),
    role: 'Apoio',
    memberName: 'Pedro Santos',
  ),
  ServiceSlot(
    id: '3',
    serviceDate: DateTime.now().add(const Duration(days: 9)),
    role: 'Responsável',
    memberName: 'Ana Costa',
  ),
];

final _mockSongs = [
  const RepertoireSong(
    id: '1',
    title: 'Grande É o Senhor',
    key: 'G',
    referenceUrl: 'https://youtube.com/watch?v=exemplo1',
    addedBy: 'Maria Silva',
  ),
  const RepertoireSong(
    id: '2',
    title: 'Reckless Love (Amor Que Vai Além)',
    key: 'D',
    referenceUrl: 'https://youtube.com/watch?v=exemplo2',
    addedBy: 'Pedro Santos',
  ),
  const RepertoireSong(
    id: '3',
    title: 'Ousado Amor',
    key: 'E',
    addedBy: 'Maria Silva',
  ),
];

final _mockPlans = [
  RepertoirePlan(
    id: '1',
    serviceDate: DateTime.now().add(const Duration(days: 2)),
    assignments: const [
      RepertoireAssignment(songId: '1', vocalist: 'Maria Silva'),
      RepertoireAssignment(songId: '2', vocalist: 'Pedro Santos'),
    ],
  ),
];
