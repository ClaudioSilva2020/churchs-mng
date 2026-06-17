import 'package:equatable/equatable.dart';

/// RF-016: associação entre uma música do repertório e o(s) vocalista(s)
/// designado(s) para um culto específico.
class RepertoireAssignment extends Equatable {
  const RepertoireAssignment({
    required this.songId,
    required this.songTitle,
    required this.vocalistId,
    required this.vocalistName,
  });

  final String songId;
  final String songTitle;
  final String vocalistId;
  final String vocalistName;

  factory RepertoireAssignment.fromJson(Map<String, dynamic> json) =>
      RepertoireAssignment(
        songId: json['song'].toString(),
        songTitle: json['song_title'] as String? ?? '',
        vocalistId: json['vocalist'].toString(),
        vocalistName: json['vocalist_name'] as String? ?? '',
      );

  @override
  List<Object?> get props => [songId, songTitle, vocalistId, vocalistName];
}

/// RF-016: plano de louvor de um culto — quais músicas serão cantadas e por
/// quem, montado pelo Líder do Ministério de Louvor.
class RepertoirePlan extends Equatable {
  const RepertoirePlan({
    required this.id,
    required this.serviceDate,
    required this.assignments,
  });

  final String id;
  final DateTime serviceDate;
  final List<RepertoireAssignment> assignments;

  factory RepertoirePlan.fromJson(Map<String, dynamic> json) => RepertoirePlan(
        id: json['id'].toString(),
        serviceDate: DateTime.parse(json['service_date'] as String),
        assignments: (json['assignments'] as List<dynamic>)
            .map((e) => RepertoireAssignment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [id, serviceDate, assignments];
}
