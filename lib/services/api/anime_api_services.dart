import 'package:anime_discovery_app_v2/core/constants/api_constants.dart';
import 'package:anime_discovery_app_v2/models/dtos/anime_dto.dart';
import 'package:dio/dio.dart';

class AnimeApiServices {
  final Dio _dio;

  AnimeApiServices(this._dio);

  Future<AnimeDto> getPopularAnime({
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

    final json = response.data['data'];

    return AnimeDto.fromJson(json);
  }
}
