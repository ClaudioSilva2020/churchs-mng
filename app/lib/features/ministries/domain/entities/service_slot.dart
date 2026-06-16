import 'package:equatable/equatable.dart';

/// RF-014: escala de serviço — quem está designado para qual função em
/// um culto/reunião do ministério.
class ServiceSlot extends Equatable {
  const ServiceSlot({
    required this.id,
    required this.serviceDate,
    required this.role,
    required this.memberName,
  });

  final String id;
  final DateTime serviceDate;
  final String role;
  final String memberName;

  @override
  List<Object?> get props => [id, serviceDate, role, memberName];
}
