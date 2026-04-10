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
  
  // Initialize Firebase — required before using any Firebase services
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // เช็คว่ามีผู้ใช้ล็อกอินค้างไว้ในเครื่องหรือไม่
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // ถ้ามีคนล็อกอินอยู่ ให้โหลดของในตะกร้าจาก Firebase มารอไว้เลย!
      await CartService().loadCart();
    }


  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(
    // ProviderScope is required at the root — it wires up the entire Riverpod system
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
      
      // Apply AppTheme to MaterialApp
      theme: AppTheme.theme,

      // Hook GoRouter into MaterialApp
      routerConfig: appRouter,
    );
  }
}