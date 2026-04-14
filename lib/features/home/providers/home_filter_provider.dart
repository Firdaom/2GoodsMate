import 'package:anigoods/models/filter_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final homeFilterProvider = StateProvider<ItemFilter>((ref) => ItemFilter());