import 'package:dio/dio.dart';

import '../domain/entities/ministry_event.dart';
import '../domain/entities/ministry_member.dart';
import '../domain/entities/repertoire_plan.dart';
import '../domain/entities/repertoire_song.dart';
import '../domain/entities/service_slot.dart';

class MinistryApiService {
  MinistryApiService(this._dio);

  final Dio _dio;

  Future<List<MinistryEvent>> fetchEvents(String ministryId) async {
    final res = await _dio.get('/ministries/$ministryId/events/');
    return (res.data as List)
        .map((e) => MinistryEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MinistryEvent> createEvent({
    required String ministryId,
    required String title,
    required String description,
    required String location,
    required DateTime startsAt,
  }) async {
    final res = await _dio.post('/ministries/$ministryId/events/', data: {
      'title': title,
      'description': description,
      'location': location,
      'starts_at': startsAt.toIso8601String(),
    });
    return MinistryEvent.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<ServiceSlot>> fetchSlots(String ministryId) async {
    final res = await _dio.get('/ministries/$ministryId/schedule-slots/');
    return (res.data as List)
        .map((e) => ServiceSlot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceSlot> createSlot({
    required String ministryId,
    required DateTime serviceDate,
    required String role,
    required String memberId,
  }) async {
    final dateStr =
        '${serviceDate.year.toString().padLeft(4, '0')}-${serviceDate.month.toString().padLeft(2, '0')}-${serviceDate.day.toString().padLeft(2, '0')}T00:00:00';
    final res = await _dio.post('/ministries/$ministryId/schedule-slots/', data: {
      'service_date': dateStr,
      'role': role,
      'member': int.parse(memberId),
    });
    return ServiceSlot.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<RepertoireSong>> fetchSongs(String ministryId) async {
    final res = await _dio.get('/ministries/$ministryId/songs/');
    return (res.data as List)
        .map((e) => RepertoireSong.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RepertoireSong> addSong({
    required String ministryId,
    required String title,
    required String key,
    String? referenceUrl,
  }) async {
    final res = await _dio.post('/ministries/$ministryId/songs/', data: {
      'title': title,
      'key': key,
      if (referenceUrl != null && referenceUrl.isNotEmpty) 'reference_url': referenceUrl,
    });
    return RepertoireSong.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<RepertoirePlan>> fetchPlans(String ministryId) async {
    final res = await _dio.get('/ministries/$ministryId/repertoire-plans/');
    return (res.data as List)
        .map((e) => RepertoirePlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RepertoirePlan> createPlan({
    required String ministryId,
    required DateTime serviceDate,
    required List<Map<String, int>> assignments,
  }) async {
    final dateStr =
        '${serviceDate.year.toString().padLeft(4, '0')}-${serviceDate.month.toString().padLeft(2, '0')}-${serviceDate.day.toString().padLeft(2, '0')}T${serviceDate.hour.toString().padLeft(2, '0')}:${serviceDate.minute.toString().padLeft(2, '0')}:00';
    final res = await _dio.post('/ministries/$ministryId/repertoire-plans/', data: {
      'service_date': dateStr,
      'assignments': assignments,
    });
    return RepertoirePlan.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<MinistryMember>> fetchMinistryMembers(String ministryId) async {
    final res = await _dio.get('/ministries/$ministryId/members/');
    return (res.data as List)
        .map((e) => MinistryMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MinistryMember> addMinistryMember({
    required String ministryId,
    required String userId,
    required String role,
  }) async {
    final res = await _dio.post('/ministries/$ministryId/members/', data: {
      'user': int.parse(userId),
      'role': role,
    });
    return MinistryMember.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteEvent(String ministryId, String eventId) async {
    await _dio.delete('/ministries/$ministryId/events/$eventId/');
  }

  Future<void> deleteSlot(String ministryId, String slotId) async {
    await _dio.delete('/ministries/$ministryId/schedule-slots/$slotId/');
  }

  Future<void> deletePlan(String ministryId, String planId) async {
    await _dio.delete('/ministries/$ministryId/repertoire-plans/$planId/');
  }
}
