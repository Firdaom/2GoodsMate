import 'package:anigoods/models/filter_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final watchlistFilterProvider = StateProvider<ItemFilter>((ref) => ItemFilter());


// ══════════════════════════════════════════════════════════
//  PROVIDERS สำหรับหน้า Watchlist 
// ══════════════════════════════════════════════════════════
final watchlistSearchQueryProvider = StateProvider<String>((ref) => '');
final watchlistCategoryProvider = StateProvider<String>((ref) => 'All');
final watchlistRarityProvider = StateProvider<String>((ref) => 'All');
