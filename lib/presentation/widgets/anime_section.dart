import 'package:flutter/material.dart';
import 'package:a_watch/features/anime/domain/entities/anime.dart';
import 'package:a_watch/features/anime/presentation/widgets/cards/index.dart';
import 'package:a_watch/core/theme/scroll_behavior.dart';
import 'package:a_watch/core/theme/responsive_layout.dart';

class AnimeSection extends StatelessWidget {
  final String title;
  final List<Anime> animes;
  final VoidCallback? onRefresh;
  final VoidCallback? onTitleTap;

  const AnimeSection({
    super.key,
    required this.title,
    required this.animes,
    this.onRefresh,
    this.onTitleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: ResponsiveLayout.getSpacing(context, SpacingType.lg)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок раздела
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveLayout.getSpacing(context, SpacingType.lg)
            ),
            child: Row(
              children: [
                onTitleTap != null
                    ? InkWell(
                        onTap: onTitleTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: ResponsiveLayout.getTextSize(context, TextSize.xl),
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        title,
                        style: TextStyle(
                          fontSize: ResponsiveLayout.getTextSize(context, TextSize.xl),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const Spacer(),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Обновить',
                    onPressed: onRefresh,
                  ),
              ],
            ),
          ),

          SizedBox(height: ResponsiveLayout.getSpacing(context, SpacingType.xs)),

          // Содержимое раздела - unified responsive layout
          ResponsiveLayout.buildResponsive(
            context: context,
            mobile: _buildMobileView(context),
            desktop: _buildDesktopView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopView(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // 6 колонок для десктопа
        childAspectRatio: 2 / 3.6, // Увеличенное соотношение сторон карточки (на 20% выше)
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: animes.length,
      itemBuilder: (context, index) {
        return AnimeCard(
          anime: animes[index],
          variant: CardVariant.compact,
          onTap: () {
            // TODO: Перейти на детали аниме
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Выбрано: ${animes[index].title}')),
            );
          },
        );
      },
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return SizedBox(
      height: 336, // Увеличенная высота для горизонтального списка (на 20%)
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const SmoothHorizontalScrollPhysics(),
        itemCount: animes.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(left: 16, right: index == animes.length - 1 ? 16 : 0),
            child: AnimeCard(
              anime: animes[index],
              variant: CardVariant.compact,
              onTap: () {
                // TODO: Перейти на детали аниме
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Выбрано: ${animes[index].title}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
