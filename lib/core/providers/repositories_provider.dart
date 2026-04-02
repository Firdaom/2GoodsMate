import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anigoods/features/auth/repositories/auth_repository.dart';
import 'package:anigoods/features/profile/repositories/user_repository.dart';
import 'package:anigoods/features/profile/repositories/profile_repository.dart';
import 'package:anigoods/features/home/repositories/home_repository.dart';
import 'package:anigoods/features/watchlist/repositories/watchlist_repository.dart';
import 'package:anigoods/core/repositories/item_repository.dart';

// ✅ ให้ repositories พร้อมใช้ทั่ว app
final authRepositoryProvider = Provider((ref) {
  return AuthRepository();
});

final userRepositoryProvider = Provider((ref) {
  return UserRepository();
});

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepository();
});

final homeRepositoryProvider = Provider((ref) {
  return HomeRepository();
});

final watchlistRepositoryProvider = Provider((ref) {
  return WatchlistRepository();
});

// Item Repository 
final itemRepositoryProvider = Provider((ref) {
  return ItemRepository();
});
