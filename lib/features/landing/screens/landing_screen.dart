import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 8),
                  color: const Color(0xFF131313),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopNavBar(isMobile: _isMobile(context)),
                      const SizedBox(height: 16),
                      _HeroSection(isMobile: _isMobile(context)),
                      SizedBox(height: _isMobile(context) ? 40 : 64),
                      _FeatureSection(isMobile: _isMobile(context)),
                      _FinalCtaSection(isMobile: _isMobile(context)),
                      const SizedBox(height: 48),
                      _FooterSection(isMobile: _isMobile(context)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  final bool isMobile;
  const _TopNavBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
      color: const Color(0xB2131313),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1B1B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/2goodsMate_logo.png', 
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF0051C3),
                      child: const Icon(Icons.toys, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '2GoodsMate',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 32),
                const _NavLink(text: 'Explore', active: true),
                const SizedBox(width: 16),
                const _NavLink(text: 'About'),
              ],
            ],
          ),
          Row(
            children: [
              if (!isMobile) ...[
                GestureDetector(
                  onTap: () => context.go('/login'), // 👈 Sign in ยังคงไปที่หน้า Login ปกติ
                  child: const _NavLink(text: 'Sign in'),
                ),
                const SizedBox(width: 16),
              ],
              GestureDetector(
                // 👇 1. ปุ่ม Sign Up ชี้ไปที่ /register
                onTap: () => context.go('/register'), 
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0051C3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBECEFF),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String text;
  final bool active;

  const _NavLink({required this.text, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: active
            ? const Border(bottom: BorderSide(color: Color(0xFFB1C5FF), width: 2))
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? const Color(0xFFB1C5FF) : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isMobile;
  const _HeroSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 24 : 48,
      ),
      child: isMobile
          ? Column(
              children: [
                _buildHeroText(context),
                const SizedBox(height: 32),
                const _ProductPreviewCard(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: _buildHeroText(context)),
                const SizedBox(width: 40),
                const Expanded(flex: 4, child: _ProductPreviewCard()),
              ],
            ),
    );
  }

  Widget _buildHeroText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COLLECTIBLES MARKETPLACE',
          style: TextStyle(
            fontFamily: 'Space Grotesk',
            fontSize: 10,
            letterSpacing: 2.0,
            color: Color(0xFFB1C5FF),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Find Anime \nCollectibles You \nLove',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isMobile ? 36 : 56,
            height: 1.1,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Search, track, and collect figures, cards, and more second hand anime items with ease.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.5,
            color: Color(0xFFC3C6D6),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            GestureDetector(
              // 👇 2. ปุ่ม Get started ชี้ไปที่ /register
              onTap: () => context.go('/register'), 
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB1C5FF),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1AB1C5FF),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Get started',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF002C71),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0x4D434653)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Explore Items',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProductPreviewCard extends StatelessWidget {
  const _ProductPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 300), 
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.width < 800 ? 240 : 340,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 14, left: 14, right: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/tobio.webp',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.white54, size: 32),
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tobio Kageyama',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Haikyu!! • Figure',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFFC3C6D6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF353534),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: const Color(0x0DFFFFFF)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.favorite_border, color: Color(0xFFB1C5FF), size: 16),
                        SizedBox(width: 6),
                        Text(
                          '1.2k wishlists',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFFC3C6D6),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '฿1,100',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  final bool isMobile;
  const _FeatureSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 40 : 64,
      ),
      color: const Color(0xFF1C1B1B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const Text(
                  'FEATURES',
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: Color(0xFFB1C5FF),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (isMobile)
            Column(
              children: const [
                _FeatureCard(
                  icon: Icons.rocket_launch, 
                  title: 'Track Latest Drops', 
                  body: 'Stay updated with new figures, cards and collectibles.'
                ),
                SizedBox(height: 16),
                _FeatureCard(
                  icon: Icons.favorite, 
                  title: 'Build Your Watchlist', 
                  body: 'Save items you love and get notified instantly.'
                ),
                SizedBox(height: 16),
                _FeatureCard(
                  icon: Icons.notifications_active, 
                  title: 'Smart Notifications', 
                  body: 'Custom keywords to catch exactly what you want.'
                ),
              ],
            )
          else
            Row(
              children: const [
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.rocket_launch, 
                    title: 'Track Latest Drops', 
                    body: 'Stay updated with new figures, cards and collectibles.'
                  )
                ),
                SizedBox(width: 24),
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.favorite, 
                    title: 'Build Your Watchlist', 
                    body: 'Save items you love and get notified instantly.'
                  )
                ),
                SizedBox(width: 24),
                Expanded(
                  child: _FeatureCard(
                    icon: Icons.notifications_active, 
                    title: 'Smart Notifications', 
                    body: 'Custom keywords to catch exactly what you want.'
                  )
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _FeatureCard({required this.icon,required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x1A0051C3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: Color(0xFFB1C5FF), size: 20),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.5,
              color: Color(0xFFC3C6D6),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalCtaSection extends StatelessWidget {
  final bool isMobile;
  const _FinalCtaSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 48 : 80,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x140051C3), Color(0x00131313)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Ready to expand your archive?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const Text(
              'Join 2GoodsMate today and start building your dream collection with confidence.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                height: 1.5,
                color: Color(0xFFC3C6D6),
              ),
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            // 👇 3. ปุ่ม Start collecting now ชี้ไปที่ /register
            onTap: () => context.go('/register'), 
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFB1C5FF),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33B1C5FF),
                      blurRadius: 30,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Text(
                  'Start collecting now',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF002C71),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  final bool isMobile;
  const _FooterSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: isMobile ? 24 : 40,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        border: Border(top: BorderSide(color: Color(0x0DFFFFFF))),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '2GoodsMate',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'CRAFTED FOR COLLECTORS',
                  style: TextStyle(fontFamily: 'Liberation Mono', fontSize: 10, letterSpacing: 1, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: const [
                    _FooterLink(text: 'Explore'),
                    _FooterLink(text: 'ABOUT'),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '2GoodsMate',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'CRAFTED FOR COLLECTORS',
                      style: TextStyle(fontFamily: 'Liberation Mono', fontSize: 10, letterSpacing: 1, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    SizedBox(width: 32),
                    _FooterLink(text: 'EXPLORE'),
                    SizedBox(width: 32),
                    _FooterLink(text: 'ABOUT'),
                  ],
                ),
              ],
            ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;

  const _FooterLink({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Liberation Mono',
        fontSize: 10,
        letterSpacing: 1,
        color: Color(0xFF6B7280),
      ),
    );
  }
}