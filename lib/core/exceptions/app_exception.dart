/// ════════════════════════════════════════════════════════
/// APP EXCEPTION
/// ────────────────────────────────────────────────────────
/// Custom exception for consistent error handling across the app
/// ════════════════════════════════════════════════════════

class AppException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;

  AppException({
    required this.message,
    required this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}
