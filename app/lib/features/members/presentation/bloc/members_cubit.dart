import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/user_role.dart';
import '../../data/members_api_service.dart';
import '../../domain/entities/member.dart';

/// Diretório de membros da igreja (RF-017b/RF-017c).
class MembersCubit extends Cubit<List<Member>> {
  MembersCubit(this._api) : super(const []) {
    _load();
  }

  final MembersApiService _api;

  Future<void> _load() async {
    try {
      emit(await _api.fetchMembers());
    } catch (_) {}
  }

  Future<bool> addMember({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final member = await _api.createUser(
        username: username,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
      );
      emit([...state, member]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateRole(String memberId, UserRole role) async {
    try {
      final updated = await _api.updateRole(memberId, role);
      emit([
        for (final m in state)
          if (m.id == memberId) updated else m,
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }

  void removeMember(String memberId) {
    emit(state.where((m) => m.id != memberId).toList());
  }
}
