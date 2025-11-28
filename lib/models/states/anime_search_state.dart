import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/anime.dart';

part 'anime_search_state.freezed.dart';

@freezed
abstract class AnimeSearchState with _$AnimeSearchState {
  const factory AnimeSearchState({
    @Default('') String query,
    @Default([]) List<Anime> results,
    @Default(false) bool isSearching,
    @Default(false) bool isActive,
    String? errorMessage,
  }) = _AnimeSearchState;

  const AnimeSearchState._();

  bool get hasError => errorMessage != null;
  bool get showNoResults =>
      isActive &&
      !isSearching &&
      results.isEmpty &&
      query.isNotEmpty &&
      !hasError;
  bool get hasData => results.isNotEmpty;
}
