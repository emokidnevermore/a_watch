
/// Конфигурация кэширования для разных типов данных
class CacheConfig {
  /// Время жизни кэша для списка аниме
  final Duration animeListTtl;

  /// Время жизни кэша для детальной информации об аниме
  final Duration animeDetailTtl;

  /// Время жизни кэша для серий
  final Duration episodeTtl;

  /// Время жизни кэша для коллекций
  final Duration collectionsTtl;

  /// Время жизни кэша для HTML страниц
  final Duration htmlTtl;

  /// Путь к директории кэша
  final String? cacheDirectory;

  CacheConfig({
    Duration? animeListTtl,
    Duration? animeDetailTtl,
    Duration? episodeTtl,
    Duration? collectionsTtl,
    Duration? htmlTtl,
    this.cacheDirectory,
  })  : animeListTtl = animeListTtl ?? Duration(hours: 6),
        animeDetailTtl = animeDetailTtl ?? Duration(hours: 12),
        episodeTtl = episodeTtl ?? Duration(hours: 1),
        collectionsTtl = collectionsTtl ?? Duration(hours: 6),
        htmlTtl = htmlTtl ?? Duration(hours: 2);

  /// Конфигурация по умолчанию
  factory CacheConfig.defaultConfig() {
    return CacheConfig(
      animeListTtl: Duration(hours: 6),
      animeDetailTtl: Duration(hours: 12),
      episodeTtl: Duration(hours: 1),
      collectionsTtl: Duration(hours: 6),
      htmlTtl: Duration(hours: 2),
    );
  }

  /// Конфигурация для агрессивного кэширования (для медленных соединений)
  factory CacheConfig.aggressive() {
    return CacheConfig(
      animeListTtl: Duration(hours: 24),
      animeDetailTtl: Duration(hours: 48),
      episodeTtl: Duration(hours: 6),
      collectionsTtl: Duration(hours: 24),
      htmlTtl: Duration(hours: 8),
    );
  }

  /// Конфигурация для быстрого кэширования (для частого обновления контента)
  factory CacheConfig.fast() {
    return CacheConfig(
      animeListTtl: Duration(minutes: 30),
      animeDetailTtl: Duration(hours: 2),
      episodeTtl: Duration(minutes: 10),
      collectionsTtl: Duration(minutes: 30),
      htmlTtl: Duration(minutes: 15),
    );
  }

  /// Получить TTL для типа данных
  Duration getTtlForType(String type) {
    switch (type) {
      case 'anime_list':
        return animeListTtl;
      case 'anime_detail':
        return animeDetailTtl;
      case 'episode':
        return episodeTtl;
      case 'collections':
        return collectionsTtl;
      case 'html':
        return htmlTtl;
      default:
        return htmlTtl; // По умолчанию используем TTL для HTML
    }
  }

  /// Проверить, нужно ли кэшировать тип данных
  bool shouldCache(String type) {
    return getTtlForType(type).inSeconds > 0;
  }
}
