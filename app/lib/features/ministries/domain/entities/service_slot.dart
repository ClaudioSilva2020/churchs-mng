import 'package:equatable/equatable.dart';

/// RF-014: escala de serviço — quem está designado para qual função em
/// um culto/reunião do ministério.
class ServiceSlot extends Equatable {
  const ServiceSlot({
    required this.id,
    required this.serviceDate,
    required this.role,
    required this.memberName,
    required this.memberId,
  });

  final String id;
  final DateTime serviceDate;
  final String role;
  final String memberName;
  final String memberId;

  factory ServiceSlot.fromJson(Map<String, dynamic> json) => ServiceSlot(
        id: json['id'].toString(),
        serviceDate: DateTime.parse(json['service_date'] as String),
        role: json['role'] as String? ?? '',
        memberName: json['member_name'] as String? ?? '',
        memberId: json['member'].toString(),
      );

  @override
  List<Object?> get props => [id, serviceDate, role, memberName, memberId];
}
