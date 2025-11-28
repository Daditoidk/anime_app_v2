import 'package:anime_discovery_app_v2/core/errors/failure.dart';
import 'package:anime_discovery_app_v2/models/dtos/anime_dto.dart';
import 'package:anime_discovery_app_v2/repositories/anime_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAnimeApiService mockAnimeApiService;
  late AnimeRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const AnimeResponseDto(data: []));
  });
  setUp(() {
    mockAnimeApiService = MockAnimeApiService();
    repository = AnimeRepositoryImpl(mockAnimeApiService);
  });

  final testResponse = AnimeResponseDto(
    data: [
      AnimeDto(
        id: '1',
        attributes: AnimeAttributesDto(
          canonicalTitle: 'Test Anime',
          averageRating: '85.5',
          status: 'current',
        ),
      ),
    ],
  );

  group('getPopularAnime', () {
    test('shoudl return list of animes on success', () async {
      when(
        () => mockAnimeApiService.getPopularAnime(
          offset: any(named: 'offset'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => testResponse);

      final result = await repository.getPopularAnime();

      expect(result.isRight(), true);
      result.fold((l) => fail('Should not be left'), (animes) {
        expect(animes.length, 1);
        expect(animes.first.title, 'Test Anime');
      });
    });

    test('should return Network Failure on connection error', () async {
      when(
        () => mockAnimeApiService.getPopularAnime(
          offset: any(named: 'offset'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.getPopularAnime();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<NetworkFailure>());
      }, (r) => fail('Should not be right'));
    });

    test('should return ServerFailure on 500 error', () async {
      when(
        () => mockAnimeApiService.getPopularAnime(
          offset: any(named: 'offset'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(statusCode: 500, requestOptions: RequestOptions()),
          requestOptions: RequestOptions(),
        ),
      );

      final result = await repository.getPopularAnime();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (r) => fail('Should not be right'),
      );
    });

    test('should return Failure on unexpected error', () async {
      when(
        () => mockAnimeApiService.getPopularAnime(
          offset: any(named: 'offset'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      final result = await repository.getPopularAnime();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<UnexpectedFailure>());
      }, (r) => fail('Should not be right'));
    });

    test('should return NotFoundFailure on 404 error', () async {
      when(
        () => mockAnimeApiService.getPopularAnime(
          offset: any(named: 'offset'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await repository.getPopularAnime();

      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<NotFoundFailure>());
      }, (animeList) => fail('should not be right'));
    });
  });

  group('SearchAnime feature', () {
    test('should return list of animes on successful search', () async {
      when(
        () => mockAnimeApiService.seachAnime(
          query: any(named: 'query'),
          offset: any(named: 'offset'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => testResponse);

      final result = await repository.searchAnime(query: 'Naruto');

      expect(result.isRight(), true);
      result.fold((l) => fail('Should not be left'), (animes) {
        expect(animes.length, 1);
        expect(animes.first.title, 'Test Anime');
      });
    });
    test(
      'should return a NetworkFailure on connection error during search',
      () async {
        when(
          () => mockAnimeApiService.seachAnime(
            query: any(named: 'query'),
            offset: any(named: 'offset'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await repository.searchAnime(query: 'Naruto');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (r) => fail('Should not be right'),
        );
      },
    );
    test(
      'should return a ServerFailure on server error durign search',
      () async {
        when(
          () => mockAnimeApiService.seachAnime(
            query: any(named: 'query'),
            offset: any(named: 'offset'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 500,
              requestOptions: RequestOptions(),
            ),
            requestOptions: RequestOptions(),
          ),
        );

        final result = await repository.searchAnime(query: 'Naruto');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (r) => fail('Should not be right'),
        );
      },
    );
    test(
      'should return a empty list when DioException type cancel get thrown',
      () async {
        when(
          () => mockAnimeApiService.seachAnime(
            query: any(named: 'query'),
            offset: any(named: 'offset'),
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.cancel,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await repository.searchAnime(query: 'Naruto');

        expect(result.isRight(), true);
        result.fold((l) => fail('Should not be left'), (animes) {
          expect(animes, isEmpty);
        });
      },
    );
  });
}
