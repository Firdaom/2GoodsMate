import 'package:anigoods/models/item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:anigoods/core/repositories/item_repository.dart';

final itemDetailProvider = FutureProvider.family<ItemModel?, String>((ref, id) {
  return ref.watch(itemRepositoryProvider).getItem(id);
});