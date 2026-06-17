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

  factory ServiceScheduleItem.fromJson(Map<String, dynamic> json) {
    return ServiceScheduleItem(
      id: json['id'].toString(),
      dayOfWeek: json['day_of_week'] as String,
      time: json['time'] as String,
      title: json['title'] as String,
      subtitle: (json['subtitle'] as String?)?.isNotEmpty == true ? json['subtitle'] as String : null,
    );
  }

  @override
  List<Object?> get props => [id, dayOfWeek, time, title, subtitle];
}
