import 'package:flutter/material.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/constants/app_constants.dart'; 
import 'package:anigoods/core/services/error_handler.dart'; 

class SnackBarHelper {
  SnackBarHelper._();

  // ล้าง SnackBar ที่ค้างอยู่
  static void _clearPending(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Show error
  static void showError(
    BuildContext context,
    dynamic error, {
    String? contextLabel,
  }) {
    ErrorHandler.logError(contextLabel ?? 'Unknown', error);
    final userMessage = ErrorHandler.getUserMessage(error);

    _clearPending(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userMessage, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.danger,
        duration: AppConstants.errorSnackBarDuration, 
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white70,
          onPressed: () => _clearPending(context),
        ),
      ),
    );
  }

  /// Show info/warning
  static void showInfo(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    _clearPending(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppTheme.accentDark,
        duration: AppConstants.successSnackBarDuration, 
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success
  static void showSuccess(BuildContext context, String message) {
    _clearPending(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        duration: AppConstants.successSnackBarDuration, 
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show Custom Add to Cart Success
  static void showAddToCartSuccess(BuildContext context, String itemName) {
    _clearPending(context); 
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.textPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 90, left: 20, right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(milliseconds: 1500),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Added to Cart',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    itemName, 
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}