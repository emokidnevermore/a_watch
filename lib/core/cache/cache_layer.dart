import 'dart:io';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class CacheLayer {
  static const String _htmlBoxName = 'html_cache';
  static const String _modelBoxName = 'model_cache';

  late Box<String> _htmlBox;
  late Box<String> _modelBox;

  CacheLayer._privateConstructor();

  static final CacheLayer _instance = CacheLayer._privateConstructor();

  static CacheLayer get instance => _instance;

  Future<void> init() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);

    _htmlBox = await Hive.openBox<String>(_htmlBoxName);
    _modelBox = await Hive.openBox<String>(_modelBoxName);
  }

  Future<void> setHtml(String key, String html, Duration ttl) async {
    final expirationTime = DateTime.now().add(ttl).millisecondsSinceEpoch;
    final data = '$expirationTime|$html';
    await _htmlBox.put(key, data);
  }

  Future<void> setModel<T>(String key, T model, Duration ttl) async {
    final expirationTime = DateTime.now().add(ttl).millisecondsSinceEpoch;
    final json = model is String ? model : jsonEncode(model);
    final data = '$expirationTime|$json';
    await _modelBox.put(key, data);
  }

  Future<String?> getHtml(String key) async {
    final data = _htmlBox.get(key);
    if (data == null) return null;

    final parts = data.split('|');
    if (parts.length < 2) return null;

    final expirationTime = int.parse(parts[0]);
    if (DateTime.now().millisecondsSinceEpoch > expirationTime) {
      await _htmlBox.delete(key);
      return null;
    }

    return parts.sublist(1).join('|');
  }

  Future<T?> getModel<T>(String key, T Function(String) fromJson) async {
    final data = _modelBox.get(key);
    if (data == null) return null;

    final parts = data.split('|');
    if (parts.length < 2) return null;

    final expirationTime = int.parse(parts[0]);
    if (DateTime.now().millisecondsSinceEpoch > expirationTime) {
      await _modelBox.delete(key);
      return null;
    }

    final json = parts.sublist(1).join('|');
    return fromJson(json);
  }

  Future<void> clear() async {
    await _htmlBox.clear();
    await _modelBox.clear();
  }

  Future<void> clearExpired() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Clear expired HTML cache
    final htmlKeys = _htmlBox.keys.toList();
    for (final key in htmlKeys) {
      final data = _htmlBox.get(key);
      if (data != null) {
        final parts = data.split('|');
        if (parts.length >= 2) {
          final expirationTime = int.parse(parts[0]);
          if (now > expirationTime) {
            await _htmlBox.delete(key);
          }
        }
      }
    }

    // Clear expired model cache
    final modelKeys = _modelBox.keys.toList();
    for (final key in modelKeys) {
      final data = _modelBox.get(key);
      if (data != null) {
        final parts = data.split('|');
        if (parts.length >= 2) {
          final expirationTime = int.parse(parts[0]);
          if (now > expirationTime) {
            await _modelBox.delete(key);
          }
        }
      }
    }
  }

  Future<void> close() async {
    await _htmlBox.close();
    await _modelBox.close();
  }
}
