import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anigoods/models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🚀 ฟังก์ชันบันทึกออเดอร์ใหม่ลง Firebase
  Future<String?> createOrder(OrderModel order) async {
    try {
      // 1. ส่งข้อมูลไปที่ collection 'orders'
      // .add() จะสร้าง Document ID ให้เราอัตโนมัติ
      DocumentReference docRef = await _firestore.collection('orders').add(order.toMap());
      
      // 2. ส่ง ID ที่ได้กลับไป เพื่อเอาไปใช้เปิดหน้า Order Status ต่อ
      return docRef.id;
    } catch (e) {
      print('🔥 Error creating order: $e');
      return null;
    }
  }
}