import 'package:anime_discovery_app_v2/models/entities/anime.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'anime_dto.freezed.dart';
part 'anime_dto.g.dart';

@freezed
abstract class AnimeDto with _$AnimeDto {
  const factory AnimeDto({
    required String id,
    required AnimeAttributesDto attributes,
  }) = _AnimeDto;

  factory AnimeDto.fromJson(Map<String, dynamic> json) =>
      _$AnimeDtoFromJson(json);
}

@freezed
abstract class AnimeAttributesDto with _$AnimeAttributesDto {
  const factory AnimeAttributesDto({
    String? canonicalTitle,
    String? synopsis,
    String? averageRating,
    int? episodeCount,
    String? status,
    AnimePosterDto? posterImage,
  }) = _AnimeAttributesDto;

  factory AnimeAttributesDto.fromJson(Map<String, dynamic> json) =>
      _$AnimeAttributesDtoFromJson(json);
}

@freezed
abstract class AnimePosterDto with _$AnimePosterDto {
  const factory AnimePosterDto({
    String? small,
    String? medium,
    String? large,
    String? original,
  }) = _AnimePosterDto;

  factory AnimePosterDto.fromJson(Map<String, dynamic> json) =>
      _$AnimePosterDtoFromJson(json);
}

extension AnimeDtoMapper on AnimeDto {
  Anime toEntity() {
    return Anime(
      id: id,
      title: attributes.canonicalTitle ?? 'Unknown',
      posterUrl: attributes.posterImage?.medium,
      rating: double.tryParse(attributes.averageRating ?? '0') ?? 0,
      synopsis: attributes.synopsis,
      episodeCount: attributes.episodeCount,
      status: attributes.status ?? 'unknown',
    );
  }
}
