import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/church_banner.dart';

/// Estado do feed de banners/posts (RF-005).
///
/// TODO(backend): substituir `_mockBanners` por GET /api/banners/ e enviar
/// curtidas para POST /api/banners/{id}/like/.
class BannersCubit extends Cubit<List<ChurchBanner>> {
  BannersCubit() : super(_mockBanners);

  void toggleLike(String bannerId) {
    emit([
      for (final banner in state)
        if (banner.id == bannerId)
          banner.copyWith(
            likedByMe: !banner.likedByMe,
            likeCount: banner.likedByMe ? banner.likeCount - 1 : banner.likeCount + 1,
          )
        else
          banner,
    ]);
  }

  /// RF-008c: Mídia/Pastor publica um novo post no carrossel.
  void createPost({
    required String title,
    required String description,
    required BannerKind kind,
    required BannerMediaType mediaType,
  }) {
    final banner = ChurchBanner(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: description,
      mediaUrl: '',
      mediaType: mediaType,
      kind: kind,
      startsAt: DateTime.now(),
    );
    emit([banner, ...state]);
  }
}

final _mockBanners = [
  ChurchBanner(
    id: '1',
    title: 'Culto de Celebração',
    description: 'Domingo às 18h — Tema: "Fé em ação". Venha celebrar com a família IBBE!',
    mediaUrl: '',
    mediaType: BannerMediaType.photo,
    kind: BannerKind.service,
    startsAt: DateTime.now().add(const Duration(days: 2)),
    likeCount: 42,
    commentCount: 5,
  ),
  ChurchBanner(
    id: '2',
    title: 'Conferência de Louvor',
    description: 'Sexta e sábado — Ministério de Louvor. Inscrições abertas!',
    mediaUrl: '',
    mediaType: BannerMediaType.video,
    kind: BannerKind.event,
    startsAt: DateTime.now().add(const Duration(days: 5)),
    likeCount: 18,
    commentCount: 2,
  ),
  ChurchBanner(
    id: '3',
    title: 'Palavra do Pastor',
    description: '"Andando pela fé" — reflexão para a semana.',
    mediaUrl: '',
    mediaType: BannerMediaType.photo,
    kind: BannerKind.word,
    startsAt: DateTime.now(),
    likeCount: 67,
    commentCount: 12,
  ),
];
