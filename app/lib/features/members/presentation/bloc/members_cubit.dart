import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/user_role.dart';
import '../../domain/entities/member.dart';

/// Diretório de membros da igreja (RF-017b/RF-017c).
///
/// TODO(backend): substituir `_mockMembers` por GET /api/members/, e enviar
/// criação/remoção/alteração de papel para POST/DELETE/PATCH /api/members/.
class MembersCubit extends Cubit<List<Member>> {
  MembersCubit() : super(_mockMembers);

  void addMember({required String name, required String email, required UserRole role}) {
    final member = Member(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: role,
    );
    emit([...state, member]);
  }

  void removeMember(String memberId) {
    emit(state.where((member) => member.id != memberId).toList());
  }

  void updateRole(String memberId, UserRole role) {
    emit([
      for (final member in state)
        if (member.id == memberId) member.copyWith(role: role) else member,
    ]);
  }
}

final _mockMembers = [
  const Member(
    id: '1',
    name: 'Maria Silva',
    email: 'maria.silva@ibbe.dev',
    role: UserRole.leader,
    ministries: ['Louvor'],
  ),
  const Member(
    id: '2',
    name: 'Pedro Santos',
    email: 'pedro.santos@ibbe.dev',
    role: UserRole.servant,
    ministries: ['Louvor', 'PGs'],
  ),
  const Member(
    id: '3',
    name: 'Ana Costa',
    email: 'ana.costa@ibbe.dev',
    role: UserRole.member,
    ministries: ['Mulheres'],
  ),
  const Member(
    id: '4',
    name: 'João Pereira',
    email: 'joao.pereira@ibbe.dev',
    role: UserRole.media,
    ministries: [],
  ),
  const Member(
    id: '5',
    name: 'Pastor Carlos',
    email: 'pastor.carlos@ibbe.dev',
    role: UserRole.pastor,
    ministries: [],
  ),
];
