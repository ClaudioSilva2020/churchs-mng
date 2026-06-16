import 'package:equatable/equatable.dart';

import '../../../../core/constants/user_role.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.hasAutomationAccess = false,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;

  /// RF-004: concedido individualmente pelo Pastor.
  final bool hasAutomationAccess;

  @override
  List<Object?> get props => [id, name, email, role, hasAutomationAccess];
}
