import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anigoods/core/theme/app_theme.dart';
import 'package:anigoods/core/widgets/common_widgets.dart';
import 'package:anigoods/core/constants/firebase_constants.dart';

class AddressManagerCard extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddressUpdated;

  const AddressManagerCard({super.key, required this.onAddressUpdated});

  @override
  State<AddressManagerCard> createState() => _AddressManagerCardState();
}

class _AddressManagerCardState extends State<AddressManagerCard> {
  Map<String, dynamic> _currentAddress = {
    'name': '',
    'phone': '',
    'detail': '',
  };

  bool get _hasAddress =>
      _currentAddress['name'].isNotEmpty &&
      _currentAddress['phone'].isNotEmpty &&
      _currentAddress['detail'].isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  // 1. ลอจิกโหลดข้อมูล
  Future<void> _loadSavedAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data()!.containsKey('address')) {
        if (mounted) {
          setState(() {
            _currentAddress = Map<String, dynamic>.from(doc.data()!['address']);
          });
          widget.onAddressUpdated(_currentAddress);
        }
      }
    } catch (e) {
      debugPrint("Error loading address: $e");
    }
  }

  // 2. ลอจิกหน้าต่างแก้ไข + เซฟข้อมูล
  void _showEditAddressDialog() {
    final nameCtrl = TextEditingController(text: _currentAddress['name']);
    final phoneCtrl = TextEditingController(text: _currentAddress['phone']);
    final detailCtrl = TextEditingController(text: _currentAddress['detail']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Delivery Address', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField('Full Name', nameCtrl),
              const SizedBox(height: 12),
              _buildDialogTextField('Phone Number', phoneCtrl, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildDialogTextField('Full Address', detailCtrl, maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: AppTheme.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newAddress = {
                'name': nameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
                'detail': detailCtrl.text.trim(),
              };

              setState(() {
                _currentAddress = newAddress;
              });
              
              widget.onAddressUpdated(_currentAddress);
              Navigator.pop(context);

              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                try {
                  await FirebaseFirestore.instance
                      .collection(FirebaseCollections.users)
                      .doc(user.uid)
                      .set({'address': newAddress}, SetOptions(merge: true));
                } catch (e) {
                  debugPrint('Error saving address: $e');
                }
              }
            },
            child: const Text('Save Address', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  // 3. UI การ์ดแสดงผล
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('SHIPPING ADDRESS'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showEditAddressDialog,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_outlined, color: AppTheme.accent, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hasAddress ? '${_currentAddress['name']} (${_currentAddress['phone']})' : 'No Shipping Address',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _hasAddress ? _currentAddress['detail'] : 'Tap here to add your delivery address',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit_outlined, color: AppTheme.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}