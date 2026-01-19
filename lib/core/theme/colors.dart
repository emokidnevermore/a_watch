import 'package:flutter/material.dart';

/// Центральный цветовой токен для акцентного цвета приложения
/// Все компоненты будут использовать этот цвет для согласованности
class AppColors {
  /// Основной акцентный цвет (фиолетовый #CA47E6)
  static const Color accentPrimary = Color(0xFFCA47E6);
  
  /// Светлый оттенок акцентного цвета
  static const Color accentLight = Color(0xFFE1A7F0);
  
  /// Темный оттенок акцентного цвета
  static const Color accentDark = Color(0xFF9A2BB8);
  
  /// Контрастный цвет для акцентного (автоматически определяется)
  static const Color accentContrast = Colors.white;

  /// Вторичные цвета для различных состояний
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  /// Нейтральные цвета для текста и фона
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textDisabled = Colors.black38;
  static const Color textHint = Colors.black45;

  /// Цвета для темной темы
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Colors.white70;
  static const Color textDisabledDark = Colors.white38;
  static const Color textHintDark = Colors.white54;

  /// Фоновые цвета
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  /// Цвета границ и разделителей
  static const Color borderLight = Colors.black12;
  static const Color borderDark = Colors.white12;
  static const Color dividerLight = Colors.black12;
  static const Color dividerDark = Colors.white12;

  /// Цвета для состояний
  static const Color overlay = Colors.black54;
  static const Color shadow = Colors.black26;

  /// Получить цвет в зависимости от темы
  static Color getTextColor(Brightness brightness, {required TextType type}) {
    switch (type) {
      case TextType.primary:
        return brightness == Brightness.light ? textPrimary : textPrimaryDark;
      case TextType.secondary:
        return brightness == Brightness.light ? textSecondary : textSecondaryDark;
      case TextType.disabled:
        return brightness == Brightness.light ? textDisabled : textDisabledDark;
      case TextType.hint:
        return brightness == Brightness.light ? textHint : textHintDark;
    }
  }

  /// Получить фоновый цвет в зависимости от темы
  static Color getBackgroundColor(Brightness brightness) {
    return brightness == Brightness.light ? backgroundLight : backgroundDark;
  }

  /// Получить цвет поверхности в зависимости от темы
  static Color getSurfaceColor(Brightness brightness) {
    return brightness == Brightness.light ? surfaceLight : surfaceDark;
  }

  /// Получить цвет границы в зависимости от темы
  static Color getBorderColor(Brightness brightness) {
    return brightness == Brightness.light ? borderLight : borderDark;
  }

  /// Получить цвет разделителя в зависимости от темы
  static Color getDividerColor(Brightness brightness) {
    return brightness == Brightness.light ? dividerLight : dividerDark;
  }
}

/// Типы текста для удобства использования
enum TextType {
  primary,   // Основной текст
  secondary, // Вторичный текст
  disabled,  // Отключенный текст
  hint,      // Подсказка
}
