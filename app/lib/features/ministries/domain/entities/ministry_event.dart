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

  factory MinistryEvent.fromJson(Map<String, dynamic> json) => MinistryEvent(
        id: json['id'].toString(),
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        location: json['location'] as String? ?? '',
        startsAt: DateTime.parse(json['starts_at'] as String),
      );

  @override
  List<Object?> get props => [id, title, description, startsAt, location];
}
