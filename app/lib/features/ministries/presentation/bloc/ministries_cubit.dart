import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/ministries_api_service.dart';
import '../../domain/entities/ministry.dart';

/// RF-009: lista de ministérios da igreja.
class MinistriesCubit extends Cubit<List<Ministry>> {
  MinistriesCubit(this._api) : super(const []) {
    _load();
  }

  final MinistriesApiService _api;

  Future<void> _load() async {
    try {
      emit(await _api.fetchMinistries());
    } catch (_) {}
  }

  Future<bool> createMinistry({
    required String name,
    required String description,
    bool hasSchedule = false,
  }) async {
    try {
      final ministry = await _api.createMinistry(
        name: name,
        description: description,
        hasSchedule: hasSchedule,
      );
      emit([...state, ministry]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMinistry(String id) async {
    try {
      await _api.deleteMinistry(id);
      emit(state.where((m) => m.id != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }
}
