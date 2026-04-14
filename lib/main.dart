import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:anigoods/features/cart/providers/cart_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('🔥 Firebase init error: $e');
  }

  runApp(
    const ProviderScope(
      child: AniGoodsApp(),
    ),
  );
}

class AniGoodsApp extends ConsumerStatefulWidget { 
  const AniGoodsApp({super.key});

  @override
  ConsumerState<AniGoodsApp> createState() => _AniGoodsAppState();
}

class _AniGoodsAppState extends ConsumerState<AniGoodsApp> {
  @override
  void initState() {
    super.initState();
    // 🛒 โหลดตะกร้าสินค้าทันทีที่แอปเริ่มทำงาน (ถ้า Login อยู่แล้ว)
    _initializeCart();
  }

  void _initializeCart() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      Future.microtask(() => 
        ref.read(cartProvider.notifier).loadCart()
      );
    }
  }

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
    );
  }
}