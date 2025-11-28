class Anime {
  final String id;
  final String title;
  final String? posterUrl;
  final double rating;
  final String? synopsis;
  final int? episodeCount;
  final String status;

  Anime({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.rating,
    required this.synopsis,
    required this.episodeCount,
    required this.status,
  });
}
