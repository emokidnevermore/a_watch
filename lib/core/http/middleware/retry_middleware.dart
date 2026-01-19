import 'dart:async';
import 'dart:io';
import 'package:a_watch/core/logger/logger.dart';
import 'package:a_watch/core/http/middleware/http_middleware.dart';
import 'package:http/http.dart' as http;

/// Middleware для retry-логики HTTP запросов
class RetryMiddleware extends HttpMiddleware {
  final ILogger _logger;
  final int _maxRetries;
  final Duration _retryDelay;
  final List<int> _retryableStatusCodes;

  RetryMiddleware({
    required ILogger logger,
    int maxRetries = 3,
    Duration? retryDelay,
    List<int>? retryableStatusCodes,
  })  : _logger = logger,
        _maxRetries = maxRetries,
        _retryDelay = retryDelay ?? Duration(milliseconds: 500),
        _retryableStatusCodes = retryableStatusCodes ??
            const [408, 429, 500, 502, 503, 504];

  @override
  Future<http.Response> intercept(
    HttpRequestContext context,
    MiddlewareHandler next,
  ) async {
    int attempt = 0;

    while (true) {
      attempt++;
      try {
        final response = await next(context);

        // Проверяем, нужно ли повторять запрос на основе статуса
        if (_shouldRetry(response.statusCode) && attempt <= _maxRetries) {
          _logger.logWarning(
            'HTTP ${context.method} ${context.uri} returned ${response.statusCode}, retrying ($attempt/$_maxRetries)...',
          );
          await Future.delayed(_retryDelay * attempt); // Exponential backoff
          continue;
        }

        return response;
      } catch (e) {
        // Проверяем, можно ли повторять запрос при ошибке
        if (_isRetryableError(e) && attempt <= _maxRetries) {
          _logger.logWarning(
            'HTTP ${context.method} ${context.uri} failed with error: $e, retrying ($attempt/$_maxRetries)...',
          );
          await Future.delayed(_retryDelay * attempt); // Exponential backoff
          continue;
        }
        rethrow;
      }
    }
  }

  bool _shouldRetry(int statusCode) {
    return _retryableStatusCodes.contains(statusCode);
  }

  bool _isRetryableError(Object error) {
    // Повторяем запрос при сетевых ошибках
    if (error is TimeoutException) return true;
    if (error is SocketException) return true;
    if (error is HandshakeException) return true;
    if (error is HttpException) return true;
    
    return false;
  }
}
