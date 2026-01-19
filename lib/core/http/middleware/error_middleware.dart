import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/core/http/middleware/http_middleware.dart';
import 'package:http/http.dart' as http;

/// Middleware для централизованной обработки ошибок
class ErrorMiddleware extends HttpMiddleware {
  final ILogger _logger;

  ErrorMiddleware(this._logger);

  @override
  Future<http.Response> intercept(
    HttpRequestContext context,
    MiddlewareHandler next,
  ) async {
    try {
      final response = await next(context);
      
      // Логируем HTTP ошибки
      if (response.statusCode >= 400) {
        _logger.logError(
          'HTTP ${context.method} ${context.uri} failed with status ${response.statusCode}',
          null,
          Exception('HTTP Error: ${response.statusCode}'),
        );
      }
      
      return response;
    } catch (e, stackTrace) {
      // Логируем все типы ошибок
      _logger.logError(
        'HTTP ${context.method} ${context.uri} failed',
        null,
        e,
        stackTrace,
      );
      rethrow;
    }
  }
}
