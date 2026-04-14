import 'package:flutter/material.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/constants/app_constants.dart'; 
import 'package:anigoods/core/services/error_handler.dart'; 

class SnackBarHelper {
  SnackBarHelper._();

  /// Show error via ScaffoldMessenger
  static void showError(
    BuildContext context,
    dynamic error, {
    String? contextLabel,
  }) {
    // 1. สั่ง Log Error ด้วย ErrorHandler
    ErrorHandler.logError(contextLabel ?? 'Unknown', error);

    // 2. แปลง Error เป็นข้อความ
    final userMessage = ErrorHandler.getUserMessage(error);

    // 3. โชว์ SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userMessage),
        backgroundColor: AppTheme.danger,
        duration: AppConstants.errorSnackBarDuration, 
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info/warning message
  static void showInfo(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppTheme.accentDark,
        duration: AppConstants.successSnackBarDuration, 
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        duration: AppConstants.successSnackBarDuration, 
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}