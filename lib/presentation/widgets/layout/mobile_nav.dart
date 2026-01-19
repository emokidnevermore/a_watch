import 'package:flutter/material.dart';
import 'navigation_section.dart';

/// Mobile navigation using Material 3 NavigationBar
class MobileNav extends StatelessWidget {
  final NavigationSection currentSection;
  final ValueChanged<NavigationSection> onSectionChanged;

  const MobileNav({
    super.key,
    required this.currentSection,
    required this.onSectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _getNavigationIndex(currentSection),
      onDestinationSelected: (index) {
        final section = _getSectionFromIndex(index);
        onSectionChanged(section);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Главная',
        ),
        NavigationDestination(
          icon: Icon(Icons.history),
          label: 'Недавние',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore),
          label: 'Каталог',
        ),
        NavigationDestination(
          icon: Icon(Icons.leaderboard),
          label: 'Топ',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu),
          label: 'Меню',
        ),
      ],
    );
  }

  int _getNavigationIndex(NavigationSection section) {
    switch (section) {
      case NavigationSection.home:
        return 0;
      case NavigationSection.recent:
        return 1;
      case NavigationSection.catalog:
        return 2;
      case NavigationSection.top100:
        return 3;
      case NavigationSection.menu:
        return 4;
    }
  }

  NavigationSection _getSectionFromIndex(int index) {
    switch (index) {
      case 0:
        return NavigationSection.home;
      case 1:
        return NavigationSection.recent;
      case 2:
        return NavigationSection.catalog;
      case 3:
        return NavigationSection.top100;
      case 4:
        return NavigationSection.menu;
      default:
        return NavigationSection.home;
    }
  }
}
