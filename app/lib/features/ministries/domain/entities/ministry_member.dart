import 'package:equatable/equatable.dart';

/// Membro de um ministério — usado em dropdowns de escala e vocalistas.
class MinistryMember extends Equatable {
  const MinistryMember({
    required this.id,
    required this.userId,
    required this.displayName,
  });

  /// id do MinistryMembership
  final String id;

  /// id do User — enviado na API
  final String userId;

  final String displayName;

  factory MinistryMember.fromJson(Map<String, dynamic> json) {
    final userDetail = json['user_detail'] as Map<String, dynamic>?;
    final firstName = (userDetail?['first_name'] as String? ?? '').trim();
    final lastName = (userDetail?['last_name'] as String? ?? '').trim();
    final username = userDetail?['username'] as String? ?? '';
    final fullName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    return MinistryMember(
      id: json['id'].toString(),
      userId: json['user'].toString(),
      displayName: fullName.isNotEmpty ? fullName : username,
    );
  }

  @override
  List<Object?> get props => [id, userId, displayName];
}
