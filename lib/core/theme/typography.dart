import 'package:flutter/material.dart';
import 'package:a_watch/core/theme/colors.dart';

/// Типографская система приложения
/// Предоставляет согласованные размеры шрифтов и стили для всех компонентов
class AppTypography {
  /// Размеры шрифтов по умолчанию
  static const double sizeXSmall = 10.0;
  static const double sizeSmall = 12.0;
  static const double sizeMedium = 14.0;
  static const double sizeLarge = 16.0;
  static const double sizeXLarge = 18.0;
  static const double sizeXXLarge = 20.0;
  static const double sizeXXXLarge = 24.0;
  static const double sizeXXXXLarge = 32.0;

  /// Создание текстового стиля для заголовков
  static TextStyle heading({
    required double fontSize,
    FontWeight fontWeight = FontWeight.bold,
    required Brightness brightness,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.getTextColor(brightness, type: TextType.primary),
      height: 1.2,
      letterSpacing: 0.2,
    );
  }

  /// Создание текстового стиля для основного текста
  static TextStyle body({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    required Brightness brightness,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.getTextColor(brightness, type: TextType.primary),
      height: height ?? 1.5,
    );
  }

  /// Создание текстового стиля для вторичного текста
  static TextStyle secondary({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    required Brightness brightness,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.getTextColor(brightness, type: TextType.secondary),
      height: height ?? 1.4,
    );
  }

  /// Создание текстового стиля для подсказок
  static TextStyle hint({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    required Brightness brightness,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.getTextColor(brightness, type: TextType.hint),
      height: 1.4,
    );
  }

  /// Создание текстового стиля для отключенного текста
  static TextStyle disabled({
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    required Brightness brightness,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.getTextColor(brightness, type: TextType.disabled),
      height: 1.4,
    );
  }

  /// Предопределенные стили для часто используемых элементов

  /// Заголовки
  static TextStyle h1({required Brightness brightness, Color? color}) =>
      heading(fontSize: sizeXXXXLarge, brightness: brightness, color: color);

  static TextStyle h2({required Brightness brightness, Color? color}) =>
      heading(fontSize: sizeXXXLarge, brightness: brightness, color: color);

  static TextStyle h3({required Brightness brightness, Color? color}) =>
      heading(fontSize: sizeXXLarge, brightness: brightness, color: color);

  static TextStyle h4({required Brightness brightness, Color? color}) =>
      heading(fontSize: sizeXLarge, brightness: brightness, color: color);

  static TextStyle h5({required Brightness brightness, Color? color}) =>
      heading(fontSize: sizeLarge, brightness: brightness, color: color);

  /// Основной текст
  static TextStyle bodyLarge({required Brightness brightness, Color? color}) =>
      body(fontSize: sizeLarge, brightness: brightness, color: color);

  static TextStyle bodyMedium({required Brightness brightness, Color? color}) =>
      body(fontSize: sizeMedium, brightness: brightness, color: color);

  static TextStyle bodySmall({required Brightness brightness, Color? color}) =>
      body(fontSize: sizeSmall, brightness: brightness, color: color);

  /// Вторичный текст
  static TextStyle caption({required Brightness brightness, Color? color}) =>
      secondary(fontSize: sizeSmall, brightness: brightness, color: color);

  static TextStyle captionSmall({required Brightness brightness, Color? color}) =>
      secondary(fontSize: sizeXSmall, brightness: brightness, color: color);

  /// Подсказки и плейсхолдеры
  static TextStyle hintLarge({required Brightness brightness, Color? color}) =>
      hint(fontSize: sizeLarge, brightness: brightness, color: color);

  static TextStyle hintMedium({required Brightness brightness, Color? color}) =>
      hint(fontSize: sizeMedium, brightness: brightness, color: color);

  static TextStyle hintSmall({required Brightness brightness, Color? color}) =>
      hint(fontSize: sizeSmall, brightness: brightness, color: color);

  /// Специальные стили для UI элементов

  /// Стиль для кнопок
  static TextStyle buttonLarge({required Brightness brightness, Color? color}) =>
      body(
        fontSize: sizeMedium,
        fontWeight: FontWeight.w600,
        brightness: brightness,
        color: color,
      );

  static TextStyle buttonMedium({required Brightness brightness, Color? color}) =>
      body(
        fontSize: sizeSmall,
        fontWeight: FontWeight.w600,
        brightness: brightness,
        color: color,
      );

  /// Стиль для меток и бейджей
  static TextStyle label({required Brightness brightness, Color? color}) =>
      body(
        fontSize: sizeXSmall,
        fontWeight: FontWeight.w600,
        brightness: brightness,
        color: color,
      );

  /// Стиль для навигации
  static TextStyle navItem({required Brightness brightness, Color? color}) =>
      body(
        fontSize: sizeMedium,
        fontWeight: FontWeight.w600,
        brightness: brightness,
        color: color,
      );

  /// Стиль для заголовков секций
  static TextStyle sectionTitle({required Brightness brightness, Color? color}) =>
      heading(
        fontSize: sizeXLarge,
        fontWeight: FontWeight.bold,
        brightness: brightness,
        color: color,
      );

  /// Стиль для подзаголовков
  static TextStyle subtitle({required Brightness brightness, Color? color}) =>
      heading(
        fontSize: sizeMedium,
        fontWeight: FontWeight.w600,
        brightness: brightness,
        color: color,
      );
}
