import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:a_watch/presentation/widgets/anime_detail/anime_detail_widget.dart';
import 'package:a_watch/features/player/presentation/widgets/video_player_widget.dart';

import 'package:a_watch/core/navigation/routes.dart';
import 'package:a_watch/presentation/widgets/layout/app_shell.dart';

/// Application router configuration with AppShell wrapper
final GoRouter appRouter = GoRouter(
  routes: [
    // Main app shell with IndexedStack
    GoRoute(
      path: '/',
      builder: (context, state) => const AppShell(),
    ),

    // Special routes that need separate pages
    GoRoute(
      path: '${AppRoutes.animeDetail}/:url',
      builder: (context, state) {
        final url = Uri.decodeComponent(state.pathParameters['url']!);
        // Find AppShell in the widget tree and show anime in recent tab
        final appShellState = AppShell.of(context);
        if (appShellState != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appShellState.showAnimeInRecentTab(url);
          });
          // Return empty container since we're switching to existing tab
          return const SizedBox.shrink();
        }
        // Fallback if AppShell not found
        return Scaffold(
          appBar: AppBar(
            title: const Text('A-Watch'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
          ),
          body: AnimeDetailWidget(animeUrl: url),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.player,
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('A-Watch'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: VideoPlayerWidget(
          qualities: const {'720': 'placeholder'},
          onQualityChanged: (quality) {},
          translationId: '0',
        ),
      ),
    ),
  ],
);
