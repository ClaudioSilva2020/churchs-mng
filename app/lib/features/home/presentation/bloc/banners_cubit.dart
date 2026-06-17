import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/banners_api_service.dart';
import '../../domain/entities/church_banner.dart';

/// RF-005/RF-008c: feed de banners/posts (Avisos e Eventos).
class BannersCubit extends Cubit<List<ChurchBanner>> {
  BannersCubit(this._api) : super(const []) {
    _load();
  }

  final BannersApiService _api;

  Future<void> _load() async {
    try {
      emit(await _api.fetchBanners());
    } catch (_) {
      // mantém lista vazia; o usuário pode tentar novamente (pull-to-refresh futuro)
    }
  }

  Future<void> toggleLike(String bannerId) async {
    final banner = state.firstWhere((b) => b.id == bannerId);
    // Atualização otimista
    emit([
      for (final b in state)
        if (b.id == bannerId)
          b.copyWith(
            likedByMe: !b.likedByMe,
            likeCount: b.likedByMe ? b.likeCount - 1 : b.likeCount + 1,
          )
        else
          b,
    ]);
    try {
      await _api.toggleLike(bannerId: bannerId, currentlyLiked: banner.likedByMe);
    } catch (_) {
      // Reverte em caso de erro
      emit([
        for (final b in state)
          if (b.id == bannerId)
            b.copyWith(
              likedByMe: banner.likedByMe,
              likeCount: banner.likeCount,
            )
          else
            b,
      ]);
    }
  }

  void incrementCommentCount(String bannerId) {
    emit([
      for (final b in state)
        if (b.id == bannerId) b.copyWith(commentCount: b.commentCount + 1) else b,
    ]);
  }

  /// RF-008c: Mídia/Pastor/Líder publica um novo post.
  Future<bool> createPost({
    required String title,
    required String description,
    required BannerKind kind,
    required BannerMediaType mediaType,
  }) async {
    try {
      final banner = await _api.createPost(
        title: title,
        description: description,
        kind: kind.name,
        mediaType: mediaType == BannerMediaType.video ? 'video' : 'image',
      );
      emit([banner, ...state]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updatePost({
    required String id,
    required String title,
    required String description,
  }) async {
    try {
      final updated = await _api.updatePost(id: id, title: title, description: description);
      emit([for (final b in state) if (b.id == id) updated else b]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deletePost(String id) async {
    try {
      await _api.deletePost(id);
      emit(state.where((b) => b.id != id).toList());
      return true;
    } catch (_) {
      return false;
    }
  }
}
