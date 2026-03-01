import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/features/auth/screens/login_screen.dart';
import 'package:anigoods/features/auth/screens/register_screen.dart';
import 'package:anigoods/features/auth/screens/verify_email_screen.dart';
import 'package:anigoods/features/home/screens/home_screen.dart';
import 'package:anigoods/features/watchlist/screens/watchlist_screen.dart';
import 'package:anigoods/features/profile/screens/profile_screen.dart';
import 'package:anigoods/core/widgets/main_shell.dart';

// Enum for route NAMES — used with context.goNamed() / context.pushNamed()
enum RouteNames {
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
      case RouteNames.login:
        return '/';
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
  initialLocation: RouteNames.login.path,
  debugLogDiagnostics: true, // Remove in production
  redirect: (context, state) {
    // Check if user is logged in
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    
    final isLoggingIn = state.matchedLocation == RouteNames.login.path;
    final isRegistering = state.matchedLocation == RouteNames.register.path;
    final isVerifyingEmail = state.matchedLocation == RouteNames.verifyEmail.path;

    // If not logged in, allow login & register pages
    if (!isLoggedIn) {
      // Allow access to login and register pages
      if (isLoggingIn || isRegistering) {
        return null;
      }
      // Redirect to login for any other page
      return RouteNames.login.path;
    }

    // If logged in but email not verified, show verify email screen
    if (isLoggedIn && !isEmailVerified) {
      // If not already on verify page, redirect to it
      if (!isVerifyingEmail) {
        return RouteNames.verifyEmail.path;
      }
      // If already on verify page, stay there
      return null;
    }

    // If logged in, email verified, and still on auth pages, redirect to home
    if (isLoggedIn && isEmailVerified && (isLoggingIn || isRegistering || isVerifyingEmail)) {
      return RouteNames.home.path;
    }

    // No redirect needed
    return null;
  },
  routes: [
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