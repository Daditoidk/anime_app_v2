import 'package:anime_discovery_app_v2/core/errors/failure.dart';
import 'package:anime_discovery_app_v2/models/states/anime_list_state.dart';
import 'package:anime_discovery_app_v2/repositories/anime_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'anime_list_viewmodel.g.dart';

@riverpod
class AnimeListViewmodel extends _$AnimeListViewmodel {
  @override
  AnimeListState build() {
    state = const AnimeListState(isLoading: true);
    _loadAnimes();
    return state;
  }

  Future<void> _loadAnimes() async {
    final repository = ref.watch(animeRepositoryProvider);
    final response = await repository.getPopularAnime();

    // if (!ref.mounted) return;

    response.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.displayMessage,
          ),
      (animes) => state = state.copyWith(isLoading: false, animes: animes),
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: false,
      isRefreshing: true,
      errorMessage: null,
    );

    final repository = ref.watch(animeRepositoryProvider);
    final response = await repository.getPopularAnime();

    // if (!ref.mounted) return;

    response.fold(
      (failure) =>
          state = state.copyWith(
            isRefreshing: false,
            errorMessage: failure.displayMessage,
          ),
      (animes) => state = state.copyWith(isRefreshing: false, animes: animes),
    );
  }

  void retry() {
    state = const AnimeListState(isLoading: true, isRefreshing: false);
    _loadAnimes();
  }
}
