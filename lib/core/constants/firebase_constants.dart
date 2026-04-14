/// Firestore collection names
class FirebaseCollections {
  FirebaseCollections._(); // Private constructor to prevent instantiation
  
  static const String users = 'users';
  static const String items = 'items';
  static const String reports = 'reports';
  static const String orders = 'orders';
}

/// Firestore field names for User collection
class UserFields {
  UserFields._(); // Private constructor to prevent instantiation

  static const String name = 'name';
  static const String username = 'username';
  static const String email = 'email';
  static const String profileImageUrl = 'profileImageUrl';
  static const String watchlist = 'watchlist';
  static const String notificationKeywords = 'notificationKeywords';
  static const String isVerified = 'isVerified';
  static const String createdAt = 'createdAt';
  static const String cart = 'cart';
}

/// Firestore field names for Item collection
class ItemFields {
  ItemFields._(); // Private constructor to prevent instantiation

  static const String title = 'title';
  static const String series = 'series';
  static const String category = 'category';
  static const String rarity = 'rarity';
  static const String price = 'price';
  static const String condition = 'condition';
  static const String imageUrls = 'imageUrls';
  static const String sellerId = 'sellerId';
  static const String sellerName = 'sellerName';
  static const String sellerVerified = 'sellerVerified';
  static const String description = 'description';
  static const String tags = 'tags';
  static const String postedAt = 'postedAt';
  static const String moderationStatus = 'moderationStatus';
  static const String qualityScore = 'qualityScore';
  static const String reportCount = 'reportCount';
  static const String flaggedAt = 'flaggedAt';
}

class OrderFields {
  OrderFields._();
  static const String itemId = 'itemId';
  static const String buyerId = 'buyerId';
  static const String sellerId = 'sellerId';
  static const String status = 'status';
  static const String totalPrice = 'totalPrice';
  static const String shippingAddress = 'shippingAddress';
  static const String createdAt = 'createdAt';
}

/// Firebase Auth error codes
class AuthErrorCodes {
  AuthErrorCodes._(); // Private constructor to prevent instantiation

  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String invalidCredential = 'invalid-credential';
  static const String invalidEmail = 'invalid-email';
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String weakPassword = 'weak-password';
  static const String tooManyRequests = 'too-many-requests';
  static const String userDisabled = 'user-disabled';
  static const String operationNotAllowed = 'operation-not-allowed';
  static const String networkRequestFailed = 'network-request-failed';
}

/// Firebase Storage paths
class StoragePaths {
  StoragePaths._(); // Private constructor to prevent instantiation

  static const String itemImages = 'items';
  static const String profileImages = 'profile_images';
}

/// Firestore field names for Report collection
class ReportFields {
  ReportFields._(); // Private constructor to prevent instantiation
  
  static const String itemId = 'itemId';
  static const String itemTitle = 'itemTitle';
  static const String reporterId = 'reporterId';
  static const String reporterName = 'reporterName';
  static const String reason = 'reason';
  static const String additionalInfo = 'additionalInfo';
  static const String evidenceUrls = 'evidenceUrls';
  static const String createdAt = 'createdAt';
  static const String reviewed = 'reviewed';
  static const String adminNote = 'adminNote';
}

/// Firestore error codes
class FirestoreErrorCodes {
  FirestoreErrorCodes._();
  static const String permissionDenied = 'permission-denied';
  static const String notFound = 'not-found';
  static const String alreadyExists = 'already-exists';
  static const String failedPrecondition = 'failed-precondition';
  static const String aborted = 'aborted';
  static const String unavailable = 'unavailable';
  static const String deadlineExceeded = 'deadline-exceeded';
  static const String unauthenticated = 'unauthenticated';
}

class StorageErrorCodes {
  StorageErrorCodes._();
  static const String unauthorized = 'storage/unauthorized';
  static const String canceled = 'storage/canceled';
  static const String objectNotFound = 'storage/object-not-found';
  static const String quotaExceeded = 'storage/quota-exceeded';
  static const String unauthenticated = 'storage/unauthenticated';
  static const String retryLimitExceeded = 'storage/retry-limit-exceeded';
}