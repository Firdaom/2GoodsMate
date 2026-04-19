
import 'package:flutter/material.dart';
import 'package:anigoods/core/theme/app_theme.dart';


// ─── Widget _StatusStep ──────────────────────────────────────────
class StatusStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final bool isActive;
  final bool isPending;
  final bool isLast;
  final bool isError;

  const StatusStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isActive = false,
    this.isPending = false,
    required this.isLast,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    // กำหนดสีตามสถานะ
    final Color iconColor = isError
        ? AppTheme.danger
        : (isActive
              ? AppTheme.accent
              : (isPending ? AppTheme.border : AppTheme.success));
    final Color bgColor = isError
        ? AppTheme.danger.withOpacity(0.1)
        : (isActive
              ? AppTheme.accentLight
              : (isPending
                    ? Colors.transparent
                    : AppTheme.success.withOpacity(0.1)));
    final Color lineColor = isPending ? AppTheme.border : AppTheme.success;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: isPending ? Border.all(color: AppTheme.border) : null,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: lineColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: (isActive || isError)
                              ? FontWeight.bold
                              : FontWeight.w600,
                          fontSize: 15,
                          color: isError
                              ? AppTheme.danger
                              : (isPending
                                    ? AppTheme.textMuted
                                    : AppTheme.textPrimary),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: isError
                              ? AppTheme.danger
                              : (isPending
                                    ? AppTheme.border
                                    : AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isPending
                          ? AppTheme.border
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
