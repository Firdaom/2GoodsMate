import 'package:anigoods/features/auth/screens/privacy_screen.dart';
import 'package:anigoods/features/auth/screens/terms_screen.dart';
import 'package:anigoods/features/chat/screens/chat_list_screen.dart';
import 'package:anigoods/features/chat/screens/chat_room_screen.dart';
import 'package:anigoods/features/notification/screens/notification_screen.dart';
import 'package:anigoods/features/profile/screens/become_seller_screen.dart';
import 'package:anigoods/features/profile/screens/edit_profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:anigoods/models/item_model.dart';
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
import 'package:anigoods/features/order/screens/order_screen.dart';
import 'package:anigoods/features/order/screens/order_status_screen.dart';
import 'package:anigoods/features/order/screens/purchase_history_screen.dart';
import 'package:anigoods/features/cart/screens/cart_screen.dart';
import 'dart:async';

// สร้าง Navigator Key เพื่อแยกเลเยอร์ (Root = เต็มจอ, Shell = มีเมนูล่าง)
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

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
  settings,
  order,
  orderStatus,
  purchaseHistory,
  chatroom,
  chatlist,
  cart,
  terms,
  privacy,
  becomeSeller;

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
        return '/item-detail/:itemId';
      case RouteNames.settings:
        return '/settings';
      case RouteNames.editProfile:
        return '/edit-profile';
      case RouteNames.notifications:
        return '/notifications';
      case RouteNames.order:
        return '/orders';
      case RouteNames.orderStatus:
        return '/order-status';
      case RouteNames.purchaseHistory:
        return '/purchase-history';
      case RouteNames.chatroom:
        return '/chatroom';
      case RouteNames.chatlist:
        return '/chatlist';
      case RouteNames.cart:
        return '/cart';
      case RouteNames.terms:
        return '/terms';
      case RouteNames.privacy:
        return '/privacy';
      case RouteNames.becomeSeller:
        return '/become-seller';

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

    final isTermsOrPrivacy = state.matchedLocation == RouteNames.terms.path || 
                             state.matchedLocation == RouteNames.privacy.path;

    if (isSplash) return null;

    if (!isLoggedIn) {
      final isAuthPage = isLanding || isLoggingIn || isRegistering || isSplash || isTermsOrPrivacy;
      if (!isAuthPage) return RouteNames.login.path;
      return null;
    }

    if (isLoggedIn &&
        (isLanding || isLoggingIn || isRegistering || isVerifyingEmail)) {
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
      path: '/item-detail/:itemId', 
      name: RouteNames.itemDetail.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final itemId = state.pathParameters['itemId']!;
        return ItemDetailScreen(itemId: itemId);
      },
    ),
    GoRoute(
      path: RouteNames.settings.path,
      name: RouteNames.settings.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
  path: RouteNames.editProfile.path,
  name: RouteNames.editProfile.name,
  parentNavigatorKey: _rootNavigatorKey,
  builder: (context, state) => const EditProfileScreen(), 
    ),
    GoRoute(
      path: RouteNames.order.path,
      name: RouteNames.order.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        // 1. แกะกล่อง Map เพื่อแยกรับ 2 ค่า (items และ isFromCart)
        final extras = state.extra as Map<String, dynamic>;
        final items = extras['items'] as List<ItemModel>;
        final isFromCart = extras['isFromCart'] as bool? ?? false;

        return OrderScreen(items: items, isFromCart: isFromCart);
      },
    ),
    GoRoute(
      path: RouteNames.orderStatus.path,
      name: RouteNames.orderStatus.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final String orderId = state.extra as String;
        return OrderStatusScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: RouteNames.purchaseHistory.path,
      name: RouteNames.purchaseHistory.name,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final initialIndex = (state.extra as int?) ?? 0;
        return PurchaseHistoryScreen(initialIndex: initialIndex);
      },
    ),
    GoRoute(
      path: RouteNames.chatroom.path,
      name: RouteNames.chatroom.name,
      builder: (context, state) {
        final sellerName = state.extra as String? ?? 'Seller';
        return ChatRoomScreen(sellerName: sellerName);
      },
    ),
    GoRoute(
      path: RouteNames.chatlist.path,
      name: RouteNames.chatlist.name,
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: RouteNames.cart.path,
      name: RouteNames.cart.name,
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: RouteNames.terms.path,
      name: RouteNames.terms.name,
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: RouteNames.privacy.path,
      name: RouteNames.privacy.name,
      builder: (context, state) => const PrivacyScreen(),
    ),
    GoRoute(
      path: RouteNames.becomeSeller.path,
      name: RouteNames.becomeSeller.name,
      builder: (context, state) => const BecomeSellerScreen(),
    ),

   // ShellRoute: กลุ่มหน้าจอที่มีเมนูด้านล่าง (Bottom Nav Bar)
   StatefulShellRoute.indexedStack(
     builder: (context, state, navigationShell) {
       return MainShell(navigationShell: navigationShell);
     },
     branches: [
       StatefulShellBranch(
         routes: [
           GoRoute(
             path: RouteNames.home.path,
             name: RouteNames.home.name,
             pageBuilder: (context, state) =>
                 const NoTransitionPage(child: HomeScreen()),
           ),
         ],
       ),
       StatefulShellBranch(
         routes: [
           GoRoute(
             path: RouteNames.watchlist.path,
             name: RouteNames.watchlist.name,
             pageBuilder: (context, state) =>
                 const NoTransitionPage(child: WatchlistScreen()),
           ),
         ],
       ),
       StatefulShellBranch(
         routes: [
           GoRoute(
             path: RouteNames.profile.path,
             name: RouteNames.profile.name,
             pageBuilder: (context, state) =>
                 const NoTransitionPage(child: ProfileScreen()),
           ),
         ],
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
