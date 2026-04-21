import 'package:anigoods/features/home/providers/home_filter_provider.dart';
import 'package:anigoods/models/item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../repositories/home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeRepositoryProvider = Provider((ref) {
  return HomeRepository(
    firestore: FirebaseFirestore.instance,
  );
});


final homeItemsProvider = StreamProvider.autoDispose<List<ItemModel>>((ref) {
  //  ดึงตัว Repository 
  final repo = ref.watch(homeRepositoryProvider);

 
  final filter = ref.watch(homeFilterProvider);

  
  return repo.getItemsStream(filter.category, filter.rarity).map((items) {
    
    if (filter.query.isEmpty) {
      return items;
    }

   
    final lowerCaseQuery = filter.query.toLowerCase();
    return items.where((item) => item.matchesQuery(lowerCaseQuery)).toList();
  });
});

final homeScrollTriggerProvider = StateProvider<int>((ref) => 0);