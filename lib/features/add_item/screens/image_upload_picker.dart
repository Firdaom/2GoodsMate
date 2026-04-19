import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:anigoods/core/theme/app_theme.dart';


// เขียนไว้พัฒนาต่อสำหรับใช้งานโพสต์สินค้า เมื่อยูเซอร์จะเปิดร้านเอง ปัจจุบันนี้อยุ่ในช่วงพัฒนา ยังไม่มีการดึงโค้ดหน้านี้ไปใช้

class ImageUploadPicker extends StatelessWidget {
  final List<XFile> imageFiles;
  final VoidCallback onPickImage;
  final Function(int) onRemoveImage;

  const ImageUploadPicker({
    super.key,
    required this.imageFiles,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  // ฟังก์ชันพรีวิวรูปภาพ
Widget _buildImagePreview(XFile imageFile) {
  if (kIsWeb) {
    return FutureBuilder<Uint8List>(
      future: imageFile.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(snapshot.data!, fit: BoxFit.contain, width: double.infinity);
        }
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  } else {
    return Image.file(
      File(imageFile.path), 
      fit: BoxFit.contain, 
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: AppTheme.danger),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    if (imageFiles.isEmpty) {
      return Center(
        child: GestureDetector(
          onTap: onPickImage, 
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.accentLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.accent.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppTheme.accent,
                  size: 32,
                ),
                SizedBox(height: 6),
                Text(
                  'Add Photos',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carousel with PageView
        Container(
          height: 280,
          color: AppTheme.accentLight,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(),
            pageSnapping: true,
            itemCount: imageFiles.length + 1, 
            itemBuilder: (context, index) {
              if (index == imageFiles.length) { 
                // Add More button
                return Center(
                  child: GestureDetector(
                    onTap: onPickImage, 
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.accent.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: AppTheme.accent,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Add More Photos',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Show image
              return Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: _buildImagePreview(imageFiles[index]), 
                  ),
                  // Delete button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => onRemoveImage(index), 
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.danger,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Thumbnail list
        if (imageFiles.isNotEmpty) ...[ 
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageFiles.length, 
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: AppTheme.accentLight,
                      alignment: Alignment.center,
                      child: _buildImagePreview(imageFiles[index]), 
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}