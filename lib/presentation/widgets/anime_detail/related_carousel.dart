import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:flutter/material.dart';
import 'package:a_watch/core/theme/design_tokens.dart';
import 'package:a_watch/presentation/components/cards/hoverable_card.dart';

class RelatedCarousel extends StatefulWidget {
  final String title;
  final List<Anime> animeList;
  final Function(Anime)? onAnimeTap;

  const RelatedCarousel({
    super.key,
    required this.title,
    required this.animeList,
    this.onAnimeTap,
  });

  @override
  State<RelatedCarousel> createState() => _RelatedCarouselState();
}

class _RelatedCarouselState extends State<RelatedCarousel> {
  String _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) return 'https://yummyanime.tv$url';
    return 'https://yummyanime.tv/$url';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animeList.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Center(
          child: SizedBox(
            height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.animeList.map((anime) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: HoverableCard(
                    onTap: () => widget.onAnimeTap?.call(anime),
                    borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.15)
                              : colorScheme.outline.withValues(alpha: 0.08),
                          width: 1,
                        ),
                        boxShadow: [
                          if (theme.brightness != Brightness.dark)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Image.network(
                                _normalizeImageUrl(anime.poster),
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: colorScheme.surface,
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: colorScheme.surface,
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported, size: 24),
                                    ),
                                  );
                                },
                              ),
                            ),

                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.0),
                                      Colors.black.withValues(alpha: 0.8),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),

                            if (anime.rating != null)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [DesignTokens.softShadow],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, size: 10, color: Colors.white),
                                      const SizedBox(width: 2),
                                      Text(
                                        anime.rating!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            Positioned(
                              bottom: 6,
                              left: 6,
                              right: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    anime.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 2),

                                  if (anime.year != null)
                                    Text(
                                      anime.year!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
    )],
    );
  }
}
