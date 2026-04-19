import 'package:anigoods/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:anigoods/features/cart/providers/cart_provider.dart'; 



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

// SHARED UI COMPONENTS (ใช้ได้ทุกหน้า)
// ══════════════════════════════════════════════════════════

class EmptyState extends StatelessWidget {
  final IconData icon; 
  final String title;
  final String subtitle;

  const EmptyState({
    super.key,
    required this.icon, 
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon, 
          size: 64, 
          color: AppTheme.border, 
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary, 
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


// ─── Cart Icon Button 
class CartIconButton extends ConsumerWidget { 
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { 
    final cartItems = ref.watch(cartProvider);
    final cartCount = cartItems.length;

    return IconButton(
      onPressed: () => context.push(RouteNames.cart.path), 
      icon: Stack(
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
      ),
    );
  }
}