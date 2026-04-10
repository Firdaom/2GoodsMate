import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:anigoods/core/services/cart_service.dart';
import 'firebase_options.dart';


// Firebase initialization — run before app startup
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      CartService().loadCart(); 
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(
    const ProviderScope(
      child: AniGoodsApp(),
    ),
  );
}

class AniGoodsApp extends StatelessWidget {
  const AniGoodsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '2GoodsMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme.copyWith(
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      routerConfig: appRouter,
      builder: (context, child) {
        return ScaffoldMessenger(
          child: child!,
        );
      },
    );
  }
}