import 'dart:developer';

abstract class ILogger {
  void logInfo(String message, [String? tag]);
  void logWarning(String message, [String? tag]);
  void logError(String message, [String? tag, dynamic error, StackTrace? stackTrace]);
  void logDebug(String message, [String? tag]);
}

class Logger implements ILogger {
  static const String _defaultTag = 'AnimeParser';

  @override
  void logInfo(String message, [String? tag]) {
    log(message, name: tag ?? _defaultTag);
  }

  @override
  void logWarning(String message, [String? tag]) {
    log('WARNING: $message', name: tag ?? _defaultTag);
  }

  @override
  void logError(String message, [String? tag, dynamic error, StackTrace? stackTrace]) {
    log(
      message,
      name: tag ?? _defaultTag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void logDebug(String message, [String? tag]) {
    log('DEBUG: $message', name: tag ?? _defaultTag);
  }
}
