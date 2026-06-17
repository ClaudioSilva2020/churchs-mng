import 'package:dio/dio.dart';

import '../domain/entities/banner_comment.dart';
import '../domain/entities/church_banner.dart';

class BannersApiService {
  BannersApiService(this._dio);

  final Dio _dio;

  Future<List<ChurchBanner>> fetchBanners() async {
    final response = await _dio.get('/banners/');
    return (response.data as List)
        .map((json) => ChurchBanner.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> toggleLike({required String bannerId, required bool currentlyLiked}) async {
    if (currentlyLiked) {
      await _dio.delete('/banners/$bannerId/like/');
    } else {
      await _dio.post('/banners/$bannerId/like/');
    }
  }

  Future<ChurchBanner> createPost({
    required String title,
    required String description,
    required String kind,
    required String mediaType,
  }) async {
    final response = await _dio.post('/banners/', data: {
      'title': title,
      'description': description,
      'kind': kind,
      'media_type': mediaType,
    });
    return ChurchBanner.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<BannerComment>> fetchComments(String bannerId) async {
    final response = await _dio.get('/banners/$bannerId/comments/');
    final list = response.data as List<dynamic>;
    return list.map((e) => BannerComment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BannerComment> postComment(String bannerId, String text) async {
    final response = await _dio.post('/banners/$bannerId/comments/', data: {'text': text});
    return BannerComment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ChurchBanner> updatePost({
    required String id,
    required String title,
    required String description,
  }) async {
    final response = await _dio.patch('/banners/$id/', data: {
      'title': title,
      'description': description,
    });
    return ChurchBanner.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deletePost(String id) async {
    await _dio.delete('/banners/$id/');
  }
}
