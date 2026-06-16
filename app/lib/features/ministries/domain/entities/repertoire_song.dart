import 'package:equatable/equatable.dart';

/// RF-016: música do repertório do Ministério de Louvor, cadastrada por
/// qualquer membro do ministério.
class RepertoireSong extends Equatable {
  const RepertoireSong({
    required this.id,
    required this.title,
    required this.key,
    this.referenceUrl,
    required this.addedBy,
  });

  final String id;
  final String title;

  /// Tom da música (ex.: "G", "D", "Capo 2").
  final String key;

  /// Link de referência/versão (ex.: YouTube).
  final String? referenceUrl;

  final String addedBy;

  @override
  List<Object?> get props => [id, title, key, referenceUrl, addedBy];
}
