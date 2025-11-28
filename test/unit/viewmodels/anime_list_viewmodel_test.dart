import 'package:anime_discovery_app_v2/core/errors/failure.dart';
import 'package:anime_discovery_app_v2/models/entities/anime.dart';
import 'package:anime_discovery_app_v2/models/states/anime_list_state.dart';
import 'package:anime_discovery_app_v2/repositories/anime_repository.dart';
import 'package:anime_discovery_app_v2/viewmodels/anime_list_viewmodel.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAnimeRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const AnimeListState(isLoading: true));
  });
  setUp(() {
    mockRepository = MockAnimeRepository();
  });

  final tAnimes = [
    Anime(
      id: '1',
      title: 'Naruto',
      rating: 8.5,
      status: 'finished',
      posterUrl: '',
      synopsis: '',
      episodeCount: null,
    ),
    Anime(
      id: '2',
      title: 'One Piece',
      rating: 9.0,
      status: 'current',
      posterUrl: '',
      synopsis: '',
      episodeCount: null,
    ),
  ];

  group('AnimeListViewModel', () {
    test('initial state shoudl be loading', () async {
      when(
        () => mockRepository.getPopularAnime(),
      ).thenAnswer((_) async => Right(tAnimes));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeListState>();
      container.listen(
        animeListViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeListViewmodelProvider);

      await waitShort();


      expect(listener.states[0].isLoading, true);
    });
    test('should load animes succefully', () async {
      when(
        () => mockRepository.getPopularAnime(),
      ).thenAnswer((_) async => Right(tAnimes));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeListState>();
      container.listen(
        animeListViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeListViewmodelProvider);

      await waitShort();


      expect(listener.states[0].isLoading, true);
      expect(listener.states[1].isLoading, false);
      expect(listener.states[1].animes.length, 2);
      expect(listener.states[1].hasError, false);
    });

    test('should handle error when loading animes fails', () async {
      when(
        () => mockRepository.getPopularAnime(),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Server error')));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeListState>();
      container.listen(
        animeListViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeListViewmodelProvider);

      await waitShort();


      expect(listener.states[0].isLoading, true);
      expect(listener.states[1].isLoading, false);
      expect(listener.states[1].hasError, true);
      expect(listener.states[1].errorMessage, 'Server error');
    });

    test('should refresh animes successfully', () async {
      var count = 0;

      when(() => mockRepository.getPopularAnime()).thenAnswer((_) async {
        count++;
        return Right(tAnimes);
      });

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeListState>();
      container.listen(
        animeListViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      final viewModel = container.read(animeListViewmodelProvider.notifier);

      // Initial load
      container.read(animeListViewmodelProvider);
      await waitShort();

      // Refresh
      await viewModel.refresh();
      await waitShort();


      expect(listener.states[0].isLoading, true);
      expect(listener.states[1].isLoading, false);
      expect(listener.states[1].animes.length, 2);
      expect(listener.states[2].isRefreshing, true);
      expect(listener.states[3].isRefreshing, false);
      expect(listener.states[3].animes.length, 2);
      expect(count, 2);
    });

    test('should handle error when refresh fails', () async {
      when(
        () => mockRepository.getPopularAnime(),
      ).thenAnswer((_) async => Right(tAnimes));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeListState>();
      container.listen(
        animeListViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      final viewModel = container.read(animeListViewmodelProvider.notifier);

      // Initial load
      container.read(animeListViewmodelProvider);
      await waitShort();

      // Set up failure for refresh
      when(() => mockRepository.getPopularAnime()).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Server error on refresh')),
      );

      // Refresh
      await viewModel.refresh();
      await waitShort();


      expect(listener.states[0].isLoading, true);
      expect(listener.states[1].isLoading, false);
      expect(listener.states[1].animes.length, 2);
      expect(listener.states[2].isRefreshing, true);
      expect(listener.states[3].isRefreshing, false);
      expect(listener.states[3].hasError, true);
      expect(listener.states[3].errorMessage, 'Server error on refresh');
    });

    test('should retry loading animes after failure', () async {
      when(() => mockRepository.getPopularAnime()).thenAnswer(
        (_) async => Left(ServerFailure(message: 'Initial load failure')),
      );

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeListState>();
      container.listen(
        animeListViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      final viewModel = container.read(animeListViewmodelProvider.notifier);

      // Initial load (fails)
      container.read(animeListViewmodelProvider);
      await waitShort();

      // Set up success for retry
      when(
        () => mockRepository.getPopularAnime(),
      ).thenAnswer((_) async => Right(tAnimes));

      // Retry
      viewModel.retry();
      await waitShort();


      expect(listener.states[0].isLoading, true);
      expect(listener.states[1].isLoading, false);
      expect(listener.states[1].hasError, true);
      expect(listener.states[2].isLoading, true);
      expect(listener.states[3].isLoading, false);
      expect(listener.states[3].animes.length, 2);
      expect(listener.states[3].hasError, false);
    });

    test('should handle empty anime list', () async {
      when(
        () => mockRepository.getPopularAnime(),
      ).thenAnswer((_) async => Right([]));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeListState>();
      container.listen(
        animeListViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeListViewmodelProvider);

      await waitShort();


      expect(listener.states[0].isLoading, true);
      expect(listener.states[1].isLoading, false);
      expect(listener.states[1].animes.isEmpty, true);
      expect(listener.states[1].isEmpty, true);
    });
  });
}
