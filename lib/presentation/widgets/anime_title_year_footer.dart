import 'package:flutter/material.dart';
import 'package:a_watch/domain/entities/anime.dart';
import 'package:a_watch/core/theme/design_tokens.dart';

class AnimeTitleYearFooter extends StatelessWidget {
  final Anime anime;

  const AnimeTitleYearFooter({
    super.key,
    required this.anime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.spacingSM,
        0,
        DesignTokens.spacingSM,
        DesignTokens.spacingSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            anime.title,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 2),

          // Year
          if (anime.year != null)
            Text(
              anime.year!,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
