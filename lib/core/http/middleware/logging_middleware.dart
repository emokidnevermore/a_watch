import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/core/http/middleware/http_middleware.dart';
import 'package:http/http.dart' as http;

/// Middleware для логирования HTTP запросов
class LoggingMiddleware extends HttpMiddleware {
  final ILogger _logger;

  LoggingMiddleware(this._logger);

  @override
  Future<http.Response> intercept(
    HttpRequestContext context,
    MiddlewareHandler next,
  ) async {
    final startTime = DateTime.now();
    _logger.logInfo('HTTP ${context.method}: ${context.uri}');

    try {
      final response = await next(context);
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      _logger.logInfo(
        'HTTP ${context.method} ${context.uri} -> ${response.statusCode} (${duration}ms)',
      );

      if (response.statusCode >= 400) {
        _logger.logWarning(
          'HTTP ${context.method} ${context.uri} failed with status ${response.statusCode}',
        );
      }

      return response;
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _logger.logError(
        'HTTP ${context.method} ${context.uri} failed after ${duration}ms: $e',
      );
      rethrow;
    }
  }
}
