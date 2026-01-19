import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:a_watch/core/error/error_logger.dart';

class HttpService {
  static const Duration _defaultTimeout = Duration(seconds: 10);
  static const Duration _defaultRateLimit = Duration(milliseconds: 500);
  static const String _defaultUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0';

  final http.Client _client;
  final String _baseUrl;
  final Map<String, String> _defaultHeaders;
  final CookieJar _cookieJar;
  final RateLimiter _rateLimiter;

  HttpService({
    required String baseUrl,
    Map<String, String>? defaultHeaders,
    CookieJar? cookieJar,
    Duration? rateLimit,
  }) : _client = http.Client(),
       _baseUrl = baseUrl,
       _defaultHeaders = defaultHeaders ?? {},
       _cookieJar = cookieJar ?? CookieJar(),
       _rateLimiter = RateLimiter(rateLimit ?? _defaultRateLimit);

  CookieJar get cookieJar => _cookieJar;

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    await _rateLimiter.acquire();

    final uri = _buildUri(path, queryParameters);
    final requestHeaders = _buildHeaders(headers);

    // Debug log
    ErrorLogger.logError('HTTP GET: $uri');
    ErrorLogger.logError('Headers: ${requestHeaders.toString()}');

    try {
      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(_defaultTimeout);

      // Debug log
      ErrorLogger.logError('Response status: ${response.statusCode}');
      ErrorLogger.logError('Response headers: ${response.headers.toString()}');

      if (response.statusCode >= 400) {
        ErrorLogger.logError(
          'Response body (first 500 chars): ${response.body.substring(0, min(500, response.body.length))}',
        );
      }

      _cookieJar.saveFromResponse(uri, response.headers);
      return response;
    } catch (e) {
      ErrorLogger.logError('HTTP GET error: $e');
      rethrow;
    }
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
  }) async {
    await _rateLimiter.acquire();

    final uri = path.startsWith('http')
        ? Uri.parse(path)
        : Uri.parse('$_baseUrl$path');
    final requestHeaders = _buildHeaders(headers);

    try {
      final response = await _client
          .post(uri, headers: requestHeaders, body: body, encoding: encoding)
          .timeout(_defaultTimeout);

      _cookieJar.saveFromResponse(uri, response.headers);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    Uri uri = path.startsWith('http')
        ? Uri.parse(path)
        : Uri.parse('$_baseUrl$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final queryParams = queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Map<String, String> _buildHeaders(Map<String, String>? headers) {
    final Map<String, String> result = {
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'User-Agent': _defaultUserAgent,
      ..._defaultHeaders,
    };

    if (headers != null) {
      result.addAll(headers);
    }

    final cookies = _cookieJar.getCookiesAsString();
    if (cookies.isNotEmpty) {
      result['Cookie'] = cookies;
    }

    return result;
  }

  void close() {
    _client.close();
  }
}

class CookieJar {
  final Map<String, String> _cookies = {};

  void saveFromResponse(Uri uri, Map<String, String> headers) {
    final cookieHeader = headers['set-cookie'];
    if (cookieHeader != null) {
      // Split multiple cookies if they are comma-separated (comma followed by a potential key=value)
      final cookies = cookieHeader.split(RegExp(r',(?=[^;]*=)'));
      for (final cookie in cookies) {
        final parts = cookie.split(';').map((c) => c.trim());
        if (parts.isEmpty) continue;

        final firstPart = parts.first;
        final kv = firstPart.split('=');
        if (kv.length >= 2) {
          final key = kv[0].trim();
          final value = kv.sublist(1).join('=').trim();
          final lowerKey = key.toLowerCase();

          // Skip attributes
          if (lowerKey == 'path' ||
              lowerKey == 'domain' ||
              lowerKey == 'expires' ||
              lowerKey == 'max-age' ||
              lowerKey == 'samesite' ||
              lowerKey == 'httponly' ||
              lowerKey == 'secure') {
            continue;
          }

          _cookies[key] = value;
        }
      }
    }
  }

  String getCookiesAsString() {
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  Map<String, String> getCookies() => Map.from(_cookies);

  void clear() {
    _cookies.clear();
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
