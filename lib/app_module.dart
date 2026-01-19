/// App Module
/// 
/// Главный модуль приложения, который объединяет все feature-модули
/// и предоставляет доступ к общим зависимостям.
library;

import 'package:a_watch/core/di/service_locator.dart';

/// Основной модуль приложения
///
/// Структура:
/// lib/
/// ├── app_module.dart     # Главный модуль
/// ├── core/              # Core слой (DI, HTTP, Cache, Logger)
/// ├── features/          # Feature-модули
/// │   ├── anime/         # Модуль аниме
/// │   └── player/        # Модуль плеера
/// └── main.dart          # Точка входа

/// Инициализация всех модулей приложения
/// 
/// Вызывается из main.dart для настройки DI и всех зависимостей
Future<void> initApp() async {
  // Инициализация DI
  await init();
  
  // Можно добавить инициализацию других модулей здесь
  // await CollectionsModule.init();
  // await PlayerModule.init();
}
