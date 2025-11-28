import 'package:anime_discovery_app_v2/models/entities/anime.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onTap;

  const AnimeCard({super.key, required this.anime, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Poster
            SizedBox(
              width: 160,
              height: 240,
              child:
                  anime.posterUrl != null
                      ? CachedNetworkImage(
                        imageUrl: anime.posterUrl!,
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => const ColoredBox(
                              color: Colors.grey,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        errorWidget:
                            (_, __, ___) => const ColoredBox(
                              color: Colors.grey,
                              child: Icon(Icons.broken_image),
                            ),
                      )
                      : const ColoredBox(
                        color: Colors.grey,
                        child: Icon(Icons.movie),
                      ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(width: 4),
                    Text(
                      '★ ${anime.rating.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      anime.status.toUpperCase(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
