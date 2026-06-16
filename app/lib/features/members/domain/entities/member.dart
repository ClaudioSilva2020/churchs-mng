import 'package:equatable/equatable.dart';

import '../../../../core/constants/user_role.dart';

/// RF-017b/RF-017c: membro da igreja, visível no diretório do Pastor.
class Member extends Equatable {
  const Member({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.ministries = const [],
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final List<String> ministries;

  Member copyWith({UserRole? role}) {
    return Member(
      id: id,
      name: name,
      email: email,
      role: role ?? this.role,
      ministries: ministries,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, ministries];
}
