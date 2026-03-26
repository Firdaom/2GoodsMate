import 'package:anigoods/features/auth/repositories/auth_repository.dart';
import 'package:anigoods/features/home/repositories/home_repository.dart';
import 'package:anigoods/features/profile/repositories/profile_repository.dart';
import 'package:anigoods/features/profile/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [AuthRepository] provider
final authRepositoryProvider = Provider((ref) {
  return AuthRepository();
});

/// [UserRepository] provider
final userRepositoryProvider = Provider((ref) {
  return UserRepository();
});

/// [ProfileRepository] provider
final profileRepositoryProvider = Provider((ref) {
  return ProfileRepository();
});

/// [HomeRepository] provider
final homeRepositoryProvider = Provider((ref) {
  return HomeRepository();
});