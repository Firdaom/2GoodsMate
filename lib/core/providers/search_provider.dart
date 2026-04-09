import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeSearchQueryProvider = StateProvider<String>((ref) => '');
final homeCategoryProvider = StateProvider<String>((ref) => 'All');
final homeRarityProvider = StateProvider<String>((ref) => 'All');


// --- สำหรับหน้า Watchlist ---
final watchlistSearchQueryProvider = StateProvider<String>((ref) => '');
final watchlistCategoryProvider = StateProvider<String>((ref) => 'All');
final watchlistRarityProvider = StateProvider<String>((ref) => 'All');