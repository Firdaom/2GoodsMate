import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/router/app_router.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});
  
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        context.goNamed(RouteNames.home.name);
        break;
      case 1:
        context.goNamed(RouteNames.watchlist.name);
        break;
      case 2:
        context.goNamed(RouteNames.profile.name);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update selected index based on current route
    final location = GoRouterState.of(context).matchedLocation;
    if (location == RouteNames.home.path) {
      _selectedIndex = 0;
    } else if (location == RouteNames.watchlist.path) {
      _selectedIndex = 1;
    } else if (location == RouteNames.profile.path) {
      _selectedIndex = 2;
    }

    return Scaffold(
      body: widget.child,
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
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            backgroundColor: Colors.transparent,
            indicatorColor: AppTheme.accentLight,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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