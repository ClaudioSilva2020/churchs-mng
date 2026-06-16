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

  ChurchBanner copyWith({int? likeCount, int? commentCount, bool? likedByMe}) {
    return ChurchBanner(
      id: id,
      title: title,
      description: description,
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
