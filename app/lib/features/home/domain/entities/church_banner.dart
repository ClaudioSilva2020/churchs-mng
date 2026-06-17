import 'package:equatable/equatable.dart';

enum BannerKind { event, service, word }

enum BannerMediaType { photo, video }

/// RF-005: banners de eventos, cultos e palavras (sermões) dos pastores,
/// publicados pelo perfil Mídia/Pastor (RF-004b) em formato de post
/// (foto ou vídeo, com curtidas e comentários).
class ChurchBanner extends Equatable {
  const ChurchBanner({
    required this.id,
    required this.title,
    required this.description,
    required this.mediaUrl,
    required this.mediaType,
    required this.kind,
    required this.startsAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedByMe = false,
  });

  final String id;
  final String title;
  final String description;
  final String mediaUrl;
  final BannerMediaType mediaType;
  final BannerKind kind;
  final DateTime startsAt;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;

  factory ChurchBanner.fromJson(Map<String, dynamic> json) {
    return ChurchBanner(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      mediaUrl: json['image'] as String? ?? '',
      mediaType: json['media_type'] == 'video' ? BannerMediaType.video : BannerMediaType.photo,
      kind: _kindFromApi(json['kind'] as String? ?? 'post'),
      startsAt: json['starts_at'] != null
          ? DateTime.parse(json['starts_at'] as String)
          : DateTime.parse(json['created_at'] as String),
      likeCount: json['likes_count'] as int? ?? 0,
      commentCount: (json['comments'] as List?)?.length ?? 0,
      likedByMe: json['liked_by_me'] as bool? ?? false,
    );
  }

  static BannerKind _kindFromApi(String v) {
    switch (v) {
      case 'event': return BannerKind.event;
      case 'service': return BannerKind.service;
      case 'word': return BannerKind.word;
      default: return BannerKind.event;
    }
  }

  ChurchBanner copyWith({
    String? title,
    String? description,
    int? likeCount,
    int? commentCount,
    bool? likedByMe,
  }) {
    return ChurchBanner(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      kind: kind,
      startsAt: startsAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        mediaUrl,
        mediaType,
        kind,
        startsAt,
        likeCount,
        commentCount,
        likedByMe,
      ];
}
