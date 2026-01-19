import 'package:flutter/material.dart';

/// Система теней приложения
/// Предоставляет согласованные тени для всех UI элементов
class AppShadows {
  /// Легкая тень для subtle элементов
  static const BoxShadow light = BoxShadow(
    color: Color(0x1A000000), // 10% черный
    blurRadius: 4.0,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  /// Средняя тень для карточек и кнопок
  static const BoxShadow medium = BoxShadow(
    color: Color(0x24000000), // 14% черный
    blurRadius: 8.0,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  /// Сильная тень для выделенных элементов
  static const BoxShadow strong = BoxShadow(
    color: Color(0x33000000), // 20% черный
    blurRadius: 16.0,
    offset: Offset(0, 8),
    spreadRadius: 0,
  );

  /// Очень сильная тень для floating элементов
  static const BoxShadow heavy = BoxShadow(
    color: Color(0x40000000), // 25% черный
    blurRadius: 24.0,
    offset: Offset(0, 12),
    spreadRadius: 0,
  );

  /// Тень для нажатых состояний
  static const BoxShadow pressed = BoxShadow(
    color: Color(0x0F000000), // 6% черный
    blurRadius: 2.0,
    offset: Offset(0, 1),
    spreadRadius: 0,
  );

  /// Тень для disabled состояний
  static const BoxShadow disabled = BoxShadow(
    color: Color(0x14000000), // 8% черный
    blurRadius: 2.0,
    offset: Offset(0, 1),
    spreadRadius: 0,
  );

  /// Тень для активных/выбранных элементов
  static const BoxShadow active = BoxShadow(
    color: Color(0x2A000000), // 16% черный
    blurRadius: 12.0,
    offset: Offset(0, 6),
    spreadRadius: 0,
  );

  /// Тень для floating action button
  static const BoxShadow fab = BoxShadow(
    color: Color(0x40000000), // 25% черный
    blurRadius: 20.0,
    offset: Offset(0, 10),
    spreadRadius: 0,
  );

  /// Тень для диалогов и модальных окон
  static const BoxShadow dialog = BoxShadow(
    color: Color(0x33000000), // 20% черный
    blurRadius: 30.0,
    offset: Offset(0, 15),
    spreadRadius: 0,
  );

  /// Тень дляAppBar
  static const BoxShadow appBar = BoxShadow(
    color: Color(0x1F000000), // 12% черный
    blurRadius: 8.0,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  /// Тень для навигационной панели
  static const BoxShadow navigation = BoxShadow(
    color: Color(0x1A000000), // 10% черный
    blurRadius: 6.0,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  /// Тень для карточек с изображениями
  static const BoxShadow imageCard = BoxShadow(
    color: Color(0x24000000), // 14% черный
    blurRadius: 12.0,
    offset: Offset(0, 6),
    spreadRadius: 0,
  );

  /// Тень для floating элементов (например, тултипов)
  static const BoxShadow floating = BoxShadow(
    color: Color(0x2A000000), // 16% черный
    blurRadius: 16.0,
    offset: Offset(0, 8),
    spreadRadius: 0,
  );

  /// Получить список теней для использования в BoxDecoration
  static List<BoxShadow> getShadowList(ShadowType type) {
    switch (type) {
      case ShadowType.light:
        return [light];
      case ShadowType.medium:
        return [medium];
      case ShadowType.strong:
        return [strong];
      case ShadowType.heavy:
        return [heavy];
      case ShadowType.pressed:
        return [pressed];
      case ShadowType.disabled:
        return [disabled];
      case ShadowType.active:
        return [active];
      case ShadowType.fab:
        return [fab];
      case ShadowType.dialog:
        return [dialog];
      case ShadowType.appBar:
        return [appBar];
      case ShadowType.navigation:
        return [navigation];
      case ShadowType.imageCard:
        return [imageCard];
      case ShadowType.floating:
        return [floating];
    }
  }

  /// Создать тень с кастомными параметрами
  static BoxShadow custom({
    required Color color,
    required double blurRadius,
    required Offset offset,
    double spreadRadius = 0,
  }) {
    return BoxShadow(
      color: color,
      blurRadius: blurRadius,
      offset: offset,
      spreadRadius: spreadRadius,
    );
  }
}

/// Типы теней для удобства использования
enum ShadowType {
  light,        // Легкая тень
  medium,       // Средняя тень
  strong,       // Сильная тень
  heavy,        // Очень сильная тень
  pressed,      // Нажатое состояние
  disabled,     // Отключенное состояние
  active,       // Активное состояние
  fab,          // Floating Action Button
  dialog,       // Диалоги
  appBar,       // AppBar
  navigation,   // Навигация
  imageCard,    // Карточки с изображениями
  floating,     // Floating элементы
}
