import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_watch/presentation/bloc/collections/collections_bloc.dart';
import 'package:a_watch/presentation/bloc/collections/collections_state.dart';
import 'package:a_watch/presentation/bloc/collections/collections_event.dart';
import 'package:a_watch/features/anime/presentation/widgets/cards/index.dart';
import 'package:a_watch/presentation/components/index.dart';
import 'clickable_section_header.dart';
import 'view_mode.dart';

class CollectionsListSection extends StatelessWidget {
  final bool isDesktop;
  final bool loadAll;
  final ViewMode? tapMode;
  final Function(ViewMode?)? onViewModeChanged;
  final Function(String animeUrl)? onAnimeSelected;

  const CollectionsListSection({
    super.key,
    required this.isDesktop,
    this.loadAll = false,
    this.tapMode,
    this.onViewModeChanged,
    this.onAnimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionsBloc, CollectionsState>(
      builder: (context, state) {
        if (state is CollectionsInitial) {
          context.read<CollectionsBloc>().add(const CollectionsLoad(
            url: 'https://yummyanime.tv/index-2',
            useCache: false,
          ));
          return _buildLoadingSection();
        } else if (state is CollectionsLoading) {
          return _buildLoadingSection();
        } else if (state is CollectionsLoaded) {
          return _buildSection(
            title: 'Подборки',
            isDesktop: isDesktop,
            onTitleTap: tapMode != null ? () {
              onViewModeChanged?.call(tapMode);
            } : null,
            child: isDesktop
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: loadAll ? 6 : 4,
                      childAspectRatio: 1.6,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: state.collections.length,
                    itemBuilder: (context, index) {
                      final collection = state.collections[index];
                      return EnhancedCollectionCard(
                        title: collection.title,
                        imageUrl: collection.imageUrl,
                        itemCount: collection.itemCount,
                        heroTag: 'collection_$index',
                        onTap: () {
                          // TODO: Navigate to collection detail page
                        },
                      );
                    },
                  )
                : SizedBox(
                    height: loadAll ? 240 : 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.collections.length,
                      itemBuilder: (context, index) {
                        final collection = state.collections[index];
                        return Container(
                          margin: EdgeInsets.only(
                            left: 16,
                            right: index == state.collections.length - 1 ? 16 : 8,
                          ),
                          child: EnhancedCollectionCard(
                            title: collection.title,
                            imageUrl: collection.imageUrl,
                            itemCount: collection.itemCount,
                            heroTag: 'collection_$index',
                            onTap: () {
                              // TODO: Navigate to collection detail page
                            },
                          ),
                        );
                      },
                    ),
                  ),
          );
        } else if (state is CollectionsError) {
          return _buildErrorSection(state.message);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDesktop,
    required Widget child,
    VoidCallback? onTitleTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          onTitleTap != null
              ? ClickableSectionHeader(
                  title: title,
                  onTap: onTitleTap,
                  isDesktop: isDesktop,
                )
              : AppH2(title),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppH2('Подборки'),
          const SizedBox(height: 8),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildErrorSection(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppH2('Подборки'),
          const SizedBox(height: 8),
          Center(child: AppBodyMedium('Error: $message')),
        ],
      ),
    );
  }
}
