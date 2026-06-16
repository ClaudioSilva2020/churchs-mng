import 'package:equatable/equatable.dart';

/// RF-016: associação entre uma música do repertório e o(s) vocalista(s)
/// designado(s) para um culto específico.
class RepertoireAssignment extends Equatable {
  const RepertoireAssignment({required this.songId, required this.vocalist});

  final String songId;
  final String vocalist;

  @override
  List<Object?> get props => [songId, vocalist];
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

  @override
  List<Object?> get props => [id, serviceDate, assignments];
}
