import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_watch/domain/entities/collection.dart';
import 'package:a_watch/presentation/bloc/collections/collections_bloc.dart';
import 'package:a_watch/presentation/bloc/collections/collections_event.dart';
import 'package:a_watch/presentation/bloc/collections/collections_state.dart';
import 'collection_card.dart';
import 'package:a_watch/core/theme/scroll_behavior.dart';
import 'package:a_watch/core/theme/responsive_layout.dart';
import 'package:a_watch/presentation/components/index.dart';

class CollectionsSection extends StatelessWidget {
  const CollectionsSection({
    super.key,
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
          AppH2('Подборки'),

          SizedBox(height: ResponsiveLayout.getSpacing(context, SpacingType.xs)),

          // Содержимое раздела - unified responsive layout
          BlocBuilder<CollectionsBloc, CollectionsState>(
            builder: (context, state) {
              if (state is CollectionsInitial) {
                context.read<CollectionsBloc>().add(const CollectionsLoad(
                  url: 'https://yummyanime.tv/index-2',
                  useCache: false,
                ));
                return const Center(child: Text('Loading...'));
              } else if (state is CollectionsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CollectionsLoaded) {
                return ResponsiveLayout.buildResponsive(
                  context: context,
                  mobile: _buildMobileView(context, state.collections),
                  desktop: _buildDesktopView(context, state.collections),
                );
              } else if (state is CollectionsError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const Center(child: Text('Unknown state'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopView(BuildContext context, List<Collection> collections) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, // 6 колонок для десктопа
        childAspectRatio: 3 / 2, // Соотношение сторон для коллекций
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return CollectionCard(
          title: collection.title,
          imageUrl: collection.imageUrl,
          itemCount: collection.itemCount,
          onTap: () {
            // TODO: Перейти на страницу коллекции
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Выбрано: ${collection.title}')),
            );
          },
        );
      },
    );
  }

  Widget _buildMobileView(BuildContext context, List<Collection> collections) {
    return SizedBox(
      height: 200, // Фиксированная высота для горизонтального списка
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const SmoothHorizontalScrollPhysics(),
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final collection = collections[index];
          return Container(
            margin: EdgeInsets.only(left: 16, right: index == collections.length - 1 ? 16 : 0),
            child: CollectionCard(
              title: collection.title,
              imageUrl: collection.imageUrl,
              itemCount: collection.itemCount,
              onTap: () {
                // TODO: Перейти на страницу коллекции
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Выбрано: ${collection.title}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
