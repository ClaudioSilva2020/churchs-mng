import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/institutional_api_service.dart';

/// RF-006: princípios/valores da igreja, editável pelo Pastor.
class PrinciplesCubit extends Cubit<String> {
  PrinciplesCubit(this._api) : super('') {
    _load();
  }

  final InstitutionalApiService _api;

  Future<void> _load() async {
    try {
      emit(await _api.fetchPrinciples());
    } catch (_) {}
  }

  Future<void> updateText(String text) async {
    emit(text);
    try {
      await _api.updatePrinciples(text);
    } catch (_) {}
  }
}
