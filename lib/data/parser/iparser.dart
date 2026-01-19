import 'package:a_watch/data/config/selectors_config.dart';

/// Интерфейс для парсера
/// T - тип результата парсинга
abstract class IParser<T> {
  /// Выполнить парсинг HTML
  Future<T> parse({
    required String htmlContent,
    required Map<String, String> selectors,
    required SelectorsConfig config,
  });

  /// Проверить, может ли парсер обработать данный HTML
  bool canParse(String html);

  /// Получить тип данных, которые парсит данный парсер
  String getDataType();
}

/// Результат парсинга
class ParseResult<T> {
  final T? data;
  final List<String> errors;
  final bool success;

  ParseResult.success(this.data)
      : errors = [],
        success = true;

  ParseResult.failure(this.errors)
      : data = null,
        success = false;

  ParseResult.withErrors(this.data, this.errors)
      : success = data != null;
}

/// Фабрика парсеров
class ParserFactory {
  final List<IParser> _parsers;

  ParserFactory(this._parsers);

  /// Получить парсер для типа данных
  IParser<T>? getParser<T>(String dataType) {
    return _parsers.firstWhere(
      (parser) => parser.getDataType() == dataType,
      orElse: () => throw Exception('No parser found for type: $dataType'),
    ) as IParser<T>?;
  }

  /// Найти подходящий парсер для HTML
  IParser<T>? findParser<T>(String html) {
    return _parsers.firstWhere(
      (parser) => parser.canParse(html),
      orElse: () => throw Exception('No suitable parser found for HTML'),
    ) as IParser<T>?;
  }

  /// Получить все парсеры
  List<IParser> getAllParsers() => _parsers;
}
