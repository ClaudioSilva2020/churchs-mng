import '../../../../core/constants/user_role.dart';
import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.hasAutomationAccess,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? json['username'] as String? ?? '',
      email: json['email'] as String,
      role: UserRole.fromApi(json['role'] as String? ?? 'non_member'),
      hasAutomationAccess: json['has_automation_access'] as bool? ?? false,
    );
  }
}
