import 'package:flutter/material.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/features/report/screens/report_screen.dart';

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

  void _toggle() {
    setState(() => _watchlisted = !_watchlisted);
    widget.onWatchlistToggle();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero image ─────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.background,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                    ),
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
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                      ),
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
              // Report button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportItemScreen(item: item),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                      ),
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
              background: Container(
                color: AppTheme.accentLight,
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('🎁', style: TextStyle(fontSize: 64)),
                        ),
                      )
                    : const Center(
                        child: Text('🎁', style: TextStyle(fontSize: 64)),
                      ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
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
                    '${item.series} • ${item.category}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price + Condition cards
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

                  // Seller card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.accent, AppTheme.accentDark],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              item.sellerName.isNotEmpty
                                  ? item.sellerName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.sellerName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],
                          ),
                        ),
                        Text(
                          _timeAgo(item.postedAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Description
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

                  // Tags
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
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  // Contact
                  if (item.contactLinks.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const _Label('CONTACT SELLER'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.contactLinks
                          .map(
                            (link) => ContactButton(link: link, onTap: () {}),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
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
