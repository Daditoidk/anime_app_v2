import 'dart:async';

import 'package:anime_discovery_app_v2/models/states/anime_search_state.dart';
import 'package:anime_discovery_app_v2/repositories/anime_repository.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'anime_search_viewmodel.g.dart';

@riverpod
class AnimeSearchViewmodel extends _$AnimeSearchViewmodel {
  Timer? _searchDebounce;
  CancelToken? _cancelToken;
  String previousQuery = '';

  @override
  AnimeSearchState build() {
    ref.onDispose(() {
      _searchDebounce?.cancel();
      _cancelToken?.cancel();
    });
    return const AnimeSearchState();
  }

  void activateDeactivateSearch() {
    if (state.isActive) {
      deactivateSearch();
    } else {
      state = state.copyWith(isActive: true);
    }
  }

  void deactivateSearch() {
    _cancelToken?.cancel('Search deactivated by user');
    _searchDebounce?.cancel();
    previousQuery = '';
    state = const AnimeSearchState();
  }

  void onQueryChanged(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;
    if (previousQuery.isEmpty) previousQuery = trimmedQuery;
    if (trimmedQuery == previousQuery) return;

    _searchDebounce?.cancel();

    state = state.copyWith(query: trimmedQuery);

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      await performSearch(trimmedQuery);
    });
  }

  void clearSearch() {
    _cancelToken?.cancel('Search cleared by user');
    _searchDebounce?.cancel();
    previousQuery = '';
    state = const AnimeSearchState(isActive: true);
  }

  Future<void> performSearch(String query) async {
    _cancelToken?.cancel('Cancelled due to new search query');
    _cancelToken = CancelToken();

    state = state.copyWith(isSearching: true, errorMessage: null);

    final repo = ref.watch(animeRepositoryProvider);
    final response = await repo.searchAnime(
      query: query,
      cancelToken: _cancelToken,
    );
    // if (!ref.mounted) return;

    response.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (result) {
        state = state.copyWith(results: result);
      },
    );
    state = state.copyWith(isSearching: false);
  }
}
