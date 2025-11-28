import 'package:anime_discovery_app_v2/core/constants/api_constants.dart';
import 'package:anime_discovery_app_v2/core/network/dio_client.dart';
import 'package:anime_discovery_app_v2/models/dtos/anime_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'anime_api_services.g.dart';

class AnimeApiServices {
  final Dio _dio;

  AnimeApiServices(this._dio);

  Future<AnimeResponseDto> getPopularAnime({
    int offset = 0,
    int limit = ApiConstants.pageSize,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      ApiConstants.getAnimeUrl,
      queryParameters: {
        'sort': '-user_count',
        'page[limit]': limit,
        'page[offset]': offset,
      },
      cancelToken: cancelToken,
    );

    return AnimeResponseDto.fromJson(response.data);
  }

  Future<AnimeResponseDto> seachAnime({
    required String query,
    int offset = 0,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      ApiConstants.getAnimeUrl,
      queryParameters: {
        'filter[text]': query,
        'page[limit]': ApiConstants.pageSize,
        'page[offset]': offset,
      },
      cancelToken: cancelToken,
    );

    return AnimeResponseDto.fromJson(response.data);
  }
}

@riverpod
AnimeApiServices animeApiServices(Ref ref) {
  return AnimeApiServices(ref.watch(dioProvider));
}
