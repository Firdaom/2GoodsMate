import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});


  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(top: BorderSide(color: AppTheme.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            height: 60,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            backgroundColor: Colors.transparent,
            indicatorColor: AppTheme.accentLight,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppTheme.textMuted),
                selectedIcon: Icon(Icons.home, color: AppTheme.accent),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border, color: AppTheme.textMuted),
                selectedIcon: Icon(Icons.favorite, color: AppTheme.accent),
                label: 'Watchlist',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: AppTheme.textMuted),
                selectedIcon: Icon(Icons.person, color: AppTheme.accent),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}