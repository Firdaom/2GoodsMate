import 'package:anigoods/features/home/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';

// 1. เปลี่ยนจาก StatelessWidget เป็น ConsumerWidget
class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onDestinationSelected: (index) {
              if (index == navigationShell.currentIndex) {
                if (index == 0) {
                  ref.read(homeScrollTriggerProvider.notifier).state++;
                }
              } else {

                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              }
            },
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