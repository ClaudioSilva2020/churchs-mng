import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/institutional_api_service.dart';
import '../../domain/entities/service_schedule_item.dart';

class ScheduleCubit extends Cubit<List<ServiceScheduleItem>> {
  ScheduleCubit(this._api) : super(const []) {
    _load();
  }

  final InstitutionalApiService _api;

  Future<void> _load() async {
    try {
      emit(await _api.fetchSchedule());
    } catch (_) {}
  }

  Future<bool> createItem({
    required String dayOfWeek,
    required String time,
    required String title,
    String? subtitle,
  }) async {
    try {
      final item = await _api.createScheduleItem(
        dayOfWeek: dayOfWeek,
        time: time,
        title: title,
        subtitle: subtitle,
      );
      emit([...state, item]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateItem({
    required String id,
    required String dayOfWeek,
    required String time,
    required String title,
    String? subtitle,
  }) async {
    try {
      final updated = await _api.updateScheduleItem(
        id: id,
        dayOfWeek: dayOfWeek,
        time: time,
        title: title,
        subtitle: subtitle,
      );
      emit(state.map((e) => e.id == id ? updated : e).toList());
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await _api.deleteScheduleItem(id);
      emit(state.where((e) => e.id != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }
}
