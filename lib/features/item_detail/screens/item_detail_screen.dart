import 'package:anigoods/core/services/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/features/report/screens/report_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:anigoods/core/router/app_router.dart';

class ItemDetailScreen extends StatefulWidget {
  final ItemModel item;
  final bool isWatchlisted;
  final VoidCallback onWatchlistToggle;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.isWatchlisted,
    required this.onWatchlistToggle,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late bool _watchlisted;

  @override
  void initState() {
    super.initState();
    _watchlisted = widget.isWatchlisted;
  }

  void dispose() {
    //ทันทีที่หน้านี้ถูกปิด (ทำลาย) ให้เคลียร์ SnackBar ทิ้งด้วย
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    super.dispose();
  }

  void _toggle() {
    setState(() => _watchlisted = !_watchlisted);
    widget.onWatchlistToggle();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      body: CustomScrollView(
        slivers: [_buildHeroImage(item), _buildItemDetails(item)],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          border: const Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: SafeArea(
          child: Column(
            // 🔥 2. บังคับให้ความสูงของล่างสุดหดตัวลงมาพอดีกับปุ่ม (ห้ามขยายเต็มจอ)
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // 🛒 ปุ่ม Add to Cart
                  Expanded(
                    child: SizedBox(
                      height: 52, 
                      child: OutlinedButton(
                        onPressed: () {
                          CartService().addToCart(item);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.title} added to cart!'),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'View Cart',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  context.push('/cart'); 
                                },
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          // เอา padding เดิมออกได้เลยครับ เพราะเราบังคับความสูงด้วย SizedBox แทนแล้ว
                          side: const BorderSide(color: AppTheme.accent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Icon(Icons.add_shopping_cart, color: AppTheme.accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // ปุ่ม Order Now
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52, 
                      child: PrimaryButton(
                        label: 'Order Now',
                        onTap: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar(); 
                          context.push(RouteNames.order.path, extra: item);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ส่วนที่ 1: ส่วนรูปภาพด้านบน (SliverAppBar)
  // ══════════════════════════════════════════════════════════
  Widget _buildHeroImage(ItemModel item) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppTheme.background,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.pop(context);
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppTheme.textPrimary,
            size: 20,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _toggle,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              _watchlisted ? Icons.favorite : Icons.favorite_border,
              color: _watchlisted ? AppTheme.heart : AppTheme.textMuted,
              size: 20,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReportItemScreen(item: item)),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.flag_outlined,
              color: AppTheme.textMuted,
              size: 20,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: ImageCarousel(imageUrls: item.imageUrls, height: 280),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ส่วนที่ 2: ส่วนรายละเอียดด้านล่าง (Content)
  // ══════════════════════════════════════════════════════════
  Widget _buildItemDetails(ItemModel item) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${item.series} • ${item.category} • Posted ${_timeAgo(item.postedAt)}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👤', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(
                        item.sellerName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.sellerVerified) ...[
                        const SizedBox(width: 5),
                        const VerifiedBadge(size: 14),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    label: 'PRICE',
                    child: Text(
                      '฿${_fmt(item.price)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent,
                      ),
                    ),
                    accent: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoCard(
                    label: 'CONDITION',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: conditionColor(item.condition),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              item.condition,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        RarityBadge(rarity: item.rarity),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _Label('DESCRIPTION'),
            const SizedBox(height: 6),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.accent.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double price) => price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final Widget child;
  final bool accent;
  const _InfoCard({
    required this.label,
    required this.child,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: accent ? AppTheme.accentLight : AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: accent ? AppTheme.accent.withOpacity(0.2) : AppTheme.border,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
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
