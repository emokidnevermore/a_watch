import 'package:a_watch/core/http/ihttp_service.dart';
import 'package:a_watch/core/http/middleware/http_middleware.dart';
import 'package:a_watch/core/http/middleware/logging_middleware.dart';
import 'package:a_watch/core/http/middleware/retry_middleware.dart';
import 'package:a_watch/core/http/middleware/error_middleware.dart';
import 'package:a_watch/core/http/middleware/cookie_middleware.dart';
import 'package:a_watch/core/logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Фабрика для создания HTTP сервиса с middleware
class HttpServiceFactory {
  final ILogger _logger;

  HttpServiceFactory(this._logger);

  /// Создает HTTP сервис с middleware цепочкой
  IHttpService createHttpService({
    required String baseUrl,
    Map<String, String>? defaultHeaders,
    Duration? rateLimit,
    bool enableLogging = true,
    bool enableRetry = true,
    int maxRetries = 3,
    Duration? retryDelay,
    List<int>? retryableStatusCodes,
  }) {
    final httpClient = http.Client();
    final middlewares = <HttpMiddleware>[];

    middlewares.add(ErrorMiddleware(_logger));

    final cookieJar = CookieJar();
    middlewares.add(CookieMiddleware(cookieJar));

    if (enableLogging) {
      middlewares.add(LoggingMiddleware(_logger));
    }

    if (enableRetry) {
      middlewares.add(
        RetryMiddleware(
          logger: _logger,
          maxRetries: maxRetries,
          retryDelay: retryDelay,
          retryableStatusCodes: retryableStatusCodes,
        ),
      );
    }

    final middlewareChain = MiddlewareChain(middlewares);

    return HttpServiceWithMiddleware(
      client: httpClient,
      baseUrl: baseUrl,
      defaultHeaders: defaultHeaders,
      rateLimit: rateLimit,
      middlewareChain: middlewareChain,
      cookieJar: cookieJar,
      logger: _logger,
    );
  }
}

/// HTTP сервис с поддержкой middleware
class HttpServiceWithMiddleware implements IHttpService {
  final http.Client _client;
  final String _baseUrl;
  final Map<String, String> _defaultHeaders;
  final MiddlewareChain _middlewareChain;
  final RateLimiter _rateLimiter;
  final CookieJar _cookieJar;
  final ILogger _logger;

  HttpServiceWithMiddleware({
    required http.Client client,
    required String baseUrl,
    Map<String, String>? defaultHeaders,
    Duration? rateLimit,
    required MiddlewareChain middlewareChain,
    required CookieJar cookieJar,
    required ILogger logger,
  }) : _client = client,
       _baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl,
       _defaultHeaders = defaultHeaders ?? {},
       _middlewareChain = middlewareChain,
       _rateLimiter = RateLimiter(
         rateLimit ?? const Duration(milliseconds: 500),
       ),
       _cookieJar = cookieJar,
       _logger = logger;

  @override
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    await _rateLimiter.acquire();

    final uri = _buildUri(path, queryParameters);
    final requestHeaders = _buildHeaders(headers, domain: uri.host);

    final context = HttpRequestContext(
      method: 'GET',
      uri: uri,
      headers: requestHeaders,
    );

    Future<http.Response> baseHandler(HttpRequestContext ctx) async {
      return _client.get(ctx.uri, headers: ctx.headers);
    }

