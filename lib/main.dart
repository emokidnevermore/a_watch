import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:a_watch/core/di/service_locator.dart';
import 'package:a_watch/core/theme/theme_manager.dart';
import 'package:a_watch/core/theme/scroll_behavior.dart';
import 'package:a_watch/presentation/bloc/anime_list/anime_list_bloc.dart';
import 'package:a_watch/presentation/bloc/collections/collections_bloc.dart';
import 'package:a_watch/features/series/presentation/bloc/series_bloc.dart';
import 'package:a_watch/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:a_watch/core/navigation/app_router.dart';

import 'package:media_kit/media_kit.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // Инициализация DI
  await init();

  // Инициализация кастомного окна для десктопа
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    // Инициализируем window_manager
    await windowManager.ensureInitialized();

    // Устанавливаем окно в состояние готовности
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeManager())],
      child: MultiBlocProvider(
      providers: [
          BlocProvider<AnimeListBloc>(
            create: (context) => getIt<AnimeListBloc>(),
          ),
          BlocProvider<CollectionsBloc>(
            create: (context) => getIt<CollectionsBloc>(),
          ),
          BlocProvider<SeriesBloc>(
            create: (context) => getIt<SeriesBloc>(),
          ),
          BlocProvider<MoviesBloc>(
            create: (context) => getIt<MoviesBloc>(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return ScrollConfiguration(
          behavior: const SmoothScrollBehavior(),
          child: MaterialApp.router(
            title: 'A-Watch',
            theme: themeManager.lightTheme,
            darkTheme: themeManager.darkTheme,
            themeMode: themeManager.themeMode,
            routerDelegate: appRouter.routerDelegate,
            routeInformationParser: appRouter.routeInformationParser,
            routeInformationProvider: appRouter.routeInformationProvider,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
