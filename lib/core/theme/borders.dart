import 'package:flutter/material.dart';
import 'package:a_watch/core/theme/colors.dart';

/// Система border radius приложения
/// Предоставляет согласованные радиусы скругления для всех UI элементов
class AppBorders {
  /// Очень маленький радиус (для subtle элементов)
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(4.0));

  /// Маленький радиус (для кнопок и небольших элементов)
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(8.0));

  /// Средний радиус (для карточек и полей ввода)
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(12.0));

  /// Большой радиус (для крупных карточек и контейнеров)
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(16.0));

  /// Очень большой радиус (для floating элементов)
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(20.0));

  /// Круглый (для круглых элементов)
  static const BorderRadius radiusRound = BorderRadius.all(Radius.circular(9999.0));

  /// Только верхние углы
  static const BorderRadius radiusTopSM = BorderRadius.vertical(
    top: Radius.circular(8.0),
  );

  static const BorderRadius radiusTopMD = BorderRadius.vertical(
    top: Radius.circular(12.0),
  );

  static const BorderRadius radiusTopLG = BorderRadius.vertical(
    top: Radius.circular(16.0),
  );

  /// Только нижние углы
  static const BorderRadius radiusBottomSM = BorderRadius.vertical(
    bottom: Radius.circular(8.0),
  );

  static const BorderRadius radiusBottomMD = BorderRadius.vertical(
    bottom: Radius.circular(12.0),
  );

  static const BorderRadius radiusBottomLG = BorderRadius.vertical(
    bottom: Radius.circular(16.0),
  );

  /// Только левые углы
  static const BorderRadius radiusLeftSM = BorderRadius.horizontal(
    left: Radius.circular(8.0),
  );

  static const BorderRadius radiusLeftMD = BorderRadius.horizontal(
    left: Radius.circular(12.0),
  );

  static const BorderRadius radiusLeftLG = BorderRadius.horizontal(
    left: Radius.circular(16.0),
  );

  /// Только правые углы
  static const BorderRadius radiusRightSM = BorderRadius.horizontal(
    right: Radius.circular(8.0),
  );

  static const BorderRadius radiusRightMD = BorderRadius.horizontal(
    right: Radius.circular(12.0),
  );

  static const BorderRadius radiusRightLG = BorderRadius.horizontal(
    right: Radius.circular(16.0),
  );

  /// Создать border radius с кастомным значением
  static BorderRadius custom(double radius) {
    return BorderRadius.all(Radius.circular(radius));
  }

  /// Создать border radius только для определенных углов
  static BorderRadius only({
    double topLeft = 0.0,
    double topRight = 0.0,
    double bottomLeft = 0.0,
    double bottomRight = 0.0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  /// Получить border radius по типу
  static BorderRadius getRadius(BorderRadiusType type) {
    switch (type) {
      case BorderRadiusType.xs:
        return radiusXS;
      case BorderRadiusType.sm:
        return radiusSM;
      case BorderRadiusType.md:
        return radiusMD;
      case BorderRadiusType.lg:
        return radiusLG;
      case BorderRadiusType.xl:
        return radiusXL;
      case BorderRadiusType.round:
        return radiusRound;
      case BorderRadiusType.topSM:
        return radiusTopSM;
      case BorderRadiusType.topMD:
        return radiusTopMD;
      case BorderRadiusType.topLG:
        return radiusTopLG;
      case BorderRadiusType.bottomSM:
        return radiusBottomSM;
      case BorderRadiusType.bottomMD:
        return radiusBottomMD;
      case BorderRadiusType.bottomLG:
        return radiusBottomLG;
      case BorderRadiusType.leftSM:
        return radiusLeftSM;
      case BorderRadiusType.leftMD:
        return radiusLeftMD;
      case BorderRadiusType.leftLG:
        return radiusLeftLG;
      case BorderRadiusType.rightSM:
        return radiusRightSM;
      case BorderRadiusType.rightMD:
        return radiusRightMD;
      case BorderRadiusType.rightLG:
        return radiusRightLG;
    }
  }
}

/// Типы border radius для удобства использования
enum BorderRadiusType {
  xs,        // Очень маленький (4px)
  sm,        // Маленький (8px)
  md,        // Средний (12px)
  lg,        // Большой (16px)
  xl,        // Очень большой (20px)
  round,     // Круглый
  topSM,     // Только верхние маленькие
  topMD,     // Только верхние средние
  topLG,     // Только верхние большие
  bottomSM,  // Только нижние маленькие
  bottomMD,  // Только нижние средние
  bottomLG,  // Только нижние большие
  leftSM,    // Только левые маленькие
  leftMD,    // Только левые средние
  leftLG,    // Только левые большие
  rightSM,   // Только правые маленькие
  rightMD,   // Только правые средние
  rightLG,   // Только правые большие
}

/// Готовые border для часто используемых случаев
class AppBorderStyles {
  /// Базовый border для светлой темы
  static const BorderSide light = BorderSide(
    color: AppColors.borderLight,
    width: 1.0,
  );

  /// Базовый border для темной темы
  static const BorderSide dark = BorderSide(
    color: AppColors.borderDark,
    width: 1.0,
  );

  /// Тонкий border
  static const BorderSide thin = BorderSide(
    color: AppColors.borderLight,
    width: 0.5,
  );

  /// Толстый border
  static const BorderSide thick = BorderSide(
    color: AppColors.borderLight,
    width: 2.0,
  );

  /// Dashed border (не константа, так как BorderStyle не поддерживает константы)
  static BorderSide dashed() => BorderSide(
    color: AppColors.borderLight,
    width: 1.0,
    style: BorderStyle.solid, // BorderStyle не поддерживает dashed
  );

  /// Dotted border (не константа, так как BorderStyle не поддерживает константы)
  static BorderSide dotted() => BorderSide(
    color: AppColors.borderLight,
    width: 1.0,
    style: BorderStyle.solid, // BorderStyle не поддерживает dotted
  );

  /// Border для активного состояния
  static const BorderSide active = BorderSide(
    color: AppColors.accentPrimary,
    width: 2.0,
  );

  /// Border для disabled состояния
  static const BorderSide disabled = BorderSide(
    color: AppColors.textDisabled,
    width: 1.0,
  );

  /// Border для ошибки
  static const BorderSide error = BorderSide(
    color: AppColors.error,
    width: 1.5,
  );

  /// Border для успеха
  static const BorderSide success = BorderSide(
    color: AppColors.success,
    width: 1.5,
  );

  /// Border для предупреждения
  static const BorderSide warning = BorderSide(
    color: AppColors.warning,
    width: 1.5,
  );

  /// Border для информации
  static const BorderSide info = BorderSide(
    color: AppColors.info,
    width: 1.5,
  );

  /// Создать border с кастомными параметрами
  static BorderSide custom({
    required Color color,
    double width = 1.0,
    BorderStyle style = BorderStyle.solid,
  }) {
    return BorderSide(
      color: color,
      width: width,
      style: style,
    );
  }
}
