import 'package:anigoods/features/add_item/screens/addItem_screen.dart';
import 'package:anigoods/features/notification/screens/notification_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/models/user_model.dart';
import 'package:anigoods/features/auth/screens/login_screen.dart';
import 'package:anigoods/features/auth/screens/register_screen.dart';
import 'package:anigoods/features/auth/screens/verify_email_screen.dart';
import 'package:anigoods/features/home/screens/home_screen.dart';
import 'package:anigoods/features/watchlist/screens/watchlist_screen.dart';
import 'package:anigoods/features/profile/screens/profile_screen.dart';
import 'package:anigoods/features/splash/screens/splash_screen.dart';
import 'package:anigoods/features/landing/screens/landing_screen.dart';
import 'package:anigoods/core/widgets/main_shell.dart';
import 'package:anigoods/features/item_detail/screens/item_detail_screen.dart';
import 'package:anigoods/features/profile/screens/setting_screen.dart';
import 'package:anigoods/features/profile/screens/edit_profile_screen.dart';
import 'package:anigoods/features/profile/screens/my_listing_screen.dart';
import 'dart:async';

// สร้าง Navigator Key เพื่อแยกเลเยอร์ (Root = เต็มจอ, Shell = มีเมนูล่าง)
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

// Enum for route NAMES
enum RouteNames {
  splash,
  landing,
  login,
  register,
  verifyEmail,
  home,
  watchlist,
  profile,
  itemDetail,
  editProfile, 
  notifications,
  addItem,
  settings,
  myListings;

  // Helper getter
  String get path {
    switch (this) {
      case RouteNames.splash:
        return '/';
      case RouteNames.landing:
        return '/landing';
      case RouteNames.login:
        return '/login';
      case RouteNames.register:
        return '/register';
      case RouteNames.verifyEmail:
        return '/verify-email';
      case RouteNames.home:
        return '/home';
      case RouteNames.watchlist:
        return '/watchlist';
      case RouteNames.profile:
        return '/profile';
      case RouteNames.itemDetail:
        return '/item-detail'; 
      case RouteNames.settings:
        return '/settings';  
      case RouteNames.editProfile:
        return '/edit-profile';  
      case RouteNames.notifications:
        return '/notifications';
      case RouteNames.addItem:
        return '/add-item';
      case RouteNames.myListings:
        return '/my-listings';
    }
  }
}

// GoRouter instance with auth redirect logic
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey, 
  initialLocation: RouteNames.splash.path,
  debugLogDiagnostics: true, 
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    final isSplash = state.matchedLocation == RouteNames.splash.path;
    final isLanding = state.matchedLocation == RouteNames.landing.path;
    final isLoggingIn = state.matchedLocation == RouteNames.login.path;
    final isRegistering = state.matchedLocation == RouteNames.register.path;
    final isVerifyingEmail = state.matchedLocation == RouteNames.verifyEmail.path;

    if (isSplash) return null;

    if (!isLoggedIn) {
      final isAuthPage = isLanding || isLoggingIn || isRegistering || isSplash;
      if (!isAuthPage) return RouteNames.login.path;
      return null;
    }

    if (isLoggedIn && (isLanding || isLoggingIn || isRegistering || isVerifyingEmail)) {
      return RouteNames.home.path;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: RouteNames.splash.path,
      name: RouteNames.splash.name,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.landing.path,
      name: RouteNames.landing.name,
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: RouteNames.login.path,
      name: RouteNames.login.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.register.path,
      name: RouteNames.register.name,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RouteNames.verifyEmail.path,
      name: RouteNames.verifyEmail.name,
      builder: (context, state) => const VerifyEmailScreen(),
    ),
    GoRoute(
      path: RouteNames.notifications.path,
      name: RouteNames.notifications.name,
      parentNavigatorKey: _rootNavigatorKey, 
      builder: (context, state) => const NotificationKeywordsScreen(),
    ),
    GoRoute(
      path: RouteNames.addItem.path,
      name: RouteNames.addItem.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddItemScreen(),
    ),
    GoRoute(
      path: RouteNames.itemDetail.path,
      name: RouteNames.itemDetail.name,
      builder: (context, state) {
        // แกะกล่อง Map ที่ส่งมาจากหน้า Home
        final extras = state.extra as Map<String, dynamic>; 
        
        return ItemDetailScreen(
          item: extras['item'] as ItemModel,
          isWatchlisted: extras['isWatchlisted'] as bool,
          onWatchlistToggle: extras['onWatchlistToggle'] as VoidCallback,
        );
      },
    ),
    GoRoute(
      path: RouteNames.myListings.path,
      name: RouteNames.myListings.name,
      parentNavigatorKey: _rootNavigatorKey, 
      builder: (context, state) => const MyListingScreen(),
    ),
    GoRoute(
      path: RouteNames.settings.path,
      name: RouteNames.settings.name,
      parentNavigatorKey: _rootNavigatorKey, 
      builder: (context, state) => const SettingsScreen(),
    ),

    // 👇 ShellRoute: กลุ่มหน้าจอที่มีเมนูด้านล่าง (Bottom Nav Bar)
    ShellRoute(
      navigatorKey: _shellNavigatorKey, 
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: RouteNames.home.path,
          name: RouteNames.home.name,
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const HomeScreen()),
        ),
        // ✅ เอา Watchlist กลับมาไว้ตรงนี้แล้วครับ!
        GoRoute(
          path: RouteNames.watchlist.path,
          name: RouteNames.watchlist.name,
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const WatchlistScreen()),
        ),
        GoRoute(
          path: RouteNames.profile.path,
          name: RouteNames.profile.name,
          pageBuilder: (context, state) =>
              NoTransitionPage(child: const ProfileScreen()),
        ),
      ],
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}