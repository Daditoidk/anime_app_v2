import 'package:anime_discovery_app_v2/core/errors/failure.dart';
import 'package:anime_discovery_app_v2/models/dtos/anime_dto.dart';
import 'package:anime_discovery_app_v2/models/entities/anime.dart';
import 'package:anime_discovery_app_v2/services/api/anime_api_services.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'anime_repository.g.dart';

@riverpod
AnimeRepository animeRepository(Ref ref) {
  return AnimeRepositoryImpl(ref.watch(animeApiServicesProvider));
}

abstract class AnimeRepository {
  Future<Either<Failure, List<Anime>>> getPopularAnime({
    int offset = 0,
    CancelToken? cancelToken,
  });

  Future<Either<Failure, List<Anime>>> searchAnime({
    required String query,
    int offset = 0,
    CancelToken? cancelToken,
  });
}

class AnimeRepositoryImpl implements AnimeRepository {
  final AnimeApiServices _apiServices;
  AnimeRepositoryImpl(this._apiServices);

  @override
  Future<Either<Failure, List<Anime>>> getPopularAnime({
    int offset = 0,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _apiServices.getPopularAnime(
        offset: offset,
        cancelToken: cancelToken,
      );

      final animes = response.data.map((anime) => anime.toEntity()).toList();

      return Right(animes);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Anime>>> searchAnime({
    required String query,
    int offset = 0,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _apiServices.seachAnime(
        query: query,
        offset: offset,
        cancelToken: cancelToken,
      );

      final animes = response.data.map((anime) => anime.toEntity()).toList();

      return Right(animes);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return Right([]);
      }
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unexpected(message: e.toString()));
    }
  }

  Failure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const Failure.network();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return const Failure.notFound();
        }
        return Failure.server(statusCode: statusCode);
      default:
        return Failure.unexpected(message: e.message);
    }
  }
}
