import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:a_watch/core/theme/theme_manager.dart';
import 'package:a_watch/core/theme/design_tokens.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth * 0.1;
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: DesignTokens.spacingLG,
            ),
            children: [
              // Theme section
              _buildSettingsSection(
                context: context,
                title: 'Тема',
                children: [
                  _buildThemeOption(
                    context,
                    label: 'Светлая',
                    value: AppTheme.light,
                    icon: Icons.wb_sunny,
                  ),
                  _buildThemeOption(
                    context,
                    label: 'Темная',
                    value: AppTheme.dark,
                    icon: Icons.nightlight,
                  ),
                  _buildThemeOption(
                    context,
                    label: 'Системная',
                    value: AppTheme.system,
                    icon: Icons.settings_system_daydream,
                  ),
                ],
              ),

              const SizedBox(height: DesignTokens.spacingLG),

              // Accent color section
              _buildSettingsSection(
                context: context,
                title: 'Акцентный цвет',
                children: [const _AccentColorGrid()],
              ),

              const SizedBox(height: DesignTokens.spacingLG),

              // About section
              _buildSettingsSection(
                context: context,
                title: 'О приложении',
                children: [
                  _buildAboutItem(
                    context,
                    title: 'Версия',
                    subtitle: '0.1.0',
                    icon: Icons.info,
                  ),
                  _buildAboutItem(
                    context,
                    title: 'Разработчик',
                    subtitle: 'A-Watch Team',
                    icon: Icons.person,
                  ),
                  _buildAboutItem(
                    context,
                    title: 'Поддержка',
                    subtitle: 'support@a-watch.com',
                    icon: Icons.email,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.borderRadiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(DesignTokens.spacingMD),
            child: Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String label,
    required AppTheme value,
    required IconData icon,
  }) {
    final themeManager = Provider.of<ThemeManager>(context);
    final isSelected = themeManager.currentTheme == value;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? colorScheme.primary : colorScheme.secondary,
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: Radio<AppTheme>(
        value: value,
        groupValue: themeManager.currentTheme,
        activeColor: colorScheme.primary,
        onChanged: (AppTheme? newValue) {
          if (newValue != null) {
            themeManager.setTheme(newValue);
          }
        },
      ),
      onTap: () => themeManager.setTheme(value),
    );
  }

  Widget _buildAboutItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.secondary, size: 20),
      ),
      title: Text(
        title,
        style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _AccentColorGrid extends StatelessWidget {
  const _AccentColorGrid();

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    // Get all colors except cyan, we'll replace it with custom
    final colors = AccentColorPalette.getAll().where((palette) =>
      palette.primary != AccentColorPalette.cyan.primary
    ).toList();

    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spacingMD),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: colors.length + 1, // +1 for custom color
        itemBuilder: (context, index) {
          if (index < colors.length) {
            // Regular color
            final color = colors[index];
            final isSelected =
                themeManager.currentAccentPalette.primary == color.primary;

            return GestureDetector(
              onTap: () {
                final accentColor = _accentColorFromPalette(color);
                themeManager.setAccent(accentColor);
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.primary, color.dark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    DesignTokens.borderRadiusMD,
                  ),
                  boxShadow: isSelected
                      ? [DesignTokens.mediumShadow]
                      : [DesignTokens.softShadow],
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: isSelected ? 3 : 0,
                  ),
                ),
                child: Center(
                  child: Text(
                    _accentColorName(color),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            // Custom color picker
            final isSelected = themeManager.currentAccent == AccentColor.custom;

            return GestureDetector(
              onTap: () => _showColorPicker(context, themeManager),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [themeManager.customColor, themeManager.customColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(
                    DesignTokens.borderRadiusMD,
                  ),
                  boxShadow: isSelected
                      ? [DesignTokens.mediumShadow]
                      : [DesignTokens.softShadow],
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: isSelected ? 3 : 0,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.palette,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Свой цвет',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showColorPicker(BuildContext context, ThemeManager themeManager) {
    Color selectedColor = themeManager.customColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выберите цвет'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                selectedColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Выбрать'),
              onPressed: () {
                themeManager.setAccent(AccentColor.custom);
                themeManager.setCustomColor(selectedColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  AccentColor _accentColorFromPalette(AccentColorPalette palette) {
    if (palette.primary == AccentColorPalette.purple.primary) {
      return AccentColor.purple;
    } else if (palette.primary == AccentColorPalette.blue.primary) {
      return AccentColor.blue;
    } else if (palette.primary == AccentColorPalette.green.primary) {
      return AccentColor.green;
    } else if (palette.primary == AccentColorPalette.red.primary) {
      return AccentColor.red;
    } else if (palette.primary == AccentColorPalette.orange.primary) {
      return AccentColor.orange;
    } else {
      return AccentColor.purple;
    }
  }

  String _accentColorName(AccentColorPalette palette) {
    if (palette.primary == AccentColorPalette.purple.primary) {
      return 'Фиолетовый';
    } else if (palette.primary == AccentColorPalette.blue.primary) {
      return 'Синий';
    } else if (palette.primary == AccentColorPalette.green.primary) {
      return 'Зеленый';
    } else if (palette.primary == AccentColorPalette.red.primary) {
      return 'Красный';
    } else if (palette.primary == AccentColorPalette.orange.primary) {
      return 'Оранжевый';
    } else {
      return 'Неизвестный';
    }
  }
}
