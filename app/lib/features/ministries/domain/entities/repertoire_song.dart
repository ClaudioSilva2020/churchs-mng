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

  factory RepertoireSong.fromJson(Map<String, dynamic> json) => RepertoireSong(
        id: json['id'].toString(),
        title: json['title'] as String? ?? '',
        key: json['key'] as String? ?? '',
        referenceUrl: (json['reference_url'] as String?)?.isNotEmpty == true
            ? json['reference_url'] as String
            : null,
        addedBy: json['added_by_name'] as String? ?? '',
      );

  @override
  List<Object?> get props => [id, title, key, referenceUrl, addedBy];
}
