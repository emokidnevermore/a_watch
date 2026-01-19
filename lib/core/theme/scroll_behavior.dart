import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Плавный скролл для десктопа
class SmoothScrollBehavior extends ScrollBehavior {
  const SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Для десктопа используем более плавную физику
    if (kIsWeb || getPlatform(context) == TargetPlatform.macOS || getPlatform(context) == TargetPlatform.windows || getPlatform(context) == TargetPlatform.linux) {
      return const SmoothDesktopScrollPhysics(
        parent: BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
      );
    }
    return super.getScrollPhysics(context);
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Для десктопа делаем более тонкие и плавные скроллбары
    if (kIsWeb || getPlatform(context) == TargetPlatform.macOS || getPlatform(context) == TargetPlatform.windows || getPlatform(context) == TargetPlatform.linux) {
      return Scrollbar(
        thickness: 8,
        radius: const Radius.circular(4),
        child: child,
      );
    }
    return super.buildScrollbar(context, child, details);
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Отключаем индикатор overscroll на десктопе для более плавного вида
    if (kIsWeb || getPlatform(context) == TargetPlatform.macOS || getPlatform(context) == TargetPlatform.windows || getPlatform(context) == TargetPlatform.linux) {
      return child;
    }
    return super.buildOverscrollIndicator(context, child, details);
  }
}

/// Плавная физика скролла для десктопа
class SmoothDesktopScrollPhysics extends ScrollPhysics {
  const SmoothDesktopScrollPhysics({super.parent});

  @override
  SmoothDesktopScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothDesktopScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Используем стандартную пружину Flutter для плавного скролла
    final spring = SpringSimulation(
      const SpringDescription(
        mass: 1.0,
        stiffness: 100.0, // Меньше = плавнее
        damping: 20.0,    // Больше = меньше колебаний
      ),
      position.pixels,
      position.pixels + velocity * 0.2, // Уменьшаем множитель для плавности
      velocity * 0.5, // Уменьшаем скорость
      tolerance: const Tolerance(
        velocity: 0.1, // Более низкая точность для плавности
        distance: 1.0,
      ),
    );

    // Возвращаем симуляцию только если есть значительная скорость
    return velocity.abs() > 50 ? spring : null;
  }

  @override
  double get minFlingVelocity => 50.0; // Уменьшаем для более чувствительного скролла

  @override
  double get maxFlingVelocity => 4000.0;

  @override
  double get dragStartDistanceMotionThreshold => 3.5; // Уменьшаем для более быстрого старта

  @override
  bool get allowImplicitScrolling => true;
}

/// Физика для горизонтальных списков с плавным затуханием
class SmoothHorizontalScrollPhysics extends ScrollPhysics {
  const SmoothHorizontalScrollPhysics({super.parent});

  @override
  SmoothHorizontalScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothHorizontalScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (velocity.abs() > 50) {
      return SpringSimulation(
        const SpringDescription(
          mass: 1.0,
          stiffness: 120.0,
          damping: 25.0,
        ),
        position.pixels,
        position.pixels + velocity * 0.15,
        velocity * 0.6,
        tolerance: const Tolerance(
          velocity: 0.1,
          distance: 1.0,
        ),
      );
    }
    return null;
  }

  @override
  double get minFlingVelocity => 50.0;

  @override
  double get maxFlingVelocity => 3000.0;
}
