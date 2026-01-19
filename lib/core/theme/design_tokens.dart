import 'package:flutter/material.dart';

/// Design tokens for the application
/// Provides consistent spacing, typography, and visual elements
class DesignTokens {
  // Spacing scale based on 4px
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;
  static const double spacingXXXXL = 40.0;

  // Border radius
  static const double borderRadiusSM = 8.0;
  static const double borderRadiusMD = 12.0;
  static const double borderRadiusLG = 16.0;
  static const double borderRadiusXL = 20.0;

  // Shadows
  static const BoxShadow softShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 4.0,
    offset: Offset(0, 2),
  );

  static const BoxShadow mediumShadow = BoxShadow(
    color: Colors.black38,
    blurRadius: 8.0,
    offset: Offset(0, 4),
  );

  static const BoxShadow strongShadow = BoxShadow(
    color: Colors.black54,
    blurRadius: 16.0,
    offset: Offset(0, 8),
  );

  // Typography scale
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeXXXL = 24.0;
  static const double fontSizeXXXXL = 32.0;

  // Opacity values
  static const double opacityLow = 0.3;
  static const double opacityMedium = 0.6;
  static const double opacityHigh = 0.8;

  // Animation durations
  static const Duration shortDuration = Duration(milliseconds: 150);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Breakpoints for responsive design
  static const double mobileMaxWidth = 720.0;
  static const double tabletMinWidth = 721.0;
  static const double tabletMaxWidth = 1024.0;
  static const double desktopMinWidth = 1025.0;

  // Grid columns for different screen sizes
  static int getGridColumns(double width) {
    if (width >= desktopMinWidth) return 6;
    if (width >= tabletMinWidth) return 4;
    return 2;
  }

  // Easing curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounce = Curves.bounceOut;
}

/// Accent color palette with sub-tones
class AccentColorPalette {
  final Color primary;
  final Color light;
  final Color dark;
  final Color contrast;

  const AccentColorPalette({
    required this.primary,
    required this.light,
    required this.dark,
    required this.contrast,
  });

  /// Generate contrast color based on primary color brightness
  static Color _generateContrast(Color primary) {
    final brightness = primary.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  /// Create palette from primary color with auto-generated variants
  factory AccentColorPalette.fromPrimary(Color primary) {
    // Generate light variant (add white)
    final light = Color.lerp(primary, Colors.white, 0.3)!;
    
    // Generate dark variant (add black)
    final dark = Color.lerp(primary, Colors.black, 0.2)!;
    
    // Generate contrast color based on brightness
    final contrast = _generateContrast(primary);

    return AccentColorPalette(
      primary: primary,
      light: light,
      dark: dark,
      contrast: contrast,
    );
  }

  /// Default purple accent (#CA47E6)
  static const purple = AccentColorPalette(
    primary: Color(0xFFCA47E6),
    light: Color(0xFFE1A7F0),
    dark: Color(0xFF9A2BB8),
    contrast: Colors.white,
  );

  /// Blue accent
  static const blue = AccentColorPalette(
    primary: Color(0xFF4FC3F7),
    light: Color(0xFFA5D8FF),
    dark: Color(0xFF1890FF),
    contrast: Colors.white,
  );

  /// Green accent
  static const green = AccentColorPalette(
    primary: Color(0xFF66BB6A),
    light: Color(0xFFA5D6A7),
    dark: Color(0xFF2E7D32),
    contrast: Colors.white,
  );

  /// Red accent
  static const red = AccentColorPalette(
    primary: Color(0xFFEF5350),
    light: Color(0xFFFFCDD2),
    dark: Color(0xFFC62828),
    contrast: Colors.white,
  );

  /// Orange accent
  static const orange = AccentColorPalette(
    primary: Color(0xFFFF9800),
    light: Color(0xFFFFB74D),
    dark: Color(0xFFEF6C00),
    contrast: Colors.white,
  );

  /// Cyan accent
  static const cyan = AccentColorPalette(
    primary: Color(0xFF26C6DA),
    light: Color(0xFF80DEEA),
    dark: Color(0xFF00838F),
    contrast: Colors.white,
  );

  /// Get all available accent colors
  static List<AccentColorPalette> getAll() {
    return [
      purple,
      blue,
      green,
      red,
      orange,
      cyan,
    ];
  }
}

/// Semantic color scheme for the application
class SemanticColorScheme {
  final Color background;
  final Color surface;
  final Color primaryText;
  final Color secondaryText;
  final Color disabledText;
  final Color border;
  final Color divider;
  final Color overlay;

  const SemanticColorScheme({
    required this.background,
    required this.surface,
    required this.primaryText,
    required this.secondaryText,
    required this.disabledText,
    required this.border,
    required this.divider,
    required this.overlay,
  });

  /// Light theme semantic colors
  static const light = SemanticColorScheme(
    background: Color(0xFFF5F5F5),
    surface: Colors.white,
    primaryText: Colors.black87,
    secondaryText: Colors.black54,
    disabledText: Colors.black38,
    border: Colors.black12,
    divider: Colors.black12,
    overlay: Colors.black38,
  );

  /// Dark theme semantic colors
  static const dark = SemanticColorScheme(
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    primaryText: Colors.white,
    secondaryText: Colors.white70,
    disabledText: Colors.white38,
    border: Colors.white12,
    divider: Colors.white12,
    overlay: Colors.black54,
  );
}
