import 'dart:developer';

class ErrorLogger {
  static const String _tag = 'AnimeParser';

  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    log(
      message,
      name: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void logParsingError(String selector, String htmlSnippet, [dynamic error]) {
    log(
      'Parsing error for selector: $selector\nHTML snippet: $htmlSnippet',
      name: _tag,
      error: error,
    );
  }

  static void logNetworkError(String url, [dynamic error]) {
    log(
      'Network error for URL: $url',
      name: _tag,
      error: error,
    );
  }

  static void logCacheError(String key, [dynamic error]) {
    log(
      'Cache error for key: $key',
      name: _tag,
      error: error,
    );
  }
}
