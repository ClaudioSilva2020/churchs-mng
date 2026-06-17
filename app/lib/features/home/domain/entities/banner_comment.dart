import 'package:equatable/equatable.dart';

class BannerComment extends Equatable {
  const BannerComment({
    required this.id,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String authorName;
  final String text;
  final DateTime createdAt;

  factory BannerComment.fromJson(Map<String, dynamic> json) => BannerComment(
        id: json['id'].toString(),
        authorName: json['author_name'] as String? ?? '',
        text: json['text'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  @override
  List<Object?> get props => [id, authorName, text, createdAt];
}
