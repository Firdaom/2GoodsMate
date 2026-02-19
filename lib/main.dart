import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'firebase_options.dart';


// Firebase initialization — run before app startup
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase — required before using any Firebase services
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );


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


