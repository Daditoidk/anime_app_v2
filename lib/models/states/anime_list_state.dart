import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/anime.dart';

part 'anime_list_state.freezed.dart';

@freezed
abstract class AnimeListState with _$AnimeListState {
  const factory AnimeListState({
    @Default([]) List<Anime> animes,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    String? errorMessage,
  }) = _AnimeListState;

  const AnimeListState._();

  bool get hasError => errorMessage != null;
  bool get isEmpty => animes.isEmpty && !isLoading && !hasError;
  bool get hasData => animes.isNotEmpty;
}
