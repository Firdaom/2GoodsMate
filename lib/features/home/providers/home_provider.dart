import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../repositories/home_repository.dart';

final homeRepositoryProvider = Provider((ref) {
  return HomeRepository(
    firestore: FirebaseFirestore.instance,
  );
});