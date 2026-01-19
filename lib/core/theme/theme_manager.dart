import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'design_tokens.dart';

/// Theme mode enum
enum AppTheme {
  light,
  dark,
  system,
}

/// Accent color enum
enum AccentColor {
  purple,
  blue,
  green,
  red,
  orange,
  cyan,
  custom,
}

/// Theme manager for handling theme state and persistence
class ThemeManager with ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _accentKey = 'accent_color';
  static const String _customColorKey = 'custom_color';

  AppTheme _currentTheme = AppTheme.system;
  AccentColor _currentAccent = AccentColor.purple;
  Color _customColor = const Color(0xFF26C6DA); // Default to cyan

  AppTheme get currentTheme => _currentTheme;
  AccentColor get currentAccent => _currentAccent;
  Color get customColor => _customColor;

  AccentColorPalette get currentAccentPalette {
    switch (_currentAccent) {
      case AccentColor.blue:
        return AccentColorPalette.blue;
      case AccentColor.green:
        return AccentColorPalette.green;
      case AccentColor.red:
        return AccentColorPalette.red;
      case AccentColor.orange:
        return AccentColorPalette.orange;
      case AccentColor.cyan:
        return AccentColorPalette.cyan;
      case AccentColor.custom:
        return AccentColorPalette.fromPrimary(_customColor);
      default:
        return AccentColorPalette.purple;
    }
  }

  ThemeMode get themeMode {
    switch (_currentTheme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }

  ThemeData get lightTheme {
    final palette = currentAccentPalette;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: Brightness.light,
        primary: palette.primary,
        secondary: palette.primary,
        surface: Colors.white,
        onPrimary: palette.contrast,
        onSecondary: palette.contrast,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: palette.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(color: palette.primary, fontWeight: FontWeight.w600);
            }
            return const TextStyle(color: Colors.black54);
          },
        ),
      ),
      dividerColor: Colors.black12,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.dragged)) {
              return palette.primary.withValues(alpha: 0.8);
            }
            return palette.primary.withValues(alpha: 0.4);
          },
        ),
        thickness: WidgetStateProperty.all(6),
        radius: const Radius.circular(8),
      ),
    );
  }

  ThemeData get darkTheme {
    final palette = currentAccentPalette;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: Brightness.dark,
        primary: palette.primary,
        secondary: palette.primary,
        surface: const Color(0xFF1E1E1E),
        onPrimary: palette.contrast,
        onSecondary: palette.contrast,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
        indicatorColor: palette.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(color: palette.primary, fontWeight: FontWeight.w600);
            }
            return const TextStyle(color: Colors.white70);
          },
        ),
      ),
      dividerColor: Colors.white12,
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.dragged)) {
              return palette.primary.withValues(alpha: 0.8);
            }
            return palette.primary.withValues(alpha: 0.4);
          },
        ),
        thickness: WidgetStateProperty.all(6),
        radius: const Radius.circular(8),
      ),
    );
  }



  ThemeManager() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? 'system';
    final accentString = prefs.getString(_accentKey) ?? 'purple';
    final customColorValue = prefs.getInt(_customColorKey) ?? 0xFF26C6DA;

    _currentTheme = AppTheme.values.firstWhere(
      (theme) => theme.name == themeString,
      orElse: () => AppTheme.system,
    );

    _currentAccent = AccentColor.values.firstWhere(
      (accent) => accent.name == accentString,
      orElse: () => AccentColor.purple,
    );

    _customColor = Color(customColorValue);

    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);
    notifyListeners();
  }

  Future<void> setAccent(AccentColor accent) async {
    _currentAccent = accent;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accentKey, accent.name);
    notifyListeners();
  }

  Future<void> setCustomColor(Color color) async {
    _customColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_customColorKey, color.toARGB32());
    notifyListeners();
  }

  Color getContrastColor() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    return isDarkMode ? Colors.white : Colors.black;
  }
}
