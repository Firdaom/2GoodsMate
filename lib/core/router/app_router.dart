import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/features/auth/screens/login_screen.dart';
import 'package:anigoods/features/auth/screens/register_screen.dart';
import 'package:anigoods/features/auth/screens/verify_email_screen.dart';
import 'package:anigoods/features/home/screens/home_screen.dart';
import 'package:anigoods/features/watchlist/screens/watchlist_screen.dart';
import 'package:anigoods/features/profile/screens/profile_screen.dart';
import 'package:anigoods/features/splash/screens/splash_screen.dart';
import 'package:anigoods/features/landing/screens/landing_screen.dart';
import 'package:anigoods/core/widgets/main_shell.dart';

// Enum for route NAMES — used with context.goNamed() / context.pushNamed()
enum RouteNames {
  splash,
  landing,
  login,
  register,
  verifyEmail,
  home,
  watchlist,
  profile;

  // Helper getter — converts enum value to its path string
  // e.g. RouteNames.home.path → '/home'
  // GoRouter requires a String for 'path', this keeps path & name in sync
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
    }
  }
}

// GoRouter instance with auth redirect logic
final appRouter = GoRouter(
  initialLocation: RouteNames.splash.path,
  debugLogDiagnostics: true, // Remove in production
  redirect: (context, state) {
    // Check if user is logged in
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    final isSplash = state.matchedLocation == RouteNames.splash.path;
    final isLanding = state.matchedLocation == RouteNames.landing.path;
    final isLoggingIn = state.matchedLocation == RouteNames.login.path;
    final isRegistering = state.matchedLocation == RouteNames.register.path;
    final isVerifyingEmail = state.matchedLocation == RouteNames.verifyEmail.path;

    // Allow splash screen for everyone
    if (isSplash) {
      return null;
    }

    // If not logged in, allow landing, login & register pages
    if (!isLoggedIn) {
      // Allow access to landing, login and register pages
      if (isLanding || isLoggingIn || isRegistering) {
        return null;
      }
      // Redirect to landing for any other page
      return RouteNames.landing.path;
    }

    // ✅ Email verification disabled temporarily
    // If logged in but email not verified, show verify email screen
    // if (isLoggedIn && !isEmailVerified) {
    //   // If not already on verify page, redirect to it
    //   if (!isVerifyingEmail) {
    //     return RouteNames.verifyEmail.path;
    //   }
    //   // If already on verify page, stay there
    //   return null;
    // }

    // If logged in and still on auth pages, redirect to home
    if (isLoggedIn && (isLanding || isLoggingIn || isRegistering || isVerifyingEmail)) {
      return RouteNames.home.path;
    }

    // No redirect needed
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
    // ShellRoute wraps home/watchlist/profile with bottom navigation bar
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: RouteNames.home.path,
          name: RouteNames.home.name,
          pageBuilder: (context, state) => NoTransitionPage(
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.watchlist.path,
          name: RouteNames.watchlist.name,
          pageBuilder: (context, state) => NoTransitionPage(
            child: const WatchlistScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.profile.path,
          name: RouteNames.profile.name,
          pageBuilder: (context, state) => NoTransitionPage(
            child: const ProfileScreen(),
          ),
        ),
      ],
    ),
  ],
);