import 'dart:convert';
import 'package:http/http.dart' as http;

/// Интерфейс для HTTP сервиса
abstract class IHttpService {
  /// Выполнить GET запрос
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  });

  /// Выполнить POST запрос
  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    dynamic body,
    Encoding? encoding,
  });

  /// Закрыть соединение
  void close();
}
