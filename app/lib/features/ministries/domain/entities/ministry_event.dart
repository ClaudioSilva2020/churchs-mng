import 'package:equatable/equatable.dart';

/// RF-013: reunião/evento agendado de um ministério.
class MinistryEvent extends Equatable {
  const MinistryEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.location,
  });

  final String id;
  final String title;
  final String description;
  final DateTime startsAt;
  final String location;

  @override
  List<Object?> get props => [id, title, description, startsAt, location];
}
