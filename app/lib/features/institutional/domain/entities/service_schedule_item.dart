import 'package:equatable/equatable.dart';

/// RF-007: item da programação semanal de cultos e eventos.
class ServiceScheduleItem extends Equatable {
  const ServiceScheduleItem({
    required this.id,
    required this.dayOfWeek,
    required this.time,
    required this.title,
    this.subtitle,
  });

  final String id;
  final String dayOfWeek;
  final String time;
  final String title;
  final String? subtitle;

  @override
  List<Object?> get props => [id, dayOfWeek, time, title, subtitle];
}
