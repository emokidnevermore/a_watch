import 'package:flutter/material.dart';

/// Responsive layout utilities for unified design system
class ResponsiveLayout {
  static const double mobileMaxWidth = 720.0;
  static const double tabletMinWidth = 721.0;
  static const double tabletMaxWidth = 1024.0;
  static const double desktopMinWidth = 1025.0;

  /// Check if the current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }

  /// Check if the current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletMinWidth && width <= tabletMaxWidth;
  }

  /// Check if the current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMinWidth;
  }

  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopMinWidth) return 6;
    if (width >= tabletMinWidth) return 4;
    return 2;
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, SpacingType type) {
    final isMobile = ResponsiveLayout.isMobile(context);
    switch (type) {
      case SpacingType.xxs:
        return isMobile ? 2.0 : 4.0;
      case SpacingType.xs:
        return isMobile ? 4.0 : 8.0;
      case SpacingType.sm:
        return isMobile ? 8.0 : 12.0;
      case SpacingType.md:
        return isMobile ? 12.0 : 16.0;
      case SpacingType.lg:
        return isMobile ? 16.0 : 20.0;
      case SpacingType.xl:
        return isMobile ? 20.0 : 24.0;
      case SpacingType.xxl:
        return isMobile ? 24.0 : 32.0;
    }
  }

  /// Get responsive text size
  static double getTextSize(BuildContext context, TextSize size) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final scale = isMobile ? 0.9 : 1.0;

    switch (size) {
      case TextSize.xs:
        return 10.0 * scale;
      case TextSize.sm:
        return 12.0 * scale;
      case TextSize.md:
        return 14.0 * scale;
      case TextSize.lg:
        return 16.0 * scale;
      case TextSize.xl:
        return 18.0 * scale;
      case TextSize.xxl:
        return 20.0 * scale;
      case TextSize.xxxl:
        return 24.0 * scale;
      case TextSize.xxxxl:
        return 32.0 * scale;
    }
  }

  /// Build responsive widget
  static Widget buildResponsive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    required Widget desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return desktop;
    }
  }
}

/// Spacing types for responsive design
enum SpacingType {
  xxs, // 2-4px
  xs,  // 4-8px
  sm,  // 8-12px
  md,  // 12-16px
  lg,  // 16-20px
  xl,  // 20-24px
  xxl, // 24-32px
}

/// Text size types for responsive design
enum TextSize {
  xs,     // 10px
  sm,     // 12px
  md,     // 14px
  lg,     // 16px
  xl,     // 18px
  xxl,    // 20px
  xxxl,   // 24px
  xxxxl,  // 32px
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, constraints);
      },
    );
  }
}

/// Unified responsive card layout
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final cardPadding = padding ?? EdgeInsets.all(
      ResponsiveLayout.getSpacing(context, SpacingType.md)
    );

    return Card(
      elevation: elevation ?? (isMobile ? 1 : 2),
      margin: EdgeInsets.all(
        ResponsiveLayout.getSpacing(context, SpacingType.xs)
      ),
      child: Padding(
        padding: cardPadding,
        child: child,
      ),
    );
  }
}

/// Unified responsive grid layout
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 2 / 3,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveLayout.getGridColumns(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Unified responsive list layout
class ResponsiveList extends StatelessWidget {
  final List<Widget> children;
  final ScrollPhysics? physics;

  const ResponsiveList({
    super.key,
    required this.children,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    if (isMobile) {
      // Mobile: vertical list
      return ListView(
        shrinkWrap: true,
        physics: physics ?? const NeverScrollableScrollPhysics(),
        children: children,
      );
    } else {
      // Desktop/Tablet: horizontal list or grid
      return Wrap(
        spacing: ResponsiveLayout.getSpacing(context, SpacingType.sm),
        runSpacing: ResponsiveLayout.getSpacing(context, SpacingType.sm),
        children: children,
      );
    }
  }
}
