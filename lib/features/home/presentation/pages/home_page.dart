import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:a_watch/presentation/bloc/anime_list/anime_list_bloc.dart';
import 'package:a_watch/presentation/bloc/anime_list/anime_list_event.dart';
import 'package:a_watch/core/theme/design_tokens.dart';
import 'package:a_watch/core/theme/scroll_behavior.dart';
import 'package:a_watch/presentation/components/index.dart';
import 'package:a_watch/features/series/presentation/widgets/series_section.dart';
import 'package:a_watch/features/movies/presentation/widgets/movies_section.dart';
import 'package:a_watch/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:a_watch/presentation/widgets/collections_section.dart';
import 'package:a_watch/core/di/service_locator.dart';
import '../widgets/index.dart';

class HomePage extends StatefulWidget {
  final Function(String animeUrl)? onAnimeSelected;
  final ViewMode initialViewMode; // Начальное состояние секции
  final Function(ViewMode)? onViewModeChanged; // Callback для изменения состояния

  const HomePage({
    super.key,
    this.onAnimeSelected,
    this.initialViewMode = ViewMode.all, // По умолчанию все секции
    this.onViewModeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ViewMode _currentViewMode;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentViewMode = widget.initialViewMode;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= DesignTokens.desktopMinWidth;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AnimeListBloc>().add(const AnimeListLoad(
          url: 'https://yummyanime.tv/index-2',
          forceRefresh: true,
        ));
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = isDesktop
              ? constraints.maxWidth * 0.08  // 8% for desktop
              : constraints.maxWidth * 0.04; // 4% for mobile
          return ListView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            physics: isDesktop
                ? const SmoothDesktopScrollPhysics()
                : const AlwaysScrollableScrollPhysics(),
            children: _buildContent(isDesktop),
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(bool isDesktop) {
    final children = <Widget>[];

    // Кнопка "Назад" если не в режиме all
    if (_currentViewMode != ViewMode.all) {
      children.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _currentViewMode = ViewMode.all);
                  widget.onViewModeChanged?.call(ViewMode.all);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              AppH2(_getTitleForMode(_currentViewMode)),
            ],
          ),
        ),
      );
    }

    // Секции в зависимости от режима
    switch (_currentViewMode) {
      case ViewMode.all:
        children.addAll([
          // Секция сериалов
          AnimeListSection(
            title: 'Сериалы',
            type: 'serial',
            isDesktop: isDesktop,
            tapMode: ViewMode.serials,
            onViewModeChanged: (mode) {
              if (mode != null) {
                setState(() => _currentViewMode = mode);
                widget.onViewModeChanged?.call(mode);
              }
            },
            onAnimeSelected: widget.onAnimeSelected,
          ),
          const SizedBox(height: 24),
          // Секция фильмов
          AnimeListSection(
            title: 'Фильмы',
            type: 'movie',
            isDesktop: isDesktop,
            tapMode: ViewMode.movies,
            onViewModeChanged: (mode) {
              if (mode != null) {
                setState(() => _currentViewMode = mode);
                widget.onViewModeChanged?.call(mode);
              }
            },
            onAnimeSelected: widget.onAnimeSelected,
          ),
          const SizedBox(height: 24),
          // Секция подборок
          const CollectionsSection(),
        ]);
        break;
      case ViewMode.serials:
        children.add(
          SeriesSection(
            isDesktop: isDesktop,
            onAnimeSelected: widget.onAnimeSelected,
          ),
        );
        break;
      case ViewMode.movies:
        children.add(
          BlocProvider<MoviesBloc>(
            create: (context) => getIt<MoviesBloc>(),
            child: MoviesSection(
              isDesktop: isDesktop,
              onAnimeSelected: widget.onAnimeSelected,
            ),
          ),
        );
        break;
      case ViewMode.collections:
        children.add(
          const CollectionsSection(),
        );
        break;
      default:
        // Unknown mode - fall back to all
        setState(() => _currentViewMode = ViewMode.all);
        children.addAll([
          AnimeListSection(
            title: 'Сериалы',
            type: 'serial',
            isDesktop: isDesktop,
            tapMode: ViewMode.serials,
            onViewModeChanged: (mode) {
              if (mode != null) {
                setState(() => _currentViewMode = mode);
                widget.onViewModeChanged?.call(mode);
              }
            },
            onAnimeSelected: widget.onAnimeSelected,
          ),
          const SizedBox(height: 24),
          AnimeListSection(
            title: 'Фильмы',
            type: 'movie',
            isDesktop: isDesktop,
            tapMode: ViewMode.movies,
            onViewModeChanged: (mode) {
              if (mode != null) {
                setState(() => _currentViewMode = mode);
                widget.onViewModeChanged?.call(mode);
              }
            },
            onAnimeSelected: widget.onAnimeSelected,
          ),
          const SizedBox(height: 24),
          const CollectionsSection(),
        ]);
        break;
    }

    return children;
  }

  String _getTitleForMode(ViewMode mode) {
    switch (mode) {
      case ViewMode.serials:
        return 'Сериалы';
      case ViewMode.movies:
        return 'Фильмы';
      case ViewMode.collections:
        return 'Подборки';
      default:
        return 'Главная';
    }
  }

}
