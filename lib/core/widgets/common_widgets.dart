import 'package:anigoods/core/router/app_router.dart';
import 'package:anigoods/core/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

// ─── Image Carousel ───────────────────────────────────────
class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final double borderRadius;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 280,
    this.borderRadius = 0,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // เรียกใช้ widget.imageUrls
  void _openFullScreen(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          imageUrls: widget.imageUrls,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. ถ้าไม่มีรูปเลย แสดง fallback
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppTheme.accentLight,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: const Center(child: Text('🎁', style: TextStyle(fontSize: 64))),
      );
    }

    // 2. ถ้ามีรูปเดียว แสดงรูปแบบธรรมดา ไม่มี carousel
    if (widget.imageUrls.length == 1) {
      return GestureDetector(
        onTap: () => _openFullScreen(context, 0), // เปิดหน้าเต็มจอ
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Container(
            height: widget.height,
            color: AppTheme.accentLight,
            alignment: Alignment.center,
            child: Image.network(
              widget.imageUrls[0],
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (_, __, ___) => const Center(
                child: Text('🎁', style: TextStyle(fontSize: 64)),
              ),
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.accent,
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    // 3. ถ้ามีหลายรูป แสดง carousel พร้อม indicator
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            height: widget.height,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(), // เลื่อนหนึบขึ้น
              pageSnapping: true,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openFullScreen(context, index), // กดซูมรูป
                  child: Container(
                    color: AppTheme.accentLight,
                    alignment: Alignment.center,
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('🎁', style: TextStyle(fontSize: 64)),
                      ),
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.accent,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Dot Indicator ด้านล่าง
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.imageUrls.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Item Image ───────────────────────────────────────────
class ItemImage extends StatelessWidget {
  final List<String> imageUrls;
  final double size;
  final double radius;

  const ItemImage({
    super.key,
    required this.imageUrls,
    this.size = 72,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: AppTheme.accentLight,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImageFallback(),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.accent,
                        ),
                      ),
              )
            : const _ImageFallback(),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('🎁', style: TextStyle(fontSize: 28)));
}

// ─── Rarity Badge ─────────────────────────────────────────
class RarityBadge extends StatelessWidget {
  final String rarity;
  const RarityBadge({super.key, required this.rarity});

  @override
  Widget build(BuildContext context) {
    final color = rarityColor(rarity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        rarity.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Verified Badge ───────────────────────────────────────
class VerifiedBadge extends StatelessWidget {
  final double size;
  const VerifiedBadge({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppTheme.verified,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(Icons.check, color: Colors.white, size: size * 0.7),
      ),
    );
  }
}

// ─── Condition + Rarity row ───────────────────────────────
class ConditionWithRarity extends StatelessWidget {
  final String condition;
  final String rarity;
  const ConditionWithRarity({
    super.key,
    required this.condition,
    required this.rarity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: conditionColor(condition),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          condition,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 6),
        const Text(
          '•',
          style: TextStyle(fontSize: 9, color: AppTheme.textMuted),
        ),
        const SizedBox(width: 6),
        RarityBadge(rarity: rarity),
      ],
    );
  }
}

// ─── Item Card ────────────────────────────────────────────
class ItemCard extends StatelessWidget {
  final ItemModel item;
  final bool isWatchlisted;
  final VoidCallback onTap;
  final VoidCallback onWatchlistToggle;

  const ItemCard({
    super.key,
    required this.item,
    required this.isWatchlisted,
    required this.onTap,
    required this.onWatchlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ItemImage(imageUrls: item.imageUrls),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.series} • ${item.category}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Seller: ${item.sellerName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      if (item.sellerVerified) ...[
                        const SizedBox(width: 4),
                        const VerifiedBadge(size: 12),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '฿${_formatPrice(item.price)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ConditionWithRarity(
                            condition: item.condition,
                            rarity: item.rarity,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onWatchlistToggle,
                        child: Icon(
                          isWatchlisted
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isWatchlisted
                              ? AppTheme.heart
                              : AppTheme.textMuted,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) => price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ─── Settings Row ─────────────────────────────────────────
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: danger
                    ? AppTheme.danger.withOpacity(0.1)
                    : AppTheme.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18,
                  color: danger ? AppTheme.danger : AppTheme.accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: danger ? AppTheme.danger : AppTheme.textPrimary,
                ),
              ),
            ),
            if (!danger)
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textMuted,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Chip ────────────────────────────────────────
class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accent : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Contact Button ───────────────────────────────────────
class ContactButton extends StatelessWidget {
  final ContactLink link;
  final VoidCallback onTap;

  const ContactButton({super.key, required this.link, required this.onTap});

  static const _platforms = {
    'facebook': {'emoji': '📘', 'name': 'Facebook'},
    'twitter': {'emoji': '🐦', 'name': 'X (Twitter)'},
    'instagram': {'emoji': '📸', 'name': 'Instagram'},
    'line': {'emoji': '💬', 'name': 'LINE'},
    'shopee': {'emoji': '🛒', 'name': 'Shopee'},
    'lazada': {'emoji': '🛍️', 'name': 'Lazada'},
  };

  @override
  Widget build(BuildContext context) {
    final platformInfo =
        _platforms[link.platform] ?? {'emoji': '🔗', 'name': link.platform};
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(platformInfo['emoji']!, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              platformInfo['name']!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────shared buttons──────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;

  const PrimaryButton({required this.label, this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentDark],
                )
              : null,
          color: enabled ? null : AppTheme.border,
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: enabled ? Colors.white : AppTheme.textMuted,
                  ),
                ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// SHARED UI COMPONENTS (ใช้ได้ทุกหน้า)
// ══════════════════════════════════════════════════════════

class EmptyState extends StatelessWidget {
  final IconData icon; // เปลี่ยนจาก String emoji เป็น IconData
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon, // เปลี่ยนชื่อให้ตรงกัน
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // เปลี่ยนจาก Text เป็น Icon widget
        Icon(
          icon, 
          size: 64, 
          color: AppTheme.border, // ใช้สีเทาๆ ให้ดูเป็นหน้าว่างๆ
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary, // ปรับสีให้เข้มขึ้นนิดนึง
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
      ],
    ),
  );
}

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppTheme.textMuted,
      letterSpacing: 0.8,
    ),
  );
}

// ─── Full Screen Image Viewer ─────────────────────────────
class FullScreenImageViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // พื้นหลังสีดำดูโปร
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        physics: const BouncingScrollPhysics(), // เลื่อนแล้วมีเด้งๆ ขอบจอ
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            // ซูมรูปได้
            panEnabled: true,
            minScale: 1.0, // ย่อสุดได้เท่าขนาดปกติ
            maxScale: 4.0, // ซูมเข้าไปได้สูงสุด 4 เท่า
            child: Center(
              child: Image.network(imageUrls[index], fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}

// ─── Cart Icon Button (With Badge) ────────────────────────
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.push('/cart'),
      // ใช้ ListenableBuilder ครอบไว้ ดักฟัง CartService แบบ Real-time
      icon: ListenableBuilder(
        listenable: CartService(),
        builder: (context, child) {
          final cartCount = CartService().items.length;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: AppTheme.textPrimary,
                size: 24,
              ),
              if (cartCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      cartCount > 99 ? '99+' : '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
