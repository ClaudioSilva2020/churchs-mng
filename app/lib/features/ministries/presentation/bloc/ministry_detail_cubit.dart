import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/ministry_api_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/ministry_event.dart';
import '../../domain/entities/ministry_member.dart';
import '../../domain/entities/repertoire_plan.dart';
import '../../domain/entities/repertoire_song.dart';
import '../../domain/entities/service_slot.dart';

class MinistryDetailState extends Equatable {
  const MinistryDetailState({
    required this.ministryId,
    required this.ministryName,
    required this.messages,
    required this.events,
    required this.slots,
    required this.songs,
    required this.plans,
    required this.members,
    required this.isLoading,
  });

  final String ministryId;
  final String ministryName;
  final List<ChatMessage> messages;
  final List<MinistryEvent> events;
  final List<ServiceSlot> slots;
  final List<RepertoireSong> songs;
  final List<RepertoirePlan> plans;
  final List<MinistryMember> members;
  final bool isLoading;

  MinistryDetailState copyWith({
    List<ChatMessage>? messages,
    List<MinistryEvent>? events,
    List<ServiceSlot>? slots,
    List<RepertoireSong>? songs,
    List<RepertoirePlan>? plans,
    List<MinistryMember>? members,
    bool? isLoading,
  }) {
    return MinistryDetailState(
      ministryId: ministryId,
      ministryName: ministryName,
      messages: messages ?? this.messages,
      events: events ?? this.events,
      slots: slots ?? this.slots,
      songs: songs ?? this.songs,
      plans: plans ?? this.plans,
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props =>
      [ministryId, ministryName, messages, events, slots, songs, plans, members, isLoading];
}

class MinistryDetailCubit extends Cubit<MinistryDetailState> {
  MinistryDetailCubit({
    required String ministryId,
    required String ministryName,
    required MinistryApiService api,
  })  : _api = api,
        super(
          MinistryDetailState(
            ministryId: ministryId,
            ministryName: ministryName,
            messages: const [],
            events: const [],
            slots: const [],
            songs: const [],
            plans: const [],
            members: const [],
            isLoading: true,
          ),
        ) {
    _load();
  }

  final MinistryApiService _api;

  Future<void> _load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final results = await Future.wait([
        _api.fetchEvents(state.ministryId),
        _api.fetchSlots(state.ministryId),
        _api.fetchSongs(state.ministryId),
        _api.fetchPlans(state.ministryId),
        _api.fetchMinistryMembers(state.ministryId),
      ]);
      emit(state.copyWith(
        events: results[0] as List<MinistryEvent>,
        slots: results[1] as List<ServiceSlot>,
        songs: results[2] as List<RepertoireSong>,
        plans: results[3] as List<RepertoirePlan>,
        members: results[4] as List<MinistryMember>,
        isLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  /// RF-012: chat local — WebSocket via Django Channels é uma feature separada.
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

  Future<bool> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime startsAt,
  }) async {
    try {
      final event = await _api.createEvent(
        ministryId: state.ministryId,
        title: title,
        description: description,
        location: location,
        startsAt: startsAt,
      );
      emit(state.copyWith(events: [...state.events, event]));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createSlot({
    required DateTime serviceDate,
    required String role,
    required String memberId,
  }) async {
    try {
      final slot = await _api.createSlot(
        ministryId: state.ministryId,
        serviceDate: serviceDate,
        role: role,
        memberId: memberId,
      );
      emit(state.copyWith(slots: [...state.slots, slot]));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addSong({
    required String title,
    required String key,
    String? referenceUrl,
  }) async {
    try {
      final song = await _api.addSong(
        ministryId: state.ministryId,
        title: title,
        key: key,
        referenceUrl: referenceUrl,
      );
      emit(state.copyWith(songs: [...state.songs, song]));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createPlan({
    required DateTime serviceDate,
    required List<Map<String, int>> assignments,
  }) async {
    try {
      final plan = await _api.createPlan(
        ministryId: state.ministryId,
        serviceDate: serviceDate,
        assignments: assignments,
      );
      emit(state.copyWith(plans: [...state.plans, plan]));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addMinistryMember({required String userId, required String role}) async {
    try {
      final member = await _api.addMinistryMember(
        ministryId: state.ministryId,
        userId: userId,
        role: role,
      );
      emit(state.copyWith(members: [...state.members, member]));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      await _api.deleteEvent(state.ministryId, eventId);
      emit(state.copyWith(events: state.events.where((e) => e.id != eventId).toList()));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteSlot(String slotId) async {
    try {
      await _api.deleteSlot(state.ministryId, slotId);
      emit(state.copyWith(slots: state.slots.where((s) => s.id != slotId).toList()));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deletePlan(String planId) async {
    try {
      await _api.deletePlan(state.ministryId, planId);
      emit(state.copyWith(plans: state.plans.where((p) => p.id != planId).toList()));
      return true;
    } catch (_) {
      return false;
    }
  }
}
