import 'package:anime_discovery_app_v2/core/errors/failure.dart';
import 'package:anime_discovery_app_v2/models/entities/anime.dart';
import 'package:anime_discovery_app_v2/models/states/anime_list_state.dart';
import 'package:anime_discovery_app_v2/models/states/anime_search_state.dart';
import 'package:anime_discovery_app_v2/repositories/anime_repository.dart';
import 'package:anime_discovery_app_v2/viewmodels/anime_list_viewmodel.dart';
import 'package:anime_discovery_app_v2/viewmodels/anime_search_viewmodel.dart';
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

  group('SearchAnime feature', () {
    String tQuery = 'Naruto';
    final tAnimeResult = [
      Anime(
        id: '1',
        title: 'Naruto',
        rating: 8.5,
        status: 'finished',
        posterUrl: '',
        synopsis: '',
        episodeCount: null,
      ),
    ];

    test(
      'initial state should be active = false and has a empty list',
      () async {
        when(
          () => mockRepository.searchAnime(
            query: tQuery,
            cancelToken: any(named: 'cancelToken'),
          ),
        ).thenAnswer((_) async => Right(tAnimeResult));

        final container = createTestContainer(
          overrides: [
            animeRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        final listener = Listener<AnimeSearchState>();
        container.listen(
          animeSearchViewmodelProvider,
          listener.call,
          fireImmediately: true,
        );

        container.read(animeSearchViewmodelProvider.notifier).activateSearch();
        container.read(animeSearchViewmodelProvider);

        await waitShort();

        expect(listener.states[0].isActive, false);
        expect(listener.states[1].isActive, true);
        expect(listener.states[0].hasData, false);
        expect(listener.states[1].hasData, false);
      },
    );
    test('should get animes on search success', () async {
      when(
        () => mockRepository.searchAnime(
          query: tQuery,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(tAnimeResult));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeSearchState>();
      container.listen(
        animeSearchViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeSearchViewmodelProvider.notifier).activateSearch();
      final notifier = container.read(animeSearchViewmodelProvider.notifier);

      notifier.onQueryChanged(tQuery);
      await waitForDebounce();
      await waitShort();

      expect(listener.states[0].isActive, false);
      expect(listener.states[1].isActive, true);
      expect(listener.states[2].query, isNotEmpty);
      expect(listener.states[3].isSearching, true);
      expect(listener.states[4].isSearching, false);
      expect(listener.states[4].results.length, 1);
      expect(listener.states[4].hasError, false);
    });
    test('should handle error on search failure', () async {
      when(
        () => mockRepository.searchAnime(
          query: tQuery,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Search error')));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeSearchState>();
      container.listen(
        animeSearchViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeSearchViewmodelProvider.notifier).activateSearch();
      final notifier = container.read(animeSearchViewmodelProvider.notifier);

      notifier.onQueryChanged(tQuery);
      await waitForDebounce();
      await waitShort();

      expect(listener.states[0].isActive, false);
      expect(listener.states[1].isActive, true);
      expect(listener.states[2].query, isNotEmpty);
      expect(listener.states[3].isSearching, true);
      expect(listener.states[4].isSearching, false);
      expect(listener.states[4].results, isEmpty);
      expect(listener.states[4].hasError, true);
    });
    test('should clear search properly', () async {
      when(
        () => mockRepository.searchAnime(
          query: tQuery,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(tAnimeResult));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeSearchState>();
      container.listen(
        animeSearchViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeSearchViewmodelProvider.notifier).activateSearch();
      final notifier = container.read(animeSearchViewmodelProvider.notifier);

      notifier.onQueryChanged(tQuery);
      await waitForDebounce();
      await waitShort();

      notifier.clearSearch();
      await waitShort();

      expect(listener.states[0].isActive, false);
      expect(listener.states[1].isActive, true);
      expect(listener.states[2].query, isNotEmpty);
      expect(listener.states[3].isSearching, true);
      expect(listener.states[4].isSearching, false);
      expect(listener.states[4].results.length, 1);
      expect(listener.states[4].hasError, false);
      expect(listener.states[5].query, isEmpty);
      expect(listener.states[5].isSearching, false);
      expect(listener.states[5].hasError, false);
      expect(listener.states[5].results, isEmpty);
      expect(listener.states[5].isActive, true);
    });
    test('should not perform search for empty query', () async {
      final newTQuery = '   ';

      when(
        () => mockRepository.searchAnime(
          query: tQuery,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(tAnimeResult));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeSearchState>();
      container.listen(
        animeSearchViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeSearchViewmodelProvider.notifier).activateSearch();
      final notifier = container.read(animeSearchViewmodelProvider.notifier);

      notifier.onQueryChanged(newTQuery);
      await waitShort();

      expect(listener.states[0].isActive, false);
      expect(listener.states[1].isActive, true);
      expect(listener.states.length, 2);
    });
    test('should debounce search queries', () async {
      when(
        () => mockRepository.searchAnime(
          query: tQuery,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(tAnimeResult));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeSearchState>();
      container.listen(
        animeSearchViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeSearchViewmodelProvider.notifier).activateSearch();
      final notifier = container.read(animeSearchViewmodelProvider.notifier);

      notifier.onQueryChanged(tQuery);

      tQuery += ' Uz';

      when(
        () => mockRepository.searchAnime(
          query: tQuery,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(tAnimeResult));

      notifier.onQueryChanged(tQuery);
      await waitForDebounce();
      await waitShort();

      expect(listener.states[0].isActive, false);
      expect(listener.states[1].isActive, true);
      expect(listener.states[2].query, 'Naruto');
      expect(listener.states[2].isSearching, false);
      expect(listener.states[3].query, 'Naruto Uz');
      expect(listener.states[3].isSearching, false);
      expect(listener.states[4].isSearching, true);
      expect(listener.states[5].isSearching, false);
      expect(listener.states[5].results.length, 1);
      expect(listener.states.length, 6);
    });

    test('should retry search after failure', () async {
      when(
        () => mockRepository.searchAnime(
          query: tQuery,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Search error')));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeSearchState>();
      container.listen(
        animeSearchViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeSearchViewmodelProvider.notifier).activateSearch();
      final notifier = container.read(animeSearchViewmodelProvider.notifier);

      notifier.onQueryChanged(tQuery);
      await waitForDebounce();
      await waitShort();

      when(
        () => mockRepository.searchAnime(
          query: tQuery,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(tAnimeResult));

      notifier.retry();
      await waitForDebounce();
      await waitShort();

      //init active state
      expect(listener.states[0].isActive, false);
      expect(listener.states[1].isActive, true);

      //write query
      expect(listener.states[2].query, isNotEmpty);

      //start searching
      expect(listener.states[3].isSearching, true);

      //search failed
      expect(listener.states[4].isSearching, false);
      expect(listener.states[4].hasError, true);

      //reset state for retry
      expect(listener.states[5].query, isNotEmpty);
      expect(listener.states[5].isSearching, false);
      expect(listener.states[5].hasError, false);
      //retry searching
      expect(listener.states[6].isSearching, true);
      //search success
      expect(listener.states[7].isSearching, false);
      expect(listener.states[7].results, isNotEmpty);
    });
    test('should handle empty search results', () async {
      when(
        () => mockRepository.searchAnime(
          query: tQuery,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right([]));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeSearchState>();
      container.listen(
        animeSearchViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeSearchViewmodelProvider.notifier).activateSearch();
      final notifier = container.read(animeSearchViewmodelProvider.notifier);

      notifier.onQueryChanged(tQuery);
      await waitForDebounce();
      await waitShort();

      //init active state
      expect(listener.states[0].isActive, false);
      expect(listener.states[1].isActive, true);

      //write query
      expect(listener.states[2].query, isNotEmpty);

      //start searching
      expect(listener.states[3].isSearching, true);

      //search success with empty results
      expect(listener.states[4].isSearching, false);
      expect(listener.states[4].showNoResults, true);
    });

    test('should cancel previous search on new query', () async {
      const firstQuery = 'Naruto';
      const secondQuery = 'Bleach';

      when(
        () => mockRepository.searchAnime(
          query: secondQuery,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(tAnimeResult));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeSearchState>();
      container.listen(
        animeSearchViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeSearchViewmodelProvider.notifier).activateSearch();
      final notifier = container.read(animeSearchViewmodelProvider.notifier);

      notifier.onQueryChanged(firstQuery);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      notifier.onQueryChanged(secondQuery);

      await waitForDebounce();
      await waitShort();

      verifyNever(
        () => mockRepository.searchAnime(
          query: firstQuery,
          cancelToken: any(named: 'cancelToken'),
        ),
      );
      verify(
        () => mockRepository.searchAnime(
          query: secondQuery,
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);

      expect(listener.states[0].isActive, false);
      expect(listener.states[1].isActive, true);
      expect(listener.states[2].query, firstQuery);
      expect(listener.states[3].query, secondQuery);
      expect(listener.states[4].isSearching, true);
      expect(listener.states[5].isSearching, false);
      expect(listener.states[5].results, isNotEmpty);
    });

    test('should handle search query changes', () async {
      const query = '  Naruto  ';

      when(
        () => mockRepository.searchAnime(
          query: 'Naruto',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Right(tAnimeResult));

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeSearchState>();
      container.listen(
        animeSearchViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeSearchViewmodelProvider.notifier).activateSearch();
      final notifier = container.read(animeSearchViewmodelProvider.notifier);

      notifier.onQueryChanged(query);
      await waitForDebounce();
      await waitShort();

      notifier.onQueryChanged('Naruto');
      await waitShort();

      expect(listener.states[0].isActive, false);
      expect(listener.states[1].isActive, true);
      expect(listener.states[2].query, 'Naruto');
      expect(listener.states[3].isSearching, true);
      expect(listener.states[4].isSearching, false);
      expect(listener.states[4].results, isNotEmpty);
      expect(listener.states.length, 5);
    });

    test('should deactivate search properly', () async {
      const query = 'Naruto';

      final container = createTestContainer(
        overrides: [animeRepositoryProvider.overrideWithValue(mockRepository)],
      );

      final listener = Listener<AnimeSearchState>();
      container.listen(
        animeSearchViewmodelProvider,
        listener.call,
        fireImmediately: true,
      );

      container.read(animeSearchViewmodelProvider.notifier).activateSearch();
      final notifier = container.read(animeSearchViewmodelProvider.notifier);

      notifier.onQueryChanged(query);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      notifier.deactivateSearch();
      await waitForDebounce();
      await waitShort();

      verifyNever(
        () => mockRepository.searchAnime(
          query: query,
          cancelToken: any(named: 'cancelToken'),
        ),
      );

      expect(listener.states[0].isActive, false);
      expect(listener.states[1].isActive, true);
      expect(listener.states[2].query, query);
      expect(listener.states[3].isActive, false);
      expect(listener.states[3].query, isEmpty);
      expect(listener.states[3].results, isEmpty);
    });
  });
}