    return _middlewareChain.executeWithHandler(context, baseHandler);
  }

  @override
  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
  }) async {
    await _rateLimiter.acquire();

    final uri = _buildUri(path, null);
    final requestHeaders = _buildHeaders(headers, domain: uri.host);

    _logger.logInfo('HTTP POST: $uri');
    _logger.logInfo('POST Headers: $requestHeaders');
    if (body != null) {
      _logger.logInfo('POST Body: $body');
    }

    final context = HttpRequestContext(
      method: 'POST',
      uri: uri,
      headers: requestHeaders,
      body: body,
      encoding: encoding,
    );

    Future<http.Response> baseHandler(HttpRequestContext ctx) async {
      // Check if this is a multipart request
      final contentType = ctx.headers?['Content-Type'] ?? '';
      if (contentType.contains('multipart/form-data') && ctx.body is Map<String, dynamic>) {
        final request = http.MultipartRequest('POST', ctx.uri);
        if (ctx.headers != null) {
          request.headers.addAll(ctx.headers!);
        }
        // Remove content-type from headers as MultipartRequest sets it automatically
        request.headers.remove('content-type');

        // Add fields from the body Map
        final bodyMap = ctx.body as Map<String, dynamic>;
        bodyMap.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        final streamedResponse = await _client.send(request);
        return http.Response.fromStream(streamedResponse);
      } else {
        return _client.post(
          ctx.uri,
          headers: ctx.headers,
          body: ctx.body,
          encoding: ctx.encoding,
        );
      }
    }

    return _middlewareChain.executeWithHandler(context, baseHandler);
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final isFullUrl = path.startsWith('http://') || path.startsWith('https://');
    final baseUri = isFullUrl ? Uri.parse(path) : Uri.parse('$_baseUrl$path');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryParams = queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      return baseUri.replace(queryParameters: queryParams);
    }

    return baseUri;
  }

  Map<String, String> _buildHeaders(
    Map<String, String>? headers, {
    String? domain,
  }) {
    final Map<String, String> result = {
      'Accept': '*/*',
      'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
      'Accept-Encoding': 'gzip, deflate, br, zstd',
      'DNT': '1',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',
      'sec-ch-ua': '"Chromium";v="142", "Google Chrome";v="142", "Not_A Brand";v="99"',
      'sec-ch-ua-mobile': '?0',
      'sec-ch-ua-platform': '"Windows"',
      ..._defaultHeaders,
    };

    if (headers != null) {
      result.addAll(headers);
    }

    final cookies = _cookieJar.getCookiesAsString(domain);
    if (cookies.isNotEmpty) {
      result['Cookie'] = cookies;
    }

    return result;
  }

  @override
  void close() {
    _client.close();
  }
}

class CookieJar {
  final Map<String, Map<String, String>> _domainCookies = {};

  void saveFromResponse(Uri uri, Map<String, String> headers) {
    final setCookieHeaders = headers['set-cookie'];
    if (setCookieHeaders != null) {
      final cookieStrings = setCookieHeaders.split(RegExp(r',(?=[^;]*=)'));
      for (final cookieString in cookieStrings) {
        final cookie = _parseCookie(cookieString.trim());
        if (cookie != null) {
          final domain = uri.host;
          _domainCookies[domain] ??= {};
          _domainCookies[domain]![cookie['name']!] = cookie['value']!;
        }
      }
    }
  }

  Map<String, String>? _parseCookie(String cookieString) {
    final parts = cookieString.split(';').map((p) => p.trim());
    if (parts.isEmpty) return null;

    final firstPart = parts.first;
    final nameValue = firstPart.split('=');
    if (nameValue.length < 2) return null;

    final key = nameValue[0].trim();
    final lowerKey = key.toLowerCase();

    if (lowerKey == 'path' ||
        lowerKey == 'domain' ||
        lowerKey == 'expires' ||
        lowerKey == 'max-age' ||
        lowerKey == 'samesite' ||
        lowerKey == 'httponly' ||
        lowerKey == 'secure') {
      return null;
    }

    return {'name': key, 'value': nameValue.sublist(1).join('=').trim()};
  }

  String getCookiesAsString([String? domain]) {
    final result = getCookies(domain);
    return result.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  Map<String, String> getCookies([String? domain]) {
    final result = <String, String>{};
    if (domain == null) {
      _domainCookies.forEach((_, cookies) => result.addAll(cookies));
    } else {
      // Ищем куки для этого домена и его над-доменов (e.g. for api.kodik.cc match .kodik.cc and kodik.cc)
      _domainCookies.forEach((domainKey, cookies) {
        if (domain == domainKey || domain.endsWith('.$domainKey')) {
          result.addAll(cookies);
        }
      });
    }
    return result;
  }

  void clear([String? domain]) {
    if (domain != null) {
      _domainCookies.remove(domain);
    } else {
      _domainCookies.clear();
    }
  }
}

class RateLimiter {
  final Duration _interval;
  DateTime? _lastRequestTime;

  RateLimiter(this._interval);

  Future<void> acquire() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _interval) {
        final waitTime = _interval - timeSinceLastRequest;
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }
}
