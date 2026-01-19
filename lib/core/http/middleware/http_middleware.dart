import 'package:http/http.dart' as http;
import 'dart:convert';

/// Базовый класс для HTTP middleware
abstract class HttpMiddleware {
  /// Обработка запроса
  Future<http.Response> intercept(
    HttpRequestContext context,
    MiddlewareHandler next,
  );
}

/// Контекст HTTP запроса
class HttpRequestContext {
  final String method;
  final Uri uri;
  final Map<String, String>? headers;
  final dynamic body;
  final Encoding? encoding;

  HttpRequestContext({
    required this.method,
    required this.uri,
    this.headers,
    this.body,
    this.encoding,
  });
}

/// Тип для функции следующего middleware
typedef MiddlewareHandler = Future<http.Response> Function(HttpRequestContext context);

/// Цепочка middleware
class MiddlewareChain {
  final List<HttpMiddleware> _middlewares;

  MiddlewareChain(this._middlewares);

  Future<http.Response> execute(HttpRequestContext context) {
    MiddlewareHandler handler = (HttpRequestContext ctx) async {
      // Базовый обработчик - выполняет реальный HTTP запрос
      throw Exception('Base handler should be overridden');
    };

    // Строим цепочку middleware в обратном порядке
    for (int i = _middlewares.length - 1; i >= 0; i--) {
      final currentMiddleware = _middlewares[i];
      final nextHandler = handler;
      handler = (HttpRequestContext ctx) => currentMiddleware.intercept(ctx, nextHandler);
    }

    return handler(context);
  }

  /// Выполняет запрос с кастомным базовым обработчиком
  Future<http.Response> executeWithHandler(
    HttpRequestContext context,
    MiddlewareHandler baseHandler,
  ) {
    MiddlewareHandler handler = baseHandler;

    // Строим цепочку middleware в обратном порядке
    for (int i = _middlewares.length - 1; i >= 0; i--) {
      final currentMiddleware = _middlewares[i];
      final nextHandler = handler;
      handler = (HttpRequestContext ctx) => currentMiddleware.intercept(ctx, nextHandler);
    }

    return handler(context);
  }
}
