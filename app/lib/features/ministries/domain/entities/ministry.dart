import 'package:equatable/equatable.dart';

/// RF-009 a RF-011: ministério, com líderes e servos.
class Ministry extends Equatable {
  const Ministry({
    required this.id,
    required this.name,
    required this.description,
    this.color,
    this.hasSchedule = false,
    this.hasRepertoire = false,
  });

  final String id;
  final String name;
  final String description;
  final String? color;

  /// RF-014: apenas Louvor, PGs, Missões, Libras e Mulheres têm escala.
  final bool hasSchedule;

  /// RF-016: apenas o Ministério de Louvor tem repertório de músicas.
  final bool hasRepertoire;

  factory Ministry.fromJson(Map<String, dynamic> json) {
    return Ministry(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      color: json['color'] as String?,
      hasSchedule: json['has_schedule'] as bool? ?? false,
      hasRepertoire: json['has_repertoire'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, description, color, hasSchedule, hasRepertoire];
}
