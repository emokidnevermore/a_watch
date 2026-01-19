import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/core/theme/design_tokens.dart';
import 'package:a_watch/presentation/components/cards/hoverable_card.dart';

/// Variants for the unified AnimeCard
enum CardVariant {
  /// Compact card with basic information (title, rating, year, type/status chips)
  compact,

  /// Detailed card with enhanced styling, hover effects, and hero animations
  detailed,

  /// Poster-only card with overlay text
  posterOnly,
}

/// Unified anime card widget supporting multiple variants
class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? heroTag;
  final CardVariant variant;
  final bool showDetails;

  const AnimeCard({
    super.key,
    required this.anime,
    this.onTap,
    this.onLongPress,
    this.heroTag,
    this.variant = CardVariant.detailed,
    this.showDetails = true,
  });

  String _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) return 'https://yummyanime.tv$url';
    return 'https://yummyanime.tv/$url';
  }

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case CardVariant.compact:
        return _buildCompactCard(context);
      case CardVariant.detailed:
        return _buildDetailedCard(context);
      case CardVariant.posterOnly:
        return _buildPosterOnlyCard(context);
    }
  }

  Widget _buildCompactCard(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: CachedNetworkImage(
                  imageUrl: _normalizeImageUrl(anime.poster),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.image_not_supported)),
                  memCacheWidth: 200, // Optimize memory usage
                  memCacheHeight: 300,
                ),
              ),
            ),

            // Information
            if (showDetails)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      anime.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Rating and year
                    Row(
                      children: [
                        if (anime.rating != null)
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                anime.rating!,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        if (anime.year != null)
                          Text(
                            anime.year!,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Status and type
                    Wrap(
                      spacing: 4,
                      children: [
                        if (anime.type != null)
                          Chip(
                            label: Text(
                              anime.type == 'serial' ? 'Сериал' : 'Фильм',
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: anime.type == 'serial'
                                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                                : Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                            labelStyle: TextStyle(
                              color: anime.type == 'serial'
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSecondaryContainer,
                              fontSize: 10,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          ),
                        if (anime.status != null)
                          Chip(
                            label: Text(
                              anime.status!,
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                              fontSize: 10,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDesktop =
        MediaQuery.of(context).size.width >= DesignTokens.desktopMinWidth;

    // Adaptive height based on childAspectRatio 2/3.0
    final cardHeight = isDesktop ? 200.0 : 240.0;

    return HoverableCard(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
      child: AnimatedCard(
        heroTag: heroTag,
        child: Container(
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
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
            child: SizedBox(
              height: cardHeight,
              child: _buildPosterCard(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPosterOnlyCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox.expand(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
              child: SizedBox.expand(
                child: CachedNetworkImage(
                  imageUrl: _normalizeImageUrl(anime.poster),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  placeholder: (context, url) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Container(
                      color: colorScheme.surface,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Container(
                      color: colorScheme.surface,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                    );
                  },
                  memCacheWidth: 300, // Optimize memory usage
                  memCacheHeight: 450,
                ),
              ),
            ),

            // Gradient overlay for text
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Rating badge
            if (anime.rating != null)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [DesignTokens.softShadow],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        anime.rating!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Episodes count badge
            if (anime.episodesCount != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [DesignTokens.softShadow],
                  ),
                  child: Text(
                    '${anime.episodesCount} серий',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Title and year overlay
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    anime.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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

                  // Year
                  if (anime.year != null)
                    Text(
                      anime.year!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
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
    );
  }

  Widget _buildPosterCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox.expand(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
              child: SizedBox.expand(
                child: CachedNetworkImage(
                  imageUrl: _normalizeImageUrl(anime.poster),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  placeholder: (context, url) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Container(
                      color: colorScheme.surface,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Container(
                      color: colorScheme.surface,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                    );
                  },
                  memCacheWidth: 300, // Optimize memory usage
                  memCacheHeight: 450,
                ),
              ),
            ),

            // Gradient overlay for text
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Rating badge
            if (anime.rating != null)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [DesignTokens.softShadow],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        anime.rating!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Episodes count badge
            if (anime.episodesCount != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [DesignTokens.softShadow],
                  ),
                  child: Text(
                    '${anime.episodesCount} серий',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Title and year overlay
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    anime.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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

                  // Year
                  if (anime.year != null)
                    Text(
                      anime.year!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
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
    );
  }
}

/// Collection card with background image and overlay text
class EnhancedCollectionCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final int itemCount;
  final VoidCallback? onTap;
  final String heroTag;

  const EnhancedCollectionCard({
    super.key,
    required this.title,
    this.imageUrl,
    required this.itemCount,
    this.onTap,
    required this.heroTag,
  });

  String _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('//')) return 'https:$url';
    if (url.startsWith('/')) return 'https://yummyanime.tv$url';
    return 'https://yummyanime.tv/$url';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return HoverableCard(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
      child: AnimatedCard(
        heroTag: heroTag,
        child: Container(
          constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
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
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.borderRadiusLG),
            child: Stack(
              children: [
                // Background image
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _normalizeImageUrl(imageUrl).isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: _normalizeImageUrl(imageUrl),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: colorScheme.surface,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: colorScheme.surface,
                            child: const Center(
                              child: Icon(Icons.collections, size: 40),
                            ),
                          ),
                          memCacheWidth: 240, // Optimize memory usage for collection cards
                          memCacheHeight: 160,
                        )
                      : Container(
                          color: colorScheme.secondary.withValues(alpha: 0.1),
                          child: const Center(
                            child: Icon(Icons.collections, size: 40),
                          ),
                        ),
                ),

                // Overlay gradient for text
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 70, // Уменьшенная высота градиента
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

                // Title and item count overlay
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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

                      // Item count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.movie,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$itemCount аниме',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
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
  }
}

/// Animated card wrapper for hero transitions
class AnimatedCard extends StatelessWidget {
  final String? heroTag;
  final Widget child;

  const AnimatedCard({
    super.key,
    required this.heroTag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: child,
      );
    }
    return child;
  }
}
