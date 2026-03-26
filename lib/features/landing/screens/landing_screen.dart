import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A), // Navy blue dark background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Logo
                    Image.asset(
                      'assets/logo_no_bg.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),

                    // Main Title
                    const Text(
                      'Track Your Dream\nCollectibles',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Subtitle
                    Text(
                      'Discover and track figures, cards, manga & collectibles\nwith real-time updates and smart alerts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Get Started Button (centered, fixed width)
                    Center(
                      child: Container(
                        width: 220,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => context.go('/register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),

              // Features Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Features
                    _buildFeature(
                      icon: Icons.shopping_bag_outlined,
                      iconColor: const Color(0xFF6366F1),
                      title: 'Track Latest Drops',
                      description: 'Stay updated with new figures, cards & collectibles',
                    ),
                    const SizedBox(height: 20),
                    _buildFeature(
                      icon: Icons.bookmark_border,
                      iconColor: const Color(0xFFEC4899),
                      title: 'Build Your Watchlist',
                      description: 'Save items you love and get notified instantly',
                    ),
                    const SizedBox(height: 20),
                    _buildFeature(
                      icon: Icons.notifications_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Smart Alerts',
                      description: 'Custom keywords to catch exactly what you want',
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3F54), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

