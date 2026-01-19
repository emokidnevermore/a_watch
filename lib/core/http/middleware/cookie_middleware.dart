import 'package:a_watch/core/http/middleware/http_middleware.dart';
import 'package:a_watch/core/http/http_service_factory.dart';
import 'package:http/http.dart' as http;

/// Middleware для управления куками
class CookieMiddleware extends HttpMiddleware {
  final CookieJar _cookieJar;

  CookieMiddleware(this._cookieJar);

  @override
  Future<http.Response> intercept(
    HttpRequestContext context,
    MiddlewareHandler next,
  ) async {
    // Создаем новый контекст с добавленными куками для этого домена
    HttpRequestContext updatedContext = context;

    final cookies = _cookieJar.getCookiesAsString(context.uri.host);
    if (cookies.isNotEmpty) {
      final updatedHeaders = Map<String, String>.from(context.headers ?? {});
      updatedHeaders['Cookie'] = cookies;
      updatedContext = HttpRequestContext(
        method: context.method,
        uri: context.uri,
        headers: updatedHeaders,
        body: context.body,
        encoding: context.encoding,
      );
    }

    // Выполняем запрос
    final response = await next(updatedContext);

    // Сохраняем куки из ответа
    if (response.headers.containsKey('set-cookie')) {
      _cookieJar.saveFromResponse(context.uri, response.headers);
    }

    return response;
  }
}
